function [outputNode] = combineChildren(CNFNode1,CNFNode2)
% Combine the children of two nodes such that all children of node 1 are mixed with children of node 2.
% Conjunct clauses which are superseeded are removed.
% USAGE:
%    [outputNode] = combineChildren(CNFNode1,CNFNode2)
% 
% INPUTS:
%    CNFNode1:        A Node in CNF format 
%    CNFNode2:        A Node in CNF format 
%
% OUTPUTS:
%    outputNode:      A node with all children of the input nodes mixed.
%
% NOTE:
%    The function will mix all combinations of nodes. E.g. if node 1 is (A | B) & (C | D) and node 2 is (E | F) & G
%    the resulting node will be (A | B | E | F) & (A | B | G) & (C | D | E | F) & (C | D | G)
%
% .. Author: Thomas Pfau, Apr 2018

if isempty(CNFNode1.toString())
    %If one of the nodes is empty simply return the other node.
    outputNode = CNFNode2;
    return
end

if isempty(CNFNode2.toString())
    outputNode = CNFNode1;
    return
end

fp = FormulaParser();
outputNode = fp.parseFormula(['(' CNFNode1.toString(1) ') | (' CNFNode2.toString() ')']);

end

