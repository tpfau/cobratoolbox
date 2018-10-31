function writeBRENDAInfo(brendaInfo, folderName)
% write the local BRENDA info
% USAGE:
%    writeBRENDAInfo(brendaInfo, folderName)
%
% INPUT:
%    brendaInfo:       The data to write
% 
% OPTIONAL INPUT:
%    folderName:        The folder the informatio is stored in (fileName
%                       BRENDAInfo.mat) (default Folder
%                       'CBT_ROOT/databases/BRENDA')

if ~exist('folderName','var')    
    folderName = getBRENDADefaultFolder();
end
if ~exist(folderName,'file')
    mkdir(folderName);
end
% save the data
save([folderName filesep 'BRENDAReg.mat'],'brendaInfo');

end