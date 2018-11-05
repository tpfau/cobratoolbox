function [brendaData] = loadBRENDAData(varargin)
% Load the info file for BRENDA
% USAGE:
%    [brendaData] = loadBRENDAInfo(folderName)
%
% OPTIONAL INPUT:
%    varargin:          Variable arguments as parameter/value pairs or
%                       parameter struct
%                        * `folderName` - The folder BRENDA is stored in (default: 'CBT_ROOT/databases/BRENDA')
%                        * `ECNumbers` - the ECNumbers to retrieve, (default: all)
%                        * `fields` - The field names to retrieve data for (default: all)
%                        
%                        
% OUTPUT: 
%    brendaDATA:        A Struct containing the local BRENDA data.
%
% NOTE: 
%    loading the data will look up the individual elements in the 

persistent db 
persistent lastMod % 

defaultfields = getBRENDAFields();

parser = inputParser();
parser.addParameter('folderName',getBRENDADefaultFolder(),@ischar);
parser.addParameter('ECNumbers','all',@(x) ischar(x) || iscell(x));
parser.addParameter('fields',defaultfields,@(x) ischar(x) || iscell(x));

parser.parse(varargin{:});

ECNumbers = parser.Results.ECNumbers;
if ischar(ECNumbers)
    ECNumbers = {ECNumbers};
end
fields = parser.Results.fields;
if ischar(fields)
    fields = {fields};
end

folderName = parser.Results.folderName;
for i = 1:numel(ECNumbers)
    if exist([folderName filesep ECNumbers{i} '.mat'],'file')        
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
        brendaData = struct('ECNumber',{},'KM',struct(),...
                                 'MW',struct(),'PATH',struct(),...
                                 'SA',struct(),'KCAT',struct(), 'SEQ',struct());
        db = brendaData
    end
end
end