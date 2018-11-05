function fields = getBRENDAFields(fields)
% Get the available field names for BRENDS or a translation of given field
% names to those used in the local BRENDA data.
% USAGE:
%    fields = getBRENDAFields(fields)
%
% OPTIONAL INPUT:
%    fields:        The fields (either IDs or Descriptions) to use
%
% OUTPUT:
%    fields:        The translated fields
%
% NOTE:
%    Allowed field IDs for BRENDA are: 
%    {'KM','MW','PATH','SA','KCAT','SEQ'}
%    With the corresponding descriptions:
%    {'KM Value', 'Molecular Weight','Pathways','Specific Activity','Turnover Number','Sequence'};

defaultFields = {'KM','MW','PATH','SA','KCAT','SEQ'};
fieldDescriptiveNames = {'KM Value', 'Molecular Weight','Pathways','Specific Activity','Turnover Number','Sequence'};

if ~exist('fields','var')
    % get the default fields.
    fields = defaultFields;
    return;
else
    if ischar(fields)
        fields = {fields};
    end
    descriptive = ismember(fieldDescriptiveNames,fields);
    % filter only possible fields.
    fields = intersect(defaultFields,union(defaultFields(descriptive),fields));   
end


end

