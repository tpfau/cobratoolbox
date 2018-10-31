function [brendaInfo] = updateLocalBRENDAInfo(updatedData, folderName)
% Update the local BRENDA info
% USAGE:
%    [brendaInfo] = updateLocalBRENDAInfo(updatedData, folderName)
%
% INPUT:
%    updatedData:       The updated data for the database.
% 
% OPTIONAL INPUT:
%    folderName:        The folder the informatio is stored in (fileName
%                       BRENDAInfo.mat) (default Folder
%                       'CBT_ROOT/databases/BRENDA')

if exist('folderName','var')
    brendaInfo = loadBRENDAInfo(folderName);
    brendaInfo = updateBRENDAInfo(brendaInfo,updatedData);
    writeBRENDAInfo(brendaInfo, folderName);
else
    brendaInfo = loadBRENDAInfo();
    brendaInfo = updateBRENDAInfo(brendaInfo,updatedData);
    writeBRENDAInfo(brendaInfo);
end

end

