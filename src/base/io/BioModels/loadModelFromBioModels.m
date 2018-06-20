function varargout = loadModelFromBioModels( model_ids, multichoice)
% Reads models from Biomodels
%
% USAGE:
%
%    model = listBiGGModel(model_ids)
%
% OPTIONAL INPUTS:
%
%    model_ids:     The Biomodel ID(s) of the model(s). If no ID is provided (either empty or no arguments) a gui
%                   will ask for the model to load. If IDs are provided,
%                   they have to both have an SBML format and be marked as constraint
%                   based models.
%    multichoice:   Whether multiple models can be loaded if no ids are
%                   given. (Default: true)
% OUTPUT:
%    varargout:     The models in the order of the selected ids. If
%                   multiple models are selected in the dialog, a struct
%                   is provided with the models being fields of that
%                   struct.
%                   
% EXAMPLES:
%
% .. Authors:
%       - Thomas Pfau Sep 2017 

bioModelFolderName = tempname;
mkdir(bioModelFolderName);
finishup = onCleanup(@() rmdir(bioModelFolderName,'s'));

if ~exist('multichoice','var')
    multichoice = true;
end
if multichoice
    selectionMode = 'multichoice';
else
    selectionMode = 'single';
end

%Do not create a struct for multiple ids
structout = false;

modelfiles = {};

modelOptions = getBioModelsQuery('*:* AND modellingapproach:"Constraint-based model"');
%modelOptions = webread('https://wwwdev.ebi.ac.uk/biomodels/search?query=*:* AND modellingapproach:"Constraint-based model"');
modelOptions = modelOptions.models;
modelIDs = {modelOptions.id};
modelNames = {modelOptions.name};

if nargin == 0 || isempty(model_ids)
    orgNames = cellfun(@(x,y) strcat(x,' (',y,')'), modelNames, modelIDs, 'UniformOutput',0)' ;
    [sortedNames, order] = sort(orgNames);
    maxNameSize = max(cellfun(@numel,orgNames));
    
    if usejava('desktop')
        [s,v] = listdlg('Name','Model Selection','PromptString','Select Model(s) to download','SelectionMode',selectionMode, ...
                    'OKString','Load', 'ListString', sortedNames, 'ListSize', [maxNameSize*7,160] );
    else
        for i = 1:numel(sortedNames)
            fprintf('%i: %s\n',i,sortedNames{i});
        end
        s = input(['Please select a model (e.g. type 3 for ' sortedNames{3} '):'],'s');        
        s = str2num(s);
    end
   
    model_ids = modelIDs(order(s)); 
    if numel(model_ids) > 1
        structout = true;
    end
else
    if ~iscell(model_ids)
        model_ids = {model_ids};
    end
    
    present = ismember(model_ids,modelIDs);
    if any(~present)
        nonpresent = model_ids(~present);
        model_ids = model_ids(present);
        result = getBioModelsQuery(strjoin(nonpresent, ' OR '));
        presentids = {result.models.id};
        if ~isempty(setdiff(nonpresent,presentids))
            fprintf('Could not find the following model ids in BioModels:\n');
            fprintf('%s\n',strjoin(setdiff(nonpresent,presentids),'\n'));
            
        end
        if ~isempty(presentids)
            fprintf('The following models exist in Boimass but are either not\n constraint based models or are not available as SBML :\n');
            fprintf('%s\n',strjoin(presentids,'\n'));            
        end
    end
end

%If nothing is selected return nothing.
if numel(model_ids) == 0
       warning('No model selected.')
       varargout = {};
       return 
end

varargout = cell(numel(model_ids),1);
for i = 1:numel(model_ids)
    filename = [bioModelFolderName filesep model_ids{i} '.' format];
    url = ['http://bigg.ucsd.edu/static/models/' model_ids{i} '.' format];
    websave(filename,url);
    varargout{i} = readCbModel(filename);
end

if structout
    outstruct = struct();
    for i = 1:numel(model_ids)
        fieldID = regexprep(model_ids{i},'[^a-zA-Z0-9_]','');
        if isempty(regexp(fieldID,'^[a-zA-Z]'))
            fieldID = ['M_' fieldID];
        end
        outstruct.(fieldID) = varargout{i};
    end
    varargout = {outstruct};
end
