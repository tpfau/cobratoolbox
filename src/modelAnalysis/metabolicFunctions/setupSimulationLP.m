function [LPProblem] = setupSimulationLP(model)
% Set up a basic simulation LP (splitted forward/backward reactions
%
% USAGE:
%    [LPProblem] = setupSimulationLP(model)
%
% INPUTS:
%    model:                The model used for the Simulation 
%
% OUTPUTS:
%    LPProblem:            A COBRA LP Problem with splitted reactions
%
% .. Authors: 
%    Thomas Pfau June 2017
LPProblem = struct();
[nMets,nRxns] = size(model.S);

LPProblem.c = [ones(size(model.c));ones(size(model.c))];
LPProblem.osense= 1;
LPProblem.b = model.b;
LPProblem.csense = repmat('E',nMets,1);
LPProblem.lb = [max(model.lb,zeros(nRxns,1));max(-model.ub,zeros(nRxns,1))];
LPProblem.ub = [max(model.ub,zeros(nRxns,1));max(-model.lb,zeros(nRxns,1))];
LPProblem.A = [model.S, -model.S];

end
