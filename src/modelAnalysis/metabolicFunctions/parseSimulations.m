function SimulationStruct = parseSimulations(FileName, specialSubstrates)
% parses a single row of a simulation/Test table
%
% USAGE:
%    SimulationStruct = parseSimulations(FileName, specialSubstrates)
%
% INPUTS:
%    FileName:             A file  containing a table with 4 Columns. 
%                          - The first Column contains a Name
%                          - The second column contains the objective (e.g. (-)atp[c]),
%                            indicating, whether the compound should eb
%                            consumed (indicated by a - before the compound)
%                            or produced (just the compound). 
%                          - The third column contains Constraints. These
%                            are again metabolite names separated by
%                            spaces. A + indicates possible release, a -
%                            indicates possible uptake and a = in front of
%                            the metabolite indicates possible uptake or
%                            release.
%                          - The fourth Column are evaluators (again
%                            metabolite names), which should have non zero
%                            accumulation/depletion.
%
%    specialSubstrates:    - a struct containing fields for special
%                            substrates (e.g. whole Formulations of
%                            available substrates). If a metabolite in any
%                            column matches a special substrate, the
%                            respective cell arrays for that substrate will
%                            eb appended.
%
% OUTPUTS:
%    SimulationStruct:   A Struct with 4 fields:
%                        - Constraints a Cell array containing the
%                          constraints for each Test/Simulation
%                        - Objectives a Cell array containing the
%                          objectives for each Test/Simulation
%                        - Evaluators a Cell array containing the
%                          evaluators for each Test/Simulation
%                        - Names a Cell array containing the
%                          names for each Test/Simulation
%
%                       successful if the actual test is infeasible.
%
% .. Authors: 
%    Thomas Pfau June 2017

SimulationStruct = struct();

Constraints = {};
Evaluators = {};
Objectives = {};
Names = {};
[~,~,extension] = fileparts(FileName);
switch extension
    case '.csv'
        table = readtable(FileName,'Delimiter','\t');
    case '.xlsx'
        table = readtable(FileName);
    case '.xls'
        table = readtable(FileName);            
end

if ~exist('table','var')
    error('Could not determine file type of provided spreadsheet');
end

for i = 1:size(table,1)
    if ~isempty(table{i,2}{1})
        %This indicates we are in a simulation row        
        Objectives(end+1) = {parseConstraintData(table{i,2}{1},specialSubstrates)};        
        Constraints(end+1) = {parseConstraintData(table{i,3}{1},specialSubstrates)};
        Evaluators(end+1) = {parseConstraintData(table{i,4}{1},specialSubstrates)};
        Names(end+1) = table{i,1}(1);
    end
end
SimulationStruct.Constraints = Constraints;
SimulationStruct.Evaluators = Evaluators;
SimulationStruct.Objectives = Objectives;
SimulationStruct.Names = Names;
