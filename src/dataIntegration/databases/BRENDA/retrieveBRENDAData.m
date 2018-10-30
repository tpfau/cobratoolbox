function retrieveBRENDAData(varargin)
% Download the Brenda Enzyme information to a given Folder.
% USAGE:
%    retrieveData(folderName)
%
% OPTIONAL INPUT:
%    varargin:          Additional Options as parameter/value pairs or
%                       parameter struct
%                        * folderName - The Folder to store the brenda data to (default CBT_ROOT/databases/BRENDA).
%                        * ECNumbers - The EC Number to obtain Data for (default: 'all')
%                        * fields - The fields to retrieve (default: {'KM','MW','PATH','SA','KCAT'});
%                        * continueInterrupted - whether this is the continuation of a previously interrupted (error or user Interrupt) call (default false).
%
%
% NOTE:
%    The retrieved fields can contain:
%     * 'KM Value' (KM)
%     * Molecular Weight (MW)
%     * Pathways (PATH)
%     * Specific Activity (SA)
%     * Turnover Number (KCAT)
%    either the full names, or the abbreviations are allowed.


persistent bclient;
persistent lastStart;
persistent lastField;

CBT_Folder = fileparts(which('initCobraToolbox.m'));
% define the default FolderName
defaultfolderName = [CBT_Folder filesep 'databases' filesep 'BRENDA'];
defaultFields = {'KM','MW','PATH','SA','KCAT';'KM Value', 'Molecular Weight','Pathways','Specific Activity','Turnover Number'};
parser = inputParser();
parser.addParameter('folderName',defaultfolderName,@ischar)
parser.addParameter('ECNumbers','all' ,@(x) ischar(x) || iscell(x))
parser.addParameter('fields',defaultFields(1,:),@(x) ischar(x) || iscell(x));
parser.addParameter('continueInterrupted', false, @(x) islogical(x) || isnumeric(x) && (x ==1 || x == 0));
parser.parse(varargin{:});

%create the Database folder if it does not exist
folderName = parser.Results.folderName;
if ~exist(folderName,'file')
    mkdir(folderName)
end

fields = parser.Results.fields;
if any(ismember(fields,defaultFields(2,:)))
    todo = defaultFields(1,ismember(defaultFields(2,:),fields));
    fields = intersect(union(todo,fields),defaultFields(1,:));
end

% initialize the availability struct (indicating what has aready been
% downloaded

% determine the ECs to download.
ECsToDo = parser.Results.ECNumbers;
continueInterrupted = parser.Results.continueInterrupted;

if continueInterrupted
    [lastStart,lastField] = setAndGetStart(start,field);
else
    lastStart = 1;
    lastField = 1;
end
% when finishing set the lastStart/lastField values.
if isempty(bclient)
    bclient = BrendaClient();
end

if strcmp(ECsToDo,'all')
    for i = 1:numel(fields)
        getBrendaECNumbersForType(fields{i},folderName);
    end
    brendaInfo = loadBRENDAInfo;
    ECs = {brendaInfo.ECNumber};
end
brendaInfo = loadBRENDAInfo(folderName);
brendaData = loadBRENDAData(folderName);
% unknown
unprocessed = setdiff(ECs, {brendaInfo.ECNumber});
existing = intersect(ECs, {brendaInfo.ECNumber});
% go through all unprocessed values
for lastField = 1:numel(fields)
    cInfo = buildBRENDAInfo(unprocessed,fields{lastField},2);
    for i = 1:numel(unprocessed)
        cEC = unprocessed{i};
        switch fields{lastField}
            case 'KM'
                data = bclient.getKmValue('ecNumber', cEC);
            case 'MW'
                data = bclient.getMolecularWeight('ecNumber', cEC);
            case 'PATH'
                data = bclient.getPathway('ecNumber',cEC);
            case 'SEQ'
                data = bclient.getSequence('ecNumber', cEC);
            case 'SA'
                data = bclient.getSpecificActivity('ecNumber', cEC);
            case 'KCAT'
                data = bclient.getTurnoverNumber('ecNumber', cEC);
        end
        defaultStruct = getBRENDADEfaultData(fields{lastField});
        if ~isempty(data)
            emptyFields = setdiff(fieldnames(defaultStruct),fieldnames(data));
            for f = 1:numel(emptyFields)
                [data.(emptyFields{f})] = deal('');
            end
            cInfo(lastStart).(fields{lastField}) = 3;
        else
            data = defaultStruct;
            cInfo(lastStart).(fields{lastField}) = 1;
        end                
    end
    for lastStart = lastStart:numel(ECs)
        data = struct();
        cEC = ECs{lastStart};
        switch fields{lastField}
            case 'KM'
                data = bclient.getKmValue('ecNumber', ECs{lastStart});
            case 'MW'
                data = bclient.getMolecularWeight('ecNumber', ECs{lastStart});
            case 'PATH'
                data = bclient.getPathway('ecNumber', ECs{lastStart});
            case 'SEQ'
                data = bclient.getSequence('ecNumber', ECs{lastStart});
            case 'SA'
                data = bclient.getSpecificActivity('ecNumber', ECs{lastStart});
            case 'KCAT'
                data = bclient.getTurnoverNumber('ecNumber', ECs{lastStart});
        end
    end
    
end
% reset lastStart
lastStart = 1;

end


function [cStart,cField] = setAndGetStart(start,field)
% get start and field positions for restart

persistent lastStart
persistent lastField
if isempty(lastStart)
    lastStart = 1;
    lastField = 1;
end
if exist('start','var')
    lastStart = start;
end
if exist('field','var')
    lastField = field;
end
cStart = lastStart;
cField = lastField;
end



