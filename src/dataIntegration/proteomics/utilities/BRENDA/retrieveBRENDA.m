function retrieveBRENDA(folderName)


CBT_Folder = fileparts(which('initCobraToolbox.m'));

if ~exist('folderName','var')
    folderName = [CBT_Folder filesep 'Databases' filesep 'BRENDA'];
end

if ~exist(folderName,'file')
    mkdir(folderName)
end

bclient = BrendaClient();

fields = {'KM','MW','PATH','SA','KCAT'}

