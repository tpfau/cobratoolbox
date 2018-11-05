function folderName = getBRENDADefaultFolder()
% get the Default FolderName for the BRENDA Database
% USAGE:
%    folderName = getBRENDADefaultFolder()
%
% OUTPUT:
%    folderName:        The Foldername BRENDA data is normally stored to.

CBT_Folder = fileparts(which('initCobraToolbox.m'));
% define the default FolderName
folderName = [CBT_Folder filesep 'databases' filesep 'BRENDA'];

end

