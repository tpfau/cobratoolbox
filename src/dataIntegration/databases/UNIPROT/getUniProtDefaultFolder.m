function folderName = getUniProtDefaultFolder()
% get the Default FolderName for the UniProt Database
% USAGE:
%    folderName = getUniProtDefaultFolder()
%
% OUTPUT:
%    folderName:        The Foldername UniProt data is normally stored to.

CBT_Folder = fileparts(which('initCobraToolbox.m'));
% define the default FolderName
folderName = [CBT_Folder filesep 'databases' filesep 'UNIPROT'];

end

