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

[compartments,uniqueCompartments]=getCompartment(model.mets);  

%Get the metabolites with the given compFlag
metNames = regexprep(metList,'\[[^\]]+\]$','');
metNames = unique(metNames);    
relmets = logical(zeros(size(model.S,1),1));
if isempty(compFlag)
    compFlag = uniqueCompartments;
end

%Extends the metNames
for i = 1:numel(uniqueCompartments)
    relmets = relmets | ismember(model.mets,strcat(metNames,['[',uniqueCompartments{i},']']));
end

transportRxnBool = logical(zeros(size(model.S,2),1));

for n=1:size(model.S,2)
    %we only look at the compartments of relevant reactions. And whether
    %they are part of the requested compartments
    relCompartments=unique(compartments(model.S(relmets,n)~=0));
    if (length(relCompartments) > 1) && any(ismember(relCompartments,compFlag))
        transportRxnBool(n,1)=true;
    end
end


TrspRxns = model.rxns(transportRxnBool);