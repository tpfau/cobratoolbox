function [minFlux, maxFlux, Vmin, Vmax] = fluxVariability(model, optPercentage, osenseStr, rxnNameList, printLevel, allowLoops, method, cpxControl, advind, useMtFVA)
% Performs flux variablity analysis
%
% USAGE:
%
%    [minFlux, maxFlux] = fluxVariability(model, optPercentage, osenseStr, rxnNameList, printLevel, allowLoops, method)
%
% INPUT:
%    model:            COBRA model structure
%
% OPTIONAL INPUTS:
%    optPercentage:    Only consider solutions that give you at least a certain
%                      percentage of the optimal solution (Default = 100
%                      or optimal solutions only)
%    osenseStr:        Objective sense ('min' or 'max') (Default = 'max')
%    rxnNameList:      List of reactions for which FVA is performed
%                      (Default = all reactions in the model)
%    printLevel:       Verbose level (default: 0)
%    allowLoops:       Whether loops are allowed in solution. (Default = true)
%                      See `optimizeCbModel` for description
%    method:           when Vmin and Vmax are in the output, the flux vector can be (Default = 2-norm):
%
%                        * 'FBA'    : standards FBA solution
%                        * '0-norm' : minimzes the vector  0-norm
%                        * '1-norm' : minimizes the vector 1-norm
%                        * '2-norm' : minimizes the vector 2-norm
%                        * 'minOrigSol' : minimizes the euclidean distance of each vector to the original solution vector
%
%   cpxControl:        solver-specific parameter structure
%
%   advind:            switch to use the solution basis
%
%                           - 0 : default
%                           - 1 : uses the original problem solution basis as advanced basis
%
%   useMtFVA:          run FVA multi-threaded via an external JVM with CPLEX as solver
%                      does not return Vmin, Vmax; requires allowLoops = true and method = 'FBA'
%
%                           - 0 : default, do not use mtFVA
%                           - 1 : use mtFVA
%
% OUTPUTS:
%    minFlux:          Minimum flux for each reaction
%    maxFlux:          Maximum flux for each reaction
%
% OPTIONAL OUTPUT:
%    Vmin:             Matrix of column flux vectors, where each column is a
%                      separate minimization.
%    Vmax:             Matrix of column flux vectors, where each column is a
%                      separate maximization.
%
% .. Authors:
%       - Markus Herrgard  8/21/06 Original code.
%       - Ronan Fleming   01/20/10 Take the extremal flux from the flux vector,
%                         not from the objective since this is invariant
%                         to the value and sign of the coefficient
%       - Ronan Fleming   27/09/10 Vmin, Vmax
%       - Marouen Ben Guebila 22/02/2017 Vmin,Vmax method

global CBT_LP_PARAMS

if nargin < 2
    optPercentage = 100;
end
if nargin < 3 || isempty(osenseStr)
    [osenseStr,~] = getObjectiveSense(model);
end
if nargin < 4
    rxnNameList = model.rxns;
end
if nargin < 5
    printLevel = 0;
end
if nargin < 6
    allowLoops = true;
end
if nargin < 7
    method = '2-norm';
end
if nargin < 8
    cpxControl = struct();
end
if nargin < 9
   advind = 0;
end
if nargin < 10
    useMtFVA= false;
end
if isempty(optPercentage)
    optPercentage = 100;
end
if isempty(rxnNameList)
    rxnNameList = model.rxns;
end

%Stop if there are reactions, which are not part of the model
if any(~ismember(rxnNameList,model.rxns))
    presence = ismember(rxnNameList,model.rxns);
    error('There were reactions in the rxnList which are not part of the model:\n%s\n',strjoin(rxnNameList(~presence),'\n'));
end

if useMtFVA && (nargout > 2 || ~allowLoops || ~strcmp(method,'FBA'))
   error('mtFVA only supports the FBA method and neither supports loopless contraints nor Vmin/Vmax');
end

% Set up the problem size
[nMets,nRxns] = size(model.S);
Vmin=[];
Vmax=[];
if nargout > 2
    OutputMatrix = 1;
else
    OutputMatrix = 0;
end

% LP solution tolerance
if exist('CBT_LP_PARAMS', 'var')
    if isfield(CBT_LP_PARAMS, 'objTol')
        tol = CBT_LP_PARAMS.objTol;
    else
        tol = 1e-6;
    end
    if nargout < 3
        minNorm = 0;
    else
        minNorm = 1;
    end
end

