function [TrspRxns] = findTrspRxnFromMet(model, metList, compFlag)
% Find transport reactions for defined metabolites. Option available to
% define the compartment of the transport
%
% USAGE:
%
%    [TrspRxns] = findTrspRxnFromMet(model, metList, compFlag)
%
% INPUTS:
%    model:       COBRA model structure
%    metList:     metabolites list
%
% OPTIONAL INPUT:
%    compFlag:    compartment of the transport (e.g. 'c', cytosol)
%
% OUTPUT:
%    TrspRxns:    List of transporters reactions
%
% .. Author: - Anne Richelle May 2017
%            - Thomas Pfau - update to use metComps

if nargin < 3
    compFlag={};
end

TrspRxns={};

if ischar(metList)
    metList = {metList};
end

% we will remove compartment parts from metabolites
[~,compLessMets] = extractCompartmentsFromMets(model.mets);
[~,searchMets] = extractCompartmentsFromMets(metList);
if ~isempty(compFlag)
    compPos = strcmp(model.metComps,compFlag);
else
    compPos = true(size(model.mets));
end
% only get directionality.
model.S = sign(model.S);

for i = 1:numel(searchMets)
    metPos = strcmp(compLessMets,searchMets{i});
    compMet = metPos & compPos;
    % The relevant reactions are those reactions, which have the given
    % metabolite AND have at least one other metabolite of the same type
    % with a different sign. or, in other words, that do have compmets
    presence = sum(abs(model.S(compMet,:)),1) > 0;
    totals = sum(abs(model.S(metPos,:)),1);
    change = abs(sum(model.S(metPos,:),1));
    relReacs = totals > change & presence;
    TrspRxns = [TrspRxns;model.rxns(relReacs)];
end
TrspRxns = unique(TrspRxns);