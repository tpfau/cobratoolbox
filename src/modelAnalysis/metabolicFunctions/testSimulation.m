function [success,sol,lp] = testSimulation(model,Objectives,Constraints,Evaluators)
% testSimulation test a model whether the given Objectives can be achieved,
% given the constraints provided. This is evaluated using the provided
% Evaluators.
%
% USAGE:
%    [success,sol,lp] = testSimulation(model,Objectives,Constraints,Evaluators)
%
% INPUTS:
%    model:                The model used for the Simulation 
%    Objectives:           A Cell array (x by 2) with X1 being metabolite
%                          IDs and X2 being directionality constraints. -1
%                          indicates that this metabolite has to be consumed,
%                          +1 indicates, that this metabolite has to be
%                          produced
%    Constraints:          A Cell array (x by 2) with X1 being metabolite
%                          IDs and X2 being directionality constraints. -1
%                          indicates that this metabolite can be consumed,
%                          +1 indicates, that this metabolite can be
%                          produced, and 0 indicates that it can be either
%                          taken up or consumed
%    Evaluators:           A column cell array where each row indicates a
%                          metabolite that should have a non-zero
%                          consumtion or production. 'fail' indicates, that
%                          this test should be infeasible.
%
% OUTPUTS:
%    success:           Whether the test was successful (a "fail" test is
%                       successful if the actual test is infeasible.
% OPTIONAL OUTPUTS:
%    sol:               The solution obatined
%    lp:                The linear problem generated
%
% .. Authors: 
%    Thomas Pfau June 2017


[exc] = findExcRxns(model); 
%Close all exchanges
model.lb(exc) = 0;
model.ub(exc) = 0;

%setup the LP bs will allow uptake/release.
lp = setupSimulationLP(model);

%Get Positive and Negative indicators
PosObj = (cell2mat(Objectives(:,2)) == 1);
NegObj = (cell2mat(Objectives(:,2)) == -1);

PosObjPositions = ismember(model.mets,Objectives(PosObj,1));
NegObjPositions = ismember(model.mets,Objectives(NegObj,1));

%Get constraint directions
uptake = (cell2mat(Constraints(:,2)) == -1);
export = (cell2mat(Constraints(:,2)) == 1);
both = (cell2mat(Constraints(:,2)) == 0);

uptakePos =  ismember(model.mets,Constraints(uptake,1));
exportPos =  ismember(model.mets,Constraints(export,1));
bothPos =  ismember(model.mets,Constraints(both,1));
successTest = 1;
%Check whether we have a fail test
if strcmp(Evaluators{1,1},'fail')
    successTest = 0;
else
    EvalPos =  ismember(model.mets,Evaluators(:,1));
end

%Set the Objective (Positive compounds have to accumulate, negative ones
%have to be removed from the system.
lp.b(PosObjPositions) = 1;
lp.b(PosObjPositions) = 1;

lp.b(NegObjPositions) = -1;
lp.b(NegObjPositions) = -1;

%Set the Constraints.

%Compounds which can be taken up have a lower 
lp.csense(uptakePos | bothPos) = 'L';

%Compounds which can be expoorted will have their maximum accumulation set to
%10000
lp.csense(exportPos | bothPos) = 'G';

%Now, this is awkward. We might have free metabolites, which are later
%necessary. So, we will remove the corresponding lines if they are free.
freeMets = (exportPos & uptakePos) | bothPos;
lp.csense = lp.csense(~freeMets);
lp.A = lp.A(~freeMets,:);
lp.b = lp.b(~freeMets,:);

sol = solveCobraLP(lp);
%Evaluate
if (sol.stat == 1) && successTest
    nRxns = size(model.rxns,1);    
    relsol = sol.full(1:nRxns) + sol.full(nRxns+(1:nRxns));
    EvaluationValues = model.S * relsol;   
    EvaluationValues = EvaluationValues(EvalPos);
    if isempty(find(abs(EvaluationValues) < 1e-8))
        success = 1;
    else
        success = 0;
    end
else
    if ~successTest && (sol.stat ~= 1)
        success = 1;
    else
        success = 0;
    end
end

    
end