function clearBRENDAPersistent(clearClient)
% This function clears all persistent variables from all BRENDA Database
% functions. The only exception is the BrendaClient.
% 
% USAGE:
%    clearBRENDAPersistent(clearClient)
% 
% OPTIONAL INPUT:
%    clearClient:       Also clear the BRENDA client (new login required)

datafolder = [fileparts(which(mfilename)) filesep 'BRENDAData'];
infofolder = [fileparts(which(mfilename)) filesep 'BRENDAInfo'];

datafiles = dir(datafolder);
infofiles = dir(infofolder);

% clear all data files
for i = 1:numel(datafiles)
    if ~isempty(regexp(datafiles(i).name, '.*\.m$','ONCE'))
        clear(regexprep(datafiles(i).name,'\.m$',''))
    end
end

% clear all info files
for i = 1:numel(infofiles)
    if ~isempty(regexp(infofiles(i).name, '.*\.m$','ONCE'))
        clear(regexprep(infofiles(i).name,'\.m$',''))
    end
end
% clear the client if requested
if exist('clearClient','var') && clearClient
    clear('startBRENDAClient.m');
end

end

