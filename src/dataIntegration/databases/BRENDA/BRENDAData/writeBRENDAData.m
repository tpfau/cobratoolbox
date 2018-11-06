function writeBRENDAData(brendaData, folderName)
% write the local BRENDA data
% USAGE:
%    writeBRENDAData(brendaData, folderName)
%
% INPUT:
%    brendaData:       The data to write
% 
% OPTIONAL INPUT:
%    folderName:        The folder the data is stored in (fileName
%                       BRENDAInfo.mat) (default Folder
%                       'CBT_ROOT/databases/BRENDA')

if ~exist('folderName','var')    
    folderName = getBRENDADefaultFolder();
end
if ~exist(folderName,'file')
    mkdir(folderName);
end
fullData = brendaData;
% save the data
for i = 1:numel(fullData)
    brendaData = fullData(i);
    save([folderName filesep brendaData.ECNumber '.mat'],'brendaData');
end

end