function [ model ] = updateAnnotation( model, modelIdentifier, database, databaseIdentifier, varargin)
%UPDATEANNOTATION This function is a manual I/O for model annotations. 
% INPUT
%   model              A Cobra model structure
%   modelidentifier    The identifier of the element which gets an updated
%                      annotation. The function will check, which basic field (as
%                      defined in the docs) contains this id and update the 
%                      according annotations.
%   databaseidentifier The actual annotation (i.e. the identifier in the provided
%                      database)
%   database           The database the annotation should refer to. 
%                      If the database is listed in identifiers.org, the
%                      databasestring will be genereated automatically.
%                      Otherwise, a registry needs to be provided using the
%                      property/value pair 'Registry','http://url' such
%                      that [ Registry '/' database '/' databaseidentifier]
%                      resolve to a valid url.
% OPTIONAL INPUT:
%   varargin           Key Value pairs including:
%                      'Registry' , (Can be any String, that identifies the Registry 
%                      to be used. Default 'identifiers.org')
%                      'AnnotationType' can be any of: 'Gene', 'Reaction',
%                      'Metabolite' (per default all fields are checked, and if
%                      multiple options are possible input is requested.
%                      'BioQualifier' a BioQualifier as described at 
%                      http://co.mbine.org/standards/qualifiers. default : 'is'
%

%The following Variables are for testing purposes (to check user input)
global UPDATE_ANNOTATION_TESTING
if ~isempty(UPDATE_ANNOTATION_TESTING)
    failedcount = 0;
end
global UPDATE_ANNOTATION_TESTING_FAILFIELD
global UPDATE_ANNOTATION_USERINPUTFAILFIELD
global UPDATE_ANNOTATION_USERINPUTSUCCESSFIELD



AnnotationOptions = getAnnotationOptions('returnOptions',1);
AnnotationOptions = [AnnotationOptions.fieldOptions, {'automatic'}];
p = inputParser;
 addRequired(p,'model',@isstruct)
 addRequired(p,'modelIdentifier',@ischar)
 addRequired(p,'database',@ischar)
 addRequired(p,'databaseIdentifier',@ischar)
 addParameter(p,'Registry',getRegistryURL(),@ischar)
 addParameter(p,'AnnotationType','automatic',@(x) isoption(x,AnnotationOptions))
 addParameter(p,'BioQualifier','is',@(x) isoption(x,getBioQualifierOptions()))
 
parse(p,model,modelIdentifier,database,databaseIdentifier,varargin{:});

model = p.Results.model;
modelIdentifier = p.Results.modelidentifier;
database = p.Results.database;
databaseIdentifier = p.Results.databaseidentifier;
Registry = p.Results.Registry;
AnnotationType = p.Results.AnnotationType;
BioQualifier = p.Results.BioQualifier;

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
    if ~numel(presentfields) == 1
        acceptfield = 0;
    end
    if numel(presentfields) == 0
        error(sprintf('Did not find %s in any annotatable fields in the model. Please check that the identifier is correct',modelIdentifier));
    end
else    
    if ~isempty(annotationOptionsStruct.modelFieldName) && any(ismember(model.(annotationOptionsStruct.modelFieldName{1}),modelIdentifier))
        presentfields = find(ismember(annotationOptionsStruct.fieldNames,annotationOptionsStruct.modelFieldName));        
    else
        %If we get to this point, the field does exist (actually the check
        %above is useless, as the input argument is checked already        
        error(sprintf('Did not find %s in model.%s. Could not update annotation. Please check that the identifier is correct',modelIdentifier,annotationOptionsStruct.modelFieldName{1}));
    end    
end

presentfieldNames = annotationOptionsStruct.fieldOptions(presentfields);
presencecount = numel(presentfields);

%We arrive here only, if the field is accepted, or we have an automatic
%setup and multiple fields with the identifier.
%as long as there are multiple fields selected, or the field is not
%accepted, we will ask again.
while presencecount ~= 1 && ~acceptfield
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
        if any(ismember(model.(annotationOptionsStruct.modelFieldName{1}),modelIdentifier))
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
itempos = find(ismember(model.(annotationOptionsStruct.fieldOptions{presentfields}),modelIdentifier));

%% The next step is to check the provided database (if it is available in the given registry).


disp(sprintf('updating Annotation for item %i of %s',presentfields,annotationOptionsStruct.fieldOptions{presentfields}));
end


function res = isoption(type,options)
res = any(ismember(options,type));
end

