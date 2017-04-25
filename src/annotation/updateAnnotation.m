function [ model ] = updateAnnotation( model, modelIdentifier, database, databaseIdentifier, varargin)
%UPDATEANNOTATION This function is a manual I/O for model annotations. 
% An annotation will commonly be added to any existing annotations. If a
% replacement of the annotation for the given database is desired, the
% optional argument 'replaceDataBaseAnnotation' must be set to true.
% Important Notice: This function may require manual input, so please don't
% use it in an automated script.
% INPUT:
%
%   model              A Cobra model structure
%
%   modelidentifier    The identifier of the element which gets an updated
%                      annotation. The function will check, which basic field (as
%                      defined in the docs) contains this id and update the 
%                      according annotations. 
%
%   database           The database the annotation should refer to. 
%                      If the database is listed in identifiers.org, the
%                      databasestring will be genereated automatically.
%                      Otherwise, a registry needs to be provided using the
%                      property/value pair 'Registry','http://url' such
%                      that [ Registry '/' database '/' databaseidentifier]
%                      resolve to a valid url.
%
%   databaseidentifier The actual annotation (i.e. the identifier in the provided
%                      database) If this is empty (i.e. '' or []), the
%                      entry indicated by the database will be deleted. Can
%                      be either a string, a cell array of strings (if 
%                      multiple identifiers should be added at once), or empty
%
% OPTIONAL INPUT:
%
%   varargin           Key Value pairs including:
%                      'Registry', identifies the registry to use.
%                      Currently, if this is different from
%                      'http://identifiers.org', the function assumes, that
%                      [Registry database databaseidentifier] is a valid
%                      url. If it is left at the default, registry.org will
%                      be contacted to check the annotation. 
%                      (default: 'http://identifiers.org', type: char)
%                      'AnnotationType' indicates which field will be annotated. 
%                      Can be any of: 'Gene', 'Reaction', 'Metabolite' or 'automatic' 
%                      if automatic, all annotateable fields will be checked.
%                      (type: char, default : 'automatic'
%                      'BioQualifier' a BioQualifier as described at 
%                      http://co.mbine.org/standards/qualifiers. default :
%                      (type: char, default: 'is')
%                      'replaceDataBaseAnnotation' specifies whether this
%                      update should replace any current annotation, or
%                      whether it is an additional annotation. (default
%                      false)
%

%The following Variables are for testing purposes (to check user input)
global UPDATE_ANNOTATION_TESTING
if ~isempty(UPDATE_ANNOTATION_TESTING)
    failedcount = 0;
end
global UPDATE_ANNOTATION_TESTING_FAILFIELD
global UPDATE_ANNOTATION_USERINPUTFAILFIELD
global UPDATE_ANNOTATION_USERINPUTSUCCESSFIELD



AnnotationOptions = getAnnotationOptions('returnOptions',1,'returnFieldNames',1);
AnnotationOptions = [AnnotationOptions.fieldOptions, AnnotationOptions.fieldNames, {'automatic'}];
p = inputParser;
%Required Parameters
addRequired(p,'model',@isstruct)
addRequired(p,'modelIdentifier',@ischar)
addRequired(p,'database',@ischar)
addOptional(p,'databaseIdentifier','',@(x) ischar(x) | (iscell(x) & all(cellfun(@ischar,x))) | isempty(x))
addParameter(p,'Registry',getRegistryURL(),@ischar)
addParameter(p,'AnnotationType','automatic',@(x) isoption(x,AnnotationOptions,1))
addParameter(p,'BioQualifier','is',@(x) isoption(x,getBioQualifierOptions()))
addParameter(p,'replaceDataBaseAnnotation',false,@(x) islogical(x) | (isnumeric(x) && numel(x) == 1));

%This works only, since we only have one optional argument. There is no
%way, how we can 
if nargin > 4
    if ~mod(numel(varargin),2)
        %We have no databaseIdentifier, so we need to fix the varargin
        %variable and clear the databaseIdentifier.
        varargin = [databaseIdentifier , varargin];
        clear databaseIdentifier            
    end    
end
 
parse(p,model,modelIdentifier,database,databaseIdentifier,varargin{:});

model = p.Results.model;
modelIdentifier = p.Results.modelIdentifier;
database = p.Results.database;
databaseIdentifier = p.Results.databaseIdentifier;
Registry = p.Results.Registry;
AnnotationType = p.Results.AnnotationType;
BioQualifier = p.Results.BioQualifier;
replaceDataBaseAnnotation = p.Results.replaceDataBaseAnnotation;

%If this is supposed to be done automatically, we check the relevant
%fields. 
annotationOptionsStruct = getAnnotationOptions('fieldDescription',AnnotationType,'returnFieldNames',1, 'returnOptions',1);
idpresentinfields = zeros(size(annotationOptionsStruct.fieldNames));
for field = annotationOptionsStruct.fieldNames  
     idpresentinfields(ismember(annotationOptionsStruct.fieldNames,field{1})) = any(ismember(model.(field{1}),modelIdentifier));
end
acceptfield = 1;
if strcmpi(AnnotationType,'automatic')    
    presentfields = find(idpresentinfields);
    if ~ (numel(presentfields) == 1)
        acceptfield = 0;
    end
    if numel(presentfields) == 0
        error(sprintf('Did not find %s in any annotatable fields in the model. Please check that the identifier is correct',modelIdentifier));
    end
else    
    if ~isempty(annotationOptionsStruct.modelFieldName) && any(ismember(model.(annotationOptionsStruct.modelFieldName),modelIdentifier))
        presentfields = find(ismember(annotationOptionsStruct.fieldNames,annotationOptionsStruct.modelFieldName));        
    else
        %If we get to this point, the field does exist (actually the check
        %above is useless, as the input argument is checked already        
        error(sprintf('Did not find %s in model.%s. Could not update annotation. Please check that the identifier is correct',modelIdentifier,annotationOptionsStruct.modelFieldName));
    end    
end

presentfieldNames = annotationOptionsStruct.fieldOptions(presentfields);
presencecount = numel(presentfields);

%We arrive here only, if the field is accepted, or we have an automatic
%setup and multiple fields with the identifier.
%as long as there are multiple fields selected, or the field is not
%accepted, we will ask again.

while (presencecount ~= 1) && (~acceptfield)
    %We have the identifier in multiple fields AND we have an automatic
    %assignment. So lets ask, which field should actually be used.
    if presencecount > 1
        concatenators = [repmat({', '},1,presencecount-2) ,' and '];
        PresentfieldString = strjoin(presentfieldNames,concatenators{:});    
        fprintf('The identifier was found to be present as %s.\n',PresentfieldString);
    end
    if UPDATE_ANNOTATION_TESTING
        if UPDATE_ANNOTATION_TESTING_FAILFIELD
            if failedcount == 0
                failedcount = faildcount + 1;            
                selection = UPDATE_ANNOTATION_USERINPUTFAILFIELD;
            else
                selection = UPDATE_ANNOTATION_USERINPUTSUCCESSFIELD;
            end
        else
            selection = UPDATE_ANNOTATION_USERINPUTSUCCESSFIELD;
        end
    else
        selection = input(sprintf('Please select a type for annotation by inserting one of the types indicated.\n'),'s');
    end
    annotationOptionsStruct = getAnnotationOptions('fieldDescription',selection,'returnFieldNames',1, 'returnOptions',1);
    if ~isempty(annotationOptionsStruct.modelFieldName) 
        if any(ismember(model.(annotationOptionsStruct.modelFieldName),modelIdentifier))
            presentfields = find(ismember(annotationOptionsStruct.fieldNames,annotationOptionsStruct.modelFieldName));        
            presencecount = 1;
            acceptfield = 1;
        else
            fprintf('The identifier was found not as a %s.\n',selection);
            concatenators = [repmat({', '},1,presencecount-2) ,' or '];
            PresentfieldString = strjoin(presentfieldNames,concatenators{:});    
            fprintf('It is present as \n',PresentfieldString);
            presencecount = 0;
        end
    else
        fprintf('The provided type (%s) does not correspond to a field name\n',selection);
        concatenators = [repmat({', '},1,presencecount-2) ,' or '];
        PresentfieldString = strjoin(presentfieldNames,concatenators{:});    
        fprintf('The identifier is present as \n',PresentfieldString);
        presencecount = 0;        
    end
    
end
   

%So, we have the field that is annotated along with te item in the field. 
%Now, get the position of the item
itempos = find(ismember(model.(annotationOptionsStruct.fieldNames{presentfields}),modelIdentifier));

%% The next step is to check the provided database (if it is available in the given registry).
[databaseid,pattern] = getDataBaseIdentifier(database, Registry,'annotatedField',annotationOptionsStruct.fieldOptions{presentfields});
%% Now, add the annotation to the respective field.
%This is completely specific to the final concept how the annotations are
%organized, so it will be implemented when that concept is set

if isempty(databaseid)
    disp(['Removing all annotations from ' modelidentifier ' in field ' annotationOptionsStruct.fieldOptions{presentfields}]);
elseif isempty(databaseIdentifier)
    disp(['Removing Annotation in database ' databaseid ' for ' modelIdentifier ' in field ' annotationOptionsStruct.fieldOptions{presentfields}]);
else
    if replaceDataBaseAnnotation
        disp([' Replacing Annotation in database ' databaseid ' for ' modelIdentifier ' in field ' annotationOptionsStruct.fieldOptions{presentfields} ' with ' databaseIdentifier]);
    else
        disp([' Adding Annotation in database ' databaseid ' for ' modelIdentifier ' in field ' annotationOptionsStruct.fieldOptions{presentfields} ' with ' databaseIdentifier]);
    end
end

end

function res = isoption(type,options,caseinsensitivestroptions)

if ~exist('caseinsensitivestroptions','var') || ~caseinsensitivestroptions
    res = any(ismember(options,type));
else
    res = any(strcmpi(type,options));
end

end

