function [brendaData] = loadBRENDAData(folderName)
% Load the info file for BRENDA
% USAGE:
%    [brendaData] = loadBRENDAInfo(folderName)
%
% OPTIONAL INPUT:
%    folderName:        The folder the informatio is stored in (fileName
%                       BRENDAInfo.mat) (default Folder
%                       'CBT_ROOT/databases/BRENDA')
%
% OUTPUT: 
%    brendaDATA:        A Struct containing the local BRENDA data.
%

persistent db
persistent lastMod

if ~exist('folderName','var')
   CBT_Folder = fileparts(which('initCobraToolbox.m'));
    % define the default FolderName
    folderName = [CBT_Folder filesep 'databases' filesep 'BRENDA'];
end

% initialize the availability struct (indicating what has aready been
% downloaded
if exist([folderName filesep 'BRENDAData.mat'],'file')
    dbProps = dir([folderName filesep 'BRENDAData.mat']);
    if isempty(lastMod)
        lastMod = dbProps.datenum;    
    end
    if lastMod < dbProps.datenum
        load([folderName filesep 'BRENDAData.mat'],'brendaData');
        db = brendaData;
    else
        if isempty(db)
            load([folderName filesep 'BRENDAData.mat'],'brendaData');
            db = brendaData;
        end
        brendaData = db;
    end
else
    % This is empty, so we just give a new struct.
    brendaData = struct('ECNumber','1.1.1.1','KM',struct(),...
                             'MW',struct(),'PATH',struct(),...
                             'SA',struct(),'KCAT',struct());
    db = brendaData
end
end