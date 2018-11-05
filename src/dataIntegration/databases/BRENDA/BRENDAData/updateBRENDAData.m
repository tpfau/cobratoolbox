function brendaData = updateBRENDAData(brendaData, updateData, field)
% Update the BRENDA Info struct.
% USAGE: 
%    updatedInfo = updateBRENDAInfo(brendaInfo,updateData)
%
% INPUTS:
%    brendaInfo:        A Struct with the BRENDAData fields (see
%                       loadBrendaInfo)
%    updateData:        A struct with data obtained for the given field.
%    field:             The field that will be overwritten with the
%                       updated data.
% OUTPUT:
%    updatedInfo:       The updated data struct
brendaData.(field) = updateData;
end

