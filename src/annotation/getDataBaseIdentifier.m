function [ database, pattern ] = getDataBase(databaseid, registry, varargin )
%GETDATABASE get the database ID provided by the registry.
% INPUT
%   databaseid          the ID of the database
%   registry            'http://identifiers.org' or the base for an url
% OPTIONAL
%   varargin            Property/Value pairs:
%                       'annotatedField', the model field to annotate. Must
%                       be one of the fields provided by
%                       getAnnotationOptions (e.g. 'gene'). If provided,
%                       some databases will be treated specially (e.g.
%                       kegg, and the selection of the appropriate kegg db
%                       will happen automatically).
% OUTPUT
% database              The databaseid for the requested database in the
%                       registry
% pattern               a regular expression pattern an identifier should
%                       match (if not using identifiers.org, this will be
%                       .*)


global UPDATE_ANNOTATION_TESTING
global UPDATE_ANNOTATION_GET_DATABASE_INPUT
global GET_DATABASEID_TESTING
global GET_DATABASEID_TESTING_POSITIONINPUT
global GET_DATABASEID_TESTING_LABELINPUT

%If there is no information in the database, its ID is empty.
if isempty(databaseid)
    database = '';
    pattern = '';
    return
end

specialDataBases = {'kegg','metanetx'};




annotOptionsStruct = getAnnotationOptions( 'returnFieldNames', 1,'returnOptions',1);
AnnotOptions = [annotOptionsStruct.fieldNames, annotOptionsStruct.fieldOptions];

p = inputParser;
addRequired(p,'databaseid',@ischar)
addRequired(p,'registry',@ischar)
addParameter(p,'annotatedField','',@(x) any(strcmpi(AnnotOptions,x)));

parse(p,databaseid,registry,varargin{:});

databaseid = p.Results.databaseid;
registry = p.Results.registry;
annotatedField = p.Results.annotatedField;

if ~isempty(annotatedField) && strcmpi(registry,getRegistryURL())
    special = find(strcmpi(specialDataBases, databaseid));
    if ~isempty(special)
        maps = getSpecialMaps();  
        currentmap = maps{special};
        annotedFieldStruct = getAnnotationOptions('fieldDescription',annotatedField);        
        databaseid = currentmap(annotedFieldStruct.modelFieldName);
    end    
end

%Now, get the matching databases from identifiers.org if that is the
%Registry
if strcmpi(registry,getRegistryURL())
    try
        options = webread([getRegistryURL(true) '/collections/name/' databaseid]);
    catch
        %this happens, if the options are empty, i.e. the database is not
        %found.
        error(sprintf('%s not present in the registry (%s).\nPlease check the provided database identifier',databaseid,registry));
    end
    while numel(options) > 1
        %Convert the options to a struct array
        if iscell(options)
            options = struct('name',cellfun(@(x) x.name,options,'UniformOutput',0),...
                'prefix',cellfun(@(x) x.prefix,options,'UniformOutput',0),...
                'definition', cellfun(@(x) x.definition,options,'UniformOutput',0),...
                'pattern', cellfun(@(x) getField(x,'pattern'),options,'UniformOutput',0));
        end
        %check whether we have an (case insensitive) exact match
        exactmatchpos = find(strcmpi({options.name},databaseid) | strcmpi({options.prefix},databaseid));
        %if either more than one, or none, the user needs to select one.        
        if numel(exactmatchpos) ~= 1
            displayOptionsString(options)
            if ~isempty(UPDATE_ANNOTATION_TESTING) || ~isempty(GET_DATABASEID_TESTING)
                if UPDATE_ANNOTATION_TESTING
                    selection = UPDATE_ANNOTATION_GET_DATABASE_INPUT;
                elseif ~isempty(GET_DATABASEID_TESTING_LABELINPUT)
                    selection = GET_DATABASEID_TESTING_LABELINPUT;
                elseif ~isempty(GET_DATABASEID_TESTING_POSITIONINPUT)
                    selection = GET_DATABASEID_TESTING_POSITIONINPUT;
                end
            else
                selection = input('Please select one of the options presented above by either \nentering the position, the name or the prefix as stated above.\n','s');
            end
            [num,status] = str2num(selection);
            if status
                if num < numel(options) && num > 0
                    options = options(num);
                else
                    fprintf('The selection was invalid. please select one of the available options\n')
                end
            else
                exactmatchpos = strcmpi({options.name},selection) | strcmpi({options.prefix},selection);
                tempoptions = options(exactmatchpos);
                if numel(tempoptions) > 1
                    fprintf('There where %i matching options:\n',numel(tempoptions));                    
                    options = tempoptions;
                elseif numel(tempoptions) == 0
                    fprintf('No option matched your selection: %s\n',selection);
                else
                    options = tempoptions;
                end                
            end            
        else
            options = options(exactmatchpos);
        end
    end    
    pattern = options(1).pattern;
    database = options(1).prefix; 
else
    database = databaseid;
    pattern = '.*';
end

end

function maps = getSpecialMaps()
%Get the maps for special databases which have multple entries.
    metanetxmap = containers.Map({'mets','rxns'},{'metanetx.chemical','metanetx.reaction'});
    keggmap = containers.Map({'genes','mets','rxns'},{'kegg.genes','kegg.compound','kegg.reaction'});    
    maps{1} = keggmap;
    maps{2} = metanetxmap;
end


function displayOptionsString(options)
    fprintf('%-8s: %-20s | %-20s | %s\n','Position','Name','Prefix','Description');    
    for i = 1: numel(options)
        if iscell(options)
            coption = options{i};
        else
            coption = options(i);
        end
        fprintf('%8i: %-20s | %-20s | %s\n',i,coption.name(1:min(20,end)),coption.prefix,coption.definition);
    end
end

function field = getField(registrydefinition,fieldname)
    if(~isfield(registrydefinition,fieldname))
        field = '.*';
    else
        field = registrydefinition.(fieldname);
    end
end
        