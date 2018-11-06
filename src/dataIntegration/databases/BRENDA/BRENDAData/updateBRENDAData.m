function brendaData = updateBRENDAData(brendaData, updateData, field)
% Update the BRENDA Data struct for a single field of a single EC Number.
% USAGE: 
%    brendaData = updateBRENDAData(brendaData, updateData, field)
%
% INPUTS:
%    brendaData:        A Struct with the BRENDAData fields (see
%                       loadBrendaInfo)
%    updateData:        A struct with data obtained for the given field.
%    field:             The field that will be overwritten with the
%                       updated data.
% OUTPUT:
%    brendaData:        The updated data struct

brendaData.(field) = updateData;
end

