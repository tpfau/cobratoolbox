function components = parseComponents(inputStruct)
% Parse the compomnents of a UniProt input data into a struct
%
% USAGE:
%    components = parseComponents(inputStruct)
%
% INPUTS:
%    inputStruct:       The input Structure as returned by a call to webread('https://www.ebi.ac.uk/proteins/api/proteins','offset',offset,'size',100,'organism',organismName)
%    
% OUTPUT:
%    components:        A struct array with a name and short field for each
%                       component in the input struct

components = struct('name', '', 'short', '');
if isfield(inputStruct.protein,'component')
    componentData = inputStruct.protein.component;
    if ~iscell(componentData)
        componentData = mat2cell(componentData,ones(numel(componentData),1),1);
    end
    components = cellfun(@parseData, componentData);
end
end

function compStruct = parseData(componentStruct)
% Parse the compomnents of a component struct in UniProt input data into a struct
%
% USAGE:
%    components = parseComponents(inputStruct)
%
% INPUTS:
%    inputStruct:       A uniprot.protein.component struct
%    
% OUTPUT:
%    components:        A struct with a name and short field for each
%                       component in the input struct
compStruct = struct('name', '', 'short', '');
compStruct.name = char(componentStruct.recommendedName.fullName.value);
if isfield(componentStruct.recommendedName,'shortName')
    compStruct.short = char(componentStruct.recommendedName.shortName.value);
end
end