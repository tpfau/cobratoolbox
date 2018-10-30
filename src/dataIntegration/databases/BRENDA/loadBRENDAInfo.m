function [brendaInfo] = loadBRENDAInfo(folderName)
% Load the info file for BRENDA
% USAGE:
%    [brendaInfo] = loadBRENDAInfo(folderName)
%
% OPTIONAL INPUT:
%    folderName:        The folder the informatio is stored in (fileName
%                       BRENDAInfo.mat) (default Folder
%                       'CBT_ROOT/databases/BRENDA')
%
% NOTE: 
%    States of the info are:
%    0 : Checked, and does not exist
%    1 : Not checked, not downloaded    
%    2 : Checked, and does exist;
%    3 : Exists and Downloaded

persistent db
persistent lastMod

if ~exist('folderName','var')
   CBT_Folder = fileparts(which('initCobraToolbox.m'));
    % define the default FolderName
    folderName = [CBT_Folder filesep 'databases' filesep 'BRENDA'];
end

% initialize the availability struct (indicating what has aready been
% downloaded
if exist([folderName filesep 'BRENDAReg.mat'],'file')
    dbProps = dir([folderName filesep 'BRENDAReg.mat']);
    if isempty(lastMod)
        lastMod = dbProps.datenum;    
    end
    if lastMod < dbProps.datenum
        load([folderName filesep 'BRENDAReg.mat'],'brendaInfo');
        db = brendaInfo;
    else
        if isempty(db)
            load([folderName filesep 'BRENDAReg.mat'],'brendaInfo');
            db = brendaInfo;
        end
        brendaInfo = db;
    end
else
    % This is empty, so we just give a new struct.
    brendaInfo = struct('ECNumber','1.1.1.1','KM',0,'MW',0,'PATH',0,...
                             'SA',0,'KCAT',0);
    db = brendaInfo
end
end

