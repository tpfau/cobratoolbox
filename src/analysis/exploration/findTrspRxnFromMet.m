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
    % the position of the requested metabolite
	origMetPos = strcmp(model.mets,metList{i});    
    % the positions of the metabolite in all other compartments.
    targetPos = strcmp(compLessMets,searchMets{i}) & ~origMetPos;
    % restrict to the target compartment (if required)
    targetPos = targetPos & compPos;    
    % The relevant reactions are those reactions, which have the given
    % metabolite AND have at least one other metabolite of the same type
    % with a different sign. or, in other words, that do have compmets
    origProd = model.S(origMetPos,:) > 0;    
    origSubs = model.S(origMetPos,:) < 0;    
    targetProd = model.S(targetPos,:) > 0;
    targetSubs = model.S(targetPos,:) < 0;    
    relReacs = origProd & any(targetSubs,1) | origSubs & any(targetProd,1);
    TrspRxns = [TrspRxns;model.rxns(relReacs)];
end
TrspRxns = unique(TrspRxns);