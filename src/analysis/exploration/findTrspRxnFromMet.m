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
%            - Speedup and catching Phosphorylating Transports - Thomas Pfau 2017

if nargin < 3
    compFlag={};
end

%Get the metabolites with the given compFlag
if ~isempty(compFlag)
    metNames = regexprep(metList,'\[[^\]]+\]$','');
    metNames = unique(metNames);    
    relmets = logical(zeros(size(model.S,1),1));
    for i = 1:numel(compFlag)
        relmets = logical | ismember(model.mets,strcat(metNames,['[',CompFlag{i},']']));
    end
else
    relmets = ismember(model.mets,metList);
end

[compartments,uniqueCompartments]=getCompartment(model.mets);  
transportRxnBool = logical(zeros(size(model.S,2),1));

for n=1:size(model.S,2)
    rxnCompartments=compartments(model.S(:,n)~=0 & relmets);
    %should also omit exchange reactions
    if length(unique(rxnCompartments))>1
        transportRxnBool(n,1)=true;
    end
end


TrspRxns = model.rxns(transportRxnBool);