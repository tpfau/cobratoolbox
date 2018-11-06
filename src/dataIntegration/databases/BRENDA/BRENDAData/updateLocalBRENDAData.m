function updateLocalBRENDAData(updatedData, folderName)
% Update the local BRENDA data
% USAGE:
%    [brendaInfo] = updateLocalBRENDAData(updatedData, folderName)
%
% INPUT:
%    updatedData:       The updated data for the database.
%    field:             The field that will be updated with the data.
% OPTIONAL INPUT:
%    folderName:        The folder the data is stored in (default Folder
%                       'CBT_ROOT/databases/BRENDA')

if ~exist('folderName','var')
    folderName = getBRENDADefaultFolder();
end

ECNumber = updatedData.ECNumber;

brendaData = loadLocalBRENDAData(ECNumber,folderName);
fields = fieldnames(updatedData);
for i = 1:numel(fields)
    cfield = fields{i};
    % the field should not be empty AND it should have more fields AND we
    % want to ignore the ECNumber field.
    if isstruct(updatedData.(cfield)) && ~isempty(updatedData.(cfield)) && ~isempty(fieldnames(updatedData.(cfield)))
        brendaData = updateBRENDAData(brendaData,updatedData.(cfield),cfield);
    end
end
writeBRENDAData(brendaData, folderName);

