function gurobiproblem = buildGUROBIProblemFromCOBRAStruct(CobraProblem, problemType)
% create a gurobi problem from the given COBRA LPproblem structure.
% USAGE:
%    gurobiproblem = buildGUROBIProblemFromCOBRAStruct(CobraProblem)
%
% INPUTS:
%    LPproblem:         a COBRA LP problem struct
%    problemType:       The type of problem
%
% OUTPUT:
%    gurobiproblem:     A problem struct for gurobi.

gurobiproblem.sense(CobraProblem.csense == 'L') = '<';
% build the csense vector
gurobiproblem.sense(CobraProblem.csense == 'G') = '>';
gurobiproblem.sense(CobraProblem.csense == 'E') = '=';
gurobiproblem.sense = gurobiproblem.sense';
% copy the lb and ub vectors
gurobiproblem.lb = CobraProblem.lb;
gurobiproblem.ub = CobraProblem.ub;

% make sure, that the A matrix is sparse
gurobiproblem.A = sparse(CobraProblem.A);

% translate the rhs vector
gurobiproblem.rhs = CobraProblem.b;

% set the objective vector
if (strcmp(problemType,'QP') || strcmp(problemType,'MIQP'))
    gurobiproblem.obj = CobraProblem.c * CobraProblem.osense;
    gurobiproblem.modelsense = 'min';
else    
    if CobraProblem.osense == -1
    % set the correct objective sense.
        gurobiproblem.modelsense = 'max';
    else
        gurobiproblem.modelsense = 'min';
    end
    gurobiproblem.obj =  CobraProblem.c;
end

% set the basis, if provided
if isfield(CobraProblem,'basis') && ~isempty(CobraProblem.basis)
	gurobiproblem.cbasis = full(CobraProblem.basis.cbasis);
    gurobiproblem.vbasis = full(CobraProblem.basis.vbasis);
end
% set the Q matrix
if isfield( CobraProblem,'F') && (strcmp(problemType,'QP') || strcmp(problemType,'MIQP'))
    gurobiproblem.Q = 0.5*sparse(CobraProblem.F);
end
% set the variable type if applicable
if isfield( CobraProblem,'vartype') && (strcmp(problemType,'MILP') || strcmp(problemType,'MIQP'))
    gurobiproblem.vtype = CobraProblem.vartype;
end
% set an initial solution
if isfield(CobraProblem,'x0') && ~isempty(CobraProblem.x0)
    gurobiproblem.start = CobraProblem.x0;
end