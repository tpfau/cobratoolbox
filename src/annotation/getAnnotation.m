function [ output_args ] = getAnnotation( model, modelIdentifier, database, varargin )
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
% OPTIONAL INPUT:
%
%   database           The database for whi to retrieve the annotation. If
%                      left empty all annotations will be returned.
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
%                      http://co.mbine.org/standards/qualifiers or 'any' if
%                      all annotations should eb returned.
%                      (type: char, default: 'any')

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

if nargin > 3
    if ~mod(numel(varargin),2)
        %We have no databaseIdentifier, so we need to fix the varargin
        %variable and clear the databaseIdentifier.
        varargin = [database , varargin];
        clear database            
    end    
end
    p = inputParser;
    addRequired(p,'model',@isstruct)
    addRequired(p,'modelIdentifier',@ischar)
    addOptional(p,'database','',@ischar)
    addParameter(p,'Registry',getRegistryURL(),@ischar)
    addParameter(p,'AnnotationType','automatic',@(x) isoption(x,AnnotationOptions))
    addParameter(p,'BioQualifier','any',@(x) isoption(x,getBioQualifierOptions()))
    parse(p,model,modelIdentifier,database,varargin{:}); 
end

