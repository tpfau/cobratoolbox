function updateLocalBRENDAData(updatedData, field, folderName)
% Update the local BRENDA data
% USAGE:
%    [brendaInfo] = updateLocalBRENDAData(updatedData, folderName)
%
% INPUT:
%    updatedData:       The updated data for the database.
%    field:             The field that will be updated with the data.
% 
% OPTIONAL INPUT:
%    folderName:        The folder the data is stored in (default Folder
%                       'CBT_ROOT/databases/BRENDA')

if exist('folderName','var')
    brendaData = loadBRENDAData(folderName);
    brendaData = updateBRENDAData(brendaData,updatedData,field);
    writeBRENDAInfo(brendaData, folderName);
else
    brendaData = loadBRENDAInfo();
    brendaData = updateBRENDAInfo(brendaData,updatedData,field);
    writeBRENDAInfo(brendaData);
end
