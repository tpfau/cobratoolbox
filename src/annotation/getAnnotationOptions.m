function [ res ] = getAnnotationOptions( varargin )
%GETANNOTATIONOPTIONS  returns the list of fields that can be annotated.
% INPUT
%   
% OPTIONAL INPUT
%
%   varargin       Option/Value fields. containing:
%       'fieldDescription'      Request the model field name for a given
%                               description (Type char)
%       'returnFieldNames'      Request the field Names available for
%                               annotation(type logic)
%       'returnOptions'         Request the Options (Descriptions) of the
%                               model field which can be annotated (type
%                               logic)
%
% OUTPUT 
%   result          a struct containing the requested fields. 
%                   modelFieldName -> if fieldDescription is provided, this field will
%                   contain the corresponding model field name.
%                   fieldNames -> if returnFieldNames is true, this field
%                   will contain the model field names.
%                   fieldOptions -> if returnOptions is true, this field
%                   will contain Descriptions for the different model field
%                   names.
%   Detailed explanation goes here
geneField = 'genes';
reactionField = 'rxns';
metField = 'mets';
geneDescription = 'Gene';
reactionDescription = 'Reaction';
metaboliteDescription = 'Metabolite';

ModelFields = {geneField,reactionField,metField}; % Later addition could e.g. be 'proteins'
ModelFieldDescriptions = {geneDescription,reactionDescription,metaboliteDescription};

p = inputParser;
p.CaseSensitive = false;
 addParameter(p,'fieldDescription','',@ischar);
 addParameter(p,'returnFieldNames',0,@(x) isnumeric(x) | islogical(x));
 addParameter(p,'returnOptions',0,@(x) isnumeric(x) | islogical(x)); 
 
parse(p,varargin{:});
res = struct();
if ~isempty(p.Results.fieldDescription)
    res.modelFieldName = [ModelFields{ismember(ModelFields,p.Results.fieldDescription) |...
        strcmpi(ModelFieldDescriptions,p.Results.fieldDescription)}];
end
if p.Results.returnFieldNames
    res.fieldNames = ModelFields;    
end
if p.Results.returnOptions
    res.fieldOptions = ModelFieldDescriptions;
end

end


