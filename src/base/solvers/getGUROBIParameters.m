function [params] = getGUROBIParameters(cobraParams, solverParams, problemType)
% Set the parameters for a specific problem from the COBRA Parameter
% structure and a solver specific parameter structre (latter has
% precedence)
% USAGE:
%    cplexProblem = setCplexParametersForProblem(cplexProblem, cobraParams, solverParams, ProblemType)
%
% INPUTS:
%    cplexProblem:      the Cplex() object to set the parameters
%    cobraParams:       the COBRA parameter structure
%    solverParams:      the solver specific parameter structure (must be a
%                       valid input to `setCplexParam`;
%    problemType:       The type of Problem ('LP','MILP','QP','MIQP').
%
% OUTPUTS:
%    params:            The parameter struct provided to GUROBI.        



params = struct();
%Set up the parameters
switch cobraParams.printLevel
    case 0
        params.OutputFlag = 0;
        params.DisplayInterval = 1;
    case cobraParams.printLevel>1
        params.OutputFlag = 1;
        params.DisplayInterval = 5;
    otherwise
        params.OutputFlag = 0;
        params.DisplayInterval = 1;
end

if ischar(cobraParams.logFile) && ~isempty(cobraParams.logFile)
    params.LogFile = cobraParams.logFile;
end
if isfield(cobraParams,'method')
    params.Method = cobraParams.method;    %-1 = automatic, 0 = primal simplex, 1 = dual simplex, 2 = barrier, 3 = concurrent, 4 = deterministic concurrent
end

params.FeasibilityTol = cobraParams.feasTol;
params.OptimalityTol = cobraParams.optTol;

if strcmp('MIQP',problemType) || strcmp('MILP',problemType)
    params.MIPGap = cobraParams.relMipGapTol;
    params.MIPGapAbs = cobraParams.absMipGapTol;
    if cobraParams.intTol <= 1e-09
        params.IntFeasTol = 1e-09;
    else
        params.IntFeasTol = cobraParams.intTol;
    end
    params.TimeLimit = cobraParams.timeLimit;
end    

if isfield(cobraParams,'method')
    params.method = cobraParams.method;
end
%Update param struct with Solver Specific parameters
params = updateStructData(params,solverParams);