%Return if minNorm is not FBA but allowloops is set to false
%This is currently not supported as it requires mechanisms that are likely
%incompatible.
if ~allowLoops && minNorm && ~strcmp(method,'FBA')
    error('Cannot return solutions with special properties if allowLoops is set to false.\nIf you want solutions without loops please set method to ''FBA''.');
end
% Determine constraints for the correct space (0-100% of the full space)
if sum(model.c ~= 0) > 0
    hasObjective = true;
else
    hasObjective = false;
end

if printLevel == 1
    showprogress(0,'Flux variability analysis in progress ...');
end
if printLevel > 1
    fprintf('%4s\t%4s\t%10s\t%9s\t%9s\n','No','Perc','Name','Min','Max');
end

% Set up the general problem
LPproblem = buildLPproblemFromModel(model);

% Solve initial (normal) LP
if allowLoops
    tempSolution = solveCobraLP(LPproblem, cpxControl);
else
    MILPproblem = addLoopLawConstraints(LPproblem, model, 1:nRxns);
    tempSolution = solveCobraMILP(MILPproblem);
end

if tempSolution.stat == 1
    if strcmp(osenseStr,'max')
        objValue = floor(tempSolution.obj/tol)*tol*optPercentage/100;
    else
        objValue = ceil(tempSolution.obj/tol)*tol*optPercentage/100;
    end
else
    error('The FVA could not be run because the model is infeasible or unbounded')
end

%set the objective
if hasObjective
    LPproblem.A = [LPproblem.A;columnVector(LPproblem.c)'];
    LPproblem.b = [LPproblem.b;objValue];    
    if strcmp(osenseStr, 'max')
        LPproblem.csense(end+1) = 'G';
    else
        LPproblem.csense(end+1) = 'L';
    end
    model = addCOBRAConstraints(model,model.rxns(find(model.c)),objValue,'dsense',LPproblem.csense(end));
end

%get the initial basis
if advind == 1
    LPproblem.basis = tempSolution.basis;
end
LPproblem.S = LPproblem.A;%needed for sparse optimisation

% Loop through reactions
maxFlux = zeros(length(rxnNameList), 1);
minFlux = zeros(length(rxnNameList), 1);

%Thats not true. The Euclidean norm does not get rid of loops if the
%objective reaction is part of the loop.
% if length(minNorm)> 1 || minNorm > 0
%     %minimizing the Euclidean norm gets rid of the loops, so there
%     %is no need for a second slower MILP approach
%     allowLoops=1;
% end

solutionPool = zeros(length(model.lb), 0);

v=ver;
PCT = 'Parallel Computing Toolbox';
if ~useMtFVA && any(strcmp(PCT,{v.Name})) && license('test','Distrib_Computing_Toolbox')
    try
        p = gcp('nocreate');
        PCT_status=1;
    catch
        PCT_status = 0;
    end
else
    PCT_status=0;  % Parallel Computing Toolbox not found.
end

preCompMaxSols = cell(nRxns,1);
preCompMinSols = cell(nRxns,1);

%We will calculate a min and max sum flux solution.
%This solution will (hopefully) provide multiple solutions for individual
%reactions.
QuickProblem = LPproblem;
[Presence,Order] = ismember(rxnNameList,model.rxns);
minFlux = model.lb(Order);
maxFlux = model.ub(Order);
QuickProblem.c(:) = 0;
QuickProblem.c(Order(Presence)) = 1;
if ~allowLoops
    QuickProblem = addLoopLawConstraints(QuickProblem,model,1:nRxns);
end
%Maximise all reactions
QuickProblem.osense = -1;
if ~allowLoops
    sol = solveCobraMILP(QuickProblem);
else
    sol = solveCobraLP(QuickProblem);
end
%If we reach this point, we can be certain, that there is a solution, i.e.
%if the stat is not 1, we have to check all reactions.
if sol.stat == 1
    relSol = sol.full(Order(Presence));
    %Obtain fluxes at their boundaries
    maxSolved = model.ub(Order(Presence)) == relSol;
    minSolved = model.lb(Order(Presence)) == relSol;
    if minNorm
        preCompMaxSols(maxSolved) = {sol};
        preCompMinSols(minSolved) = {sol};
    end
else
    maxSolved = false(size(model.lb));
    minSolved = false(size(model.lb));
end
%Minimise reactions
QuickProblem.osense = 1;
if ~allowLoops
    sol = solveCobraMILP(QuickProblem);
else
    sol = solveCobraLP(QuickProblem);
end
if sol.stat == 1
    relSol = sol.full(Order(Presence));
    %Again obtain fluxes at their boundaries
    maxSolved = maxSolved | (model.ub(Order(Presence)) == relSol);
    minSolved = minSolved | (model.lb(Order(Presence)) == relSol);
    %This is only necessary, if we want a min norm.
    if minNorm
        preCompMaxSols((model.ub(Order(Presence)) == relSol)) = {sol};
        preCompMinSols((model.lb(Order(Presence)) == relSol)) = {sol};
    end
end
%Restrict the reactions to test only those which are not at their boundariestestFv.
rxnListMin = rxnNameList(~minSolved);
rxnListMax = rxnNameList(~maxSolved);

if useMtFVA
    [~, idxMin]= ismember(rxnListMin, model.rxns);
    [~, idxMax]= ismember(rxnListMax, model.rxns);
    [fvalb, fvaub]= mtFVA(LPproblem, [idxMax(:); -idxMin(:)], cpxControl);
    minFlux= fvalb(Order);
    maxFlux= fvaub(Order);
elseif ~PCT_status %aka nothing is active
    if minNorm
        for i = 1:length(rxnNameList)
        
            LPproblem.osense = 1;
            [minFlux(i),Vmin(:,i)] = calcSolForEntry(model,rxnNameList,i,LPproblem,0, method, allowLoops,printLevel,minNorm,cpxControl,preCompMinSols{i});
            LPproblem.osense = -1;
            [maxFlux(i),Vmax(:,i)] = calcSolForEntry(model,rxnNameList,i,LPproblem,0, method, allowLoops,printLevel,minNorm,cpxControl,preCompMaxSols{i});

            if printLevel == 1
                showprogress(i/length(rxnNameList));
            end
            if printLevel > 1
                fprintf('%4d\t%4.0f\t%10s\t%9.3f\t%9.3f\n',i,100*i/length(rxnNameList),rxnNameList{i},minFlux(i),maxFlux(i));
            end
        end
    else
        %Calc minimums
        mins = -inf*ones(length(rxnListMin),1);
        LPproblem.osense = 1;
        for i = 1:length(rxnListMin)                        
            [mins(i)] = calcSolForEntry(model,rxnListMin,i,LPproblem,0, method, allowLoops,printLevel,minNorm,cpxControl,[]);
        end
        [minFluxPres,minFluxOrder] = ismember(rxnListMin,rxnNameList);
        minFlux(minFluxOrder(minFluxPres)) = mins;   
        %calc maximiums
        maxs = inf*ones(length(rxnListMax),1);
        LPproblem.osense = -1;
        for i = 1:length(rxnListMax)                        
            [maxs(i)] = calcSolForEntry(model,rxnListMax,i,LPproblem,0, method, allowLoops,printLevel,minNorm,cpxControl,[]);
        end
        [maxFluxPres,maxFluxOrder] = ismember(rxnListMax,rxnNameList);
        maxFlux(maxFluxOrder(maxFluxPres)) = maxs; 
    end
else % parallel job.  pretty much does the same thing.
    environment = getEnvironment();
    
    if minNorm        
        parfor i = 1:length(rxnNameList)
            restoreEnvironment(environment,0);
            parLPproblem = LPproblem;        
            parLPproblem.osense = 1;
            [minFlux(i),Vmin(:,i)] = calcSolForEntry(model,rxnNameList,i,parLPproblem,1, method, allowLoops,printLevel,minNorm,cpxControl,preCompMinSols{i});
            parLPproblem.osense = -1;
            [maxFlux(i),Vmax(:,i)] = calcSolForEntry(model,rxnNameList,i,parLPproblem,1, method, allowLoops,printLevel,minNorm,cpxControl,preCompMaxSols{i});
        end
    else
        mins = -inf*ones(length(rxnListMin),1);
        LPproblem.osense = 1;
        parfor i = 1:length(rxnListMin)
            restoreEnvironment(environment,0);
            parLPproblem = LPproblem;
            [mins(i)] = calcSolForEntry(model,rxnListMin,i,parLPproblem,1, method, allowLoops,printLevel,minNorm,cpxControl,[]);
        end
        [minFluxPres,minFluxOrder] = ismember(rxnListMin,rxnNameList);
        minFlux(minFluxOrder(minFluxPres)) = mins;   
        %calc maximiums
        maxs = inf*ones(length(rxnListMax),1);
        LPproblem.osense = -1;
        parfor i = 1:length(rxnListMax)        
            restoreEnvironment(environment,0);
            parLPproblem = LPproblem;
            [maxs(i)] = calcSolForEntry(model,rxnListMax,i,parLPproblem,1, method, allowLoops,printLevel,minNorm,cpxControl,[]);
        end
        [maxFluxPres,maxFluxOrder] = ismember(rxnListMax,rxnNameList);
        maxFlux(maxFluxOrder(maxFluxPres)) = maxs;         
    end
end

maxFlux = columnVector(maxFlux);
minFlux = columnVector(minFlux);
end

function [Flux,V] = calcSolForEntry(model,rxnNameList,i,LPproblem,parallelMode, method, allowLoops, printLevel, minNorm, cpxControl, sol)

    %get Number of reactions
    nRxns = numel(model.rxns);
    %Set the correct objective
    LPproblem.c(:) = 0;
    LPproblem.c(find(ismember(model.rxns,rxnNameList{i}))) = 1;
    if isempty(sol)
        if printLevel == 1 && ~parallelMode
            fprintf('iteration %d.\n', i);
        end
        % do LP always
        if allowLoops
            LPsolution = solveCobraLP(LPproblem, cpxControl);
        else
            LPsolution = solveCobraMILP(addLoopLawConstraints(LPproblem, model));
        end
        % take the maximum flux from the flux vector, not from the obj -Ronan
        % A solution is possible, so the only problem should be if its
        % unbounded and if it is unbounded, the max flux is infinity.
        if LPsolution.stat == 2
            Flux = -LPproblem.osense * inf;
        elseif LPsolution.stat == 1        
            Flux = getObjectiveFlux(LPsolution, LPproblem);
        else
            error(sprintf(['A Solution could not be found!\nThis should not be possible but can happen',...
                   'if the used solver cannot properly handle unboundedness, or if there are numerical issues.\n',...
                   'Please try to use a different solver.\n']))
        end
    else
        LPsolution = sol;
        Flux = getObjectiveFlux(LPsolution, LPproblem);        
    end
    % minimise the Euclidean norm of the optimal flux vector to remove loops -Ronan
    if minNorm == 1
        V = getMinNorm(LPproblem, LPsolution, nRxns, Flux, model, method);
    end
end


function V = getMinNorm(LPproblem,LPsolution,nRxns,cFlux, model, method)
% get the Flux distribution for the specified min norm.

    if strcmp(method, '2-norm')
        QPproblem=LPproblem;
        QPproblem.lb(LPproblem.c~=0) = cFlux - 1e-12;
        QPproblem.ub(LPproblem.c~=0) = cFlux + 1e12;
        QPproblem.c(:)=0;
        %Minimise Euclidean norm using quadratic programming
        QPproblem.F = [speye(nRxns,nRxns), sparse(nRxns,size(LPproblem.A,2)-nRxns);...
                      sparse(size(LPproblem.A,2)-nRxns,size(LPproblem.A,2))];
        QPproblem.osense = 1;
        %quadratic optimization
        solution = solveCobraQP(QPproblem);
        V=solution.full(1:nRxns,1);
    elseif strcmp(method, '1-norm')
        vSparse = sparseFBA(LPproblem, 'min', 0, 0, 'l1');
        V = vSparse;
    elseif strcmp(method, '0-norm')
        vSparse = sparseFBA(LPproblem, 'min', 0, 0);
        V = vSparse;
    elseif strcmp(method, 'FBA')
        V=LPsolution.full(1:nRxns);
    elseif strcmp(method, 'minOrigSol')
        % we take the original model, and constrain the objective reaction
        % accordingly.
        LPproblemMOMA = model;                
        LPproblemMOMA.lb(LPproblem.c(1:nRxns)~=0) = cFlux - 1e-12;
        LPproblemMOMA.ub(LPproblem.c(1:nRxns)~=0) = cFlux + 1e-12;        
        momaSolution = linearMOMA(model,LPproblemMOMA);
        V=momaSolution.x;
    end
end


function flux = getObjectiveFlux(LPsolution,LPproblem)
% Determine the current flux based on an LPsolution, the original LPproblem
% The LPproblem is used to retrieve the current objective position.
% min indicates, whether the minimum or maximum is requested, the
% upper/lower bounds are used, if the value is exceeding them

    Index = LPproblem.c~=0;
    if LPsolution.full(Index)<LPproblem.lb(Index) %takes out tolerance issues
        flux = LPproblem.lb(Index);
    elseif LPsolution.full(Index)>LPproblem.ub(Index)
        flux = LPproblem.ub(Index);
    else
        flux = LPsolution.full(Index);
    end
end
