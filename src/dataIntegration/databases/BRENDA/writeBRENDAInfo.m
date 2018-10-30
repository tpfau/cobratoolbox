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
    CBT_Folder = fileparts(which('initCobraToolbox.m'));
    % define the default FolderName
    folderName = [CBT_Folder filesep 'databases' filesep 'BRENDA'];    
end
if ~exist(folderName,'file')
    mkdir(folderName);
end
% save the data
save([folderName filesep 'BRENDAReg.mat'],'brendaInfo');

end