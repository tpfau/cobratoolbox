function [brendaData] = loadBRENDAData(varargin)
% Load Data from BRENDA (download if necessary)
% USAGE:
%    [brendaData] = loadBRENDAData(varargin)
%
% OPTIONAL INPUT:
%    varargin:          Variable arguments as parameter/value pairs or
%                       parameter struct
%                        * `folderName` - The folder BRENDA is stored in (default: 'CBT_ROOT/databases/BRENDA')
%                        * `ECNumbers` - the ECNumbers to retrieve, (default: all)
%                        * `fields` - The field names to retrieve data for (default: all)
%                        * `downloadMissing` - Download missing data (default: true)
%                        * `updateDataOlderThan` - Update data that is older than the given number of days. A Negative number indicates not to update at all. (default: -1)
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
% NOTE: 
%    loading the data will look up the individual elements online

persistent db 
persistent lastMod  

if isempty(lastMod)    
    lastMod = containers.Map;
end

defaultfields = getBRENDAFields();

parser = inputParser();
parser.addParameter('folderName',getBRENDADefaultFolder(),@ischar);
parser.addParameter('ECNumbers','all',@(x) ischar(x) || iscell(x));
parser.addParameter('fields',defaultfields,@(x) ischar(x) || iscell(x));
parser.addParameter('downloadMissing',true,@(x) isnumeric(x) && (x == 1 || x == 0) || islogical(x));
parser.addParameter('updateDataOlderThan',-1,@isnumeric)
parser.parse(varargin{:});

% init the parameters
downloadMissing = parser.Results.downloadMissing;
updateDataOlderThan = parser.Results.updateDataOlderThan;
ECNumbers = parser.Results.ECNumbers;
folderName = parser.Results.folderName;
brendaInfo = loadBRENDAInfo(folderName);
if isempty(db)
    % we initialize a struct with all potential EC Numbers.
    db = getBRENDADefaultDataStruct({brendaInfo.ECNumber});    
end

if ischar(ECNumbers)
    if strcmp(ECNumbers,'all')
        ECNumbers = unique({brendaInfo.ECNumber});
    else
        ECNumbers = {ECNumbers};
    end
end

fields = parser.Results.fields;
if ischar(fields)
    fields = {fields};
end

% get the current system time
ctime = now;

for i = 1:numel(ECNumbers)
    ecfile = [folderName filesep ECNumbers{i} '.mat'];
    if ~exist(ecfile,'file') 
        % lets download missing info (if it is possible)
        retrieveBRENDAData('folderName',folderName,'fields',fields,'ECNumbers',{ECNumbers{i}});        
    end 
    if exist(ecfile,'file')          
        dbProps = dir(ecfile);
        % first, check whether the data needs to be updated (e.g. missing
        % fields
        infoPos = ismember({brendaInfo.ECNumber},ECNumbers{i});        
        fieldsToUpdate = false(numel(fields),1);
        for f = 1:numel(fields)
            cfield = fields{f};
            if (updateDataOlderThan >= 0 && ctime-dbProps.datenum < updateDataOlderThan * 24*3600) || ...
                    brendaInfo(infoPos).(cfield) == 0 || brendaInfo(infoPos).(cfield) == 2 % not known, or not downloaded
                fieldsToUpdate(f) = true;
            end
        end
        if any(fieldsToUpdate)
            retrieveBRENDAData('ECNumbers',{ECNumbers{i}},'fields',fields(fieldsToUpdate),'folderName',folderName);
        end
        if ~lastMod.isKey(ECNumbers{i})
            % hasn't been checked yet, so we update our struct.
            lastMod(ECNumbers{i}) = 0;            
        end                        
        if lastMod(ECNumbers{i}) < dbProps.datenum
            % We don't have the latest data loaded yet, so lets do it now.
            ecpos = ismember({db.ECNumber},ECNumbers{i});
            data = load(ecfile,'brendaData');            
            if any(ecpos)                
                db(ecpos) = data.brendaData;
            else
                db(end+1) = data.brendaData;
            end
            lastMod(ECNumbers{i}) = dbProps.datenum;
        end
    else
        % the file does not exist and was not downloaded. So the info is
        % empty.
        ecpos = ismember({db.ECNumber},ECNumbers{i});
        if isempty(ecpos)
            %otherwise it already exists.
            db(end+1) = getBRENDADefaultDataStruct({ECNumbers{i}});    
        end
    end
end
posToRetrieve = ismember({db.ECNumber},ECNumbers);
brendaData = db(posToRetrieve);
end