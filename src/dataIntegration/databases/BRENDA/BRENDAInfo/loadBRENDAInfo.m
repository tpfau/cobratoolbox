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
%    0 : Not checked, not downloaded    
%    1 : Checked, and does not exist
%    2 : Checked, and does exist;
%    3 : Exists and Downloaded

persistent db
persistent lastMod

if ~exist('folderName','var')   
    folderName = getBRENDADefaultFolder();
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
    db = initBRENDAInfo();
    writeBRENDAInfo(db,folderName);
    brendaInfo = db;
end
end

