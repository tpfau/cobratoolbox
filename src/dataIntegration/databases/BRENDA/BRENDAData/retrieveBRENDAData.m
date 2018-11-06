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
%     * Sequence (SEQ)
%    either the full names, or the abbreviations are allowed.
%    The database will be stored in the given database folder with one
%    mat file per EC Number.

persistent bclient;
persistent lastStart;
persistent lastField;

defaultFields = getBRENDAFields();

% define the default FolderName
defaultfolderName = getBRENDADefaultFolder();
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

fields = getBRENDAFields(parser.Results.fields);

% initialize the availability struct (indicating what has aready been
% downloaded

BRENDAInfo = loadBRENDAInfo(folderName);

% determine the ECs to download.
ECsToDo = parser.Results.ECNumbers;
if ischar(ECsToDo)
    if strcmp(ECsToDo,'all')
        ECsToDo = {BRENDAInfo.ECNumber};
    else
        ECsToDo = {ECsToDo};
    end
end

[pres,pos] = ismember(ECsToDo,{BRENDAInfo.ECNumber});

continueInterrupted = parser.Results.continueInterrupted;
brendaData = getBRENDADefaultDataStruct(ECsToDo);
if ~continueInterrupted || isempty(lastStart)
    lastStart = 1;    
    lastField = 1;
end
% when finishing set the lastStart/lastField values.
bclient = startBRENDAClient();

% go through all EC Numbers
for lastField = lastField:numel(fields)
    cField = fields{lastField};
    for lastStart = lastStart:numel(ECsToDo)
        cEC = ECsToDo{lastStart};
        if ~pres(lastStart)
            warning('No data available for %s on BRENDA. Make sure that the EC numbers ae full EC numbers (X.X.X.X).',ECsToDo{lastStart});
        else
            status = BRENDAInfo(pos(lastStart)).(cField);
            if status == 0 || status == 2
                %its not proven to not exist, or its available but not
                %downloaded                
                switch cField
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
                if isempty(data)
                    % was not available. save this info.
                    BRENDAInfo(pos(lastStart)).(cField) = 1;
                else
                    % we got some data. lets add it.
                    defaultStruct = getBRENDADefaultData(cField);
                    %update the length                    
                    structFields = fieldnames(defaultStruct);
                    defaultStruct(numel(data)).(structFields{1}) = data(numel(data)).(structFields{1});
                    for i = 1:numel(structFields)
                        cStructField = structFields{i};
                        if isfield(data,cStructField)
                            [defaultStruct.(cStructField)] = deal(data.(cStructField));
                        end
                    end
                    brendaData(lastStart).(cField) = defaultStruct;
                    updateLocalBRENDAData(brendaData(lastStart),folderName);
                    BRENDAInfo(pos(lastStart)).(cField) = 3;
                end
                %update the finishUp function.
                finishup = onCleanup(@() updateLocalBRENDAInfo(BRENDAInfo,folderName));
            end
        end
                
    end
    % reset lastStart
    lastStart = 1;
end
% reset lastStart
lastStart = 1;
% reset lastField
lastField = 1;
end



