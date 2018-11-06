function [brendaData] = loadLocalBRENDAData(ECNumbers, folderName)
% Load the locally stored data from BRENDA for the given EC Number.
% USAGE:
%    [brendaData] = loadLocalBRENDAData(ECNumber, folderName)
%
% INPUT:
%    ECNumbers:      The EC Number(s) to load the local data for.
%
% OPTIONAL INPUT:
%    folderName:    The folder BRENDA is stored in (default: 'CBT_ROOT/databases/BRENDA')
%                        
%
% OUTPUT: 
%    brendaData:        A struct with BRENDA data. The struct has the
%                       following fields:
%                        * 'ECNumber' - EC Number
%                        * 'KM' - struct with KM Value data
%                        * 'MW' - struct with  Molecular Weight data
%                        * 'PATH' - struct with Pathway data
%                        * 'SA' - struct with  Specific Activity data
%                        * 'KCAT' - struct with Turnover number data
%                        * 'SEQ' - struct with Sequence data
%

if ischar(ECNumbers)
    ECNumbers = {ECNumbers};
end

if ~exist('folderName', 'var')
    folderName = getBRENDADefaultFolder();
end

brendaData = getBRENDADefaultDataStruct(ECNumbers);

for i = 1:numel(ECNumbers)
    ecfile = [folderName filesep ECNumbers{i} '.mat'];
    if exist(ecfile,'file') 
       data = load(ecfile);
       brendaData(i) = data.brendaData;
    end
end
