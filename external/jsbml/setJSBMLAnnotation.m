function setJSBMLAnnotation(sbmlObject,model,fieldentries,position)
% setJSBMLAnnotation sets the annotation for an SBMLObject based on the fields in the model
%
% USAGE:
%
%       setJSBMLAnnotation(sbmlObject,model,fieldentries,position)
%
% INPUT:
%    sbmlObject:       The SBMLObject that will receive the annotation
%    model:            the model to extract the data
%    fieldentries:     either a char indicating the field
%                      (prot,met,rxn,comp,gene), or a cell array with X{:,1}
%                      being field IDs and X{:,2} being bioql qualiiers to
%                      annotate for the field.
%    position:         the position in the model to extract the data.
%
% OUTPUT:
%
%   annotationString: The annotation String to be put into the SBML.
%   notes:            A 2*x cell array of fields which did not contain
%                     valid identifiers (according to the pattern check.
%
% .. Authors:
%       - Thomas Pfau May 2017

cAnnotation = sbmlObject.getAnnotation();

allQualifiers = {'encodes', 'encodement',...
    'hasPart', 'part',...
    'hasProperty', 'property',...
    'hasVersion', 'version',...
    'is', 'identity',...
    'isDescribedBy', 'description',...
    'isEncodedBy', 'encoder',...
    'isHomologTo', 'homolog',...
    'isPartOf', 'parthood',...
    'isPropertyOf', 'propertyBearer',...
    'isVersionOf', 'hypernym',...
    'occursIn', 'container',...
    'hasTaxon', 'taxon',...
    'isRelatedTo', 'relation'};

if ischar(fieldentries)
    fieldentries = {fieldentries, allQualifiers};
end

modelFields = fieldnames(model);
CVMap = java.util.HashMap();

for pos = 1:size(fieldentries,1)
    field = fieldentries{pos,1};
    if isempty(fieldentries{pos,2})
        allowedQualifiers = allQualifiers;
    else
        allowedQualifiers = fieldentries{pos,2};
    end
    relfields = modelFields(cellfun(@(x) strncmp(x,field,length(field)),modelFields));
    fieldMappings = getDatabaseMappings(field);
    [~,upos,~] = unique(fieldMappings(:,3));
    fieldMappings = fieldMappings(upos,:);
    for i = 1:numel(allowedQualifiers)
        BQual = getJSBMLBQBTerm(allowedQualifiers{i});
        if ~CVMap.containsKey(BQual)
            temp = org.sbml.jsbml.CVTerm();
            temp.setQualifier(BQual);
            CVMap.put(BQual,temp);
        end
        ccvTerm = CVMap.get(BQual);
        annotationsFields = relfields(cellfun(@(x) strncmp(x,[field allowedQualifiers{i}],length([field allowedQualifiers{i}])),relfields));
        knownFields = fieldMappings(cellfun(@(x) strcmp(x,allowedQualifiers{i}),fieldMappings(:,2)),:);
        for fieldid = 1:numel(annotationsFields)
            if isempty(model.(annotationsFields{fieldid}){pos})
                continue
            end
            ids = strsplit(model.(annotationsFields{fieldid}){position},';');
            ids = regexprep(ids,'^\s*','');
            ids = regexprep(ids,'\s*$','');
            dbname = convertSBMLID(regexprep(annotationsFields{fieldid},[field allowedQualifiers{i} '(.*)' 'ID$'],'$1'),false);
            for id = 1:numel(ids)
                ccvTerm.addResource(['http://identifiers.org/' dbname '/' ids{id}]);
            end
        end
        knownExistentFields = knownFields(ismember(knownFields(:,3),modelFields),:);
        
        
        for fieldid = 1:size(knownExistentFields,1)
            if isempty(model.(knownExistentFields{fieldid,3}){position})
                continue
            end
            ids = strsplit(model.(knownExistentFields{fieldid,3}){position},';');
            ids = regexprep(ids,'^\s*','');
            ids = regexprep(ids,'\s*$','');
            correctids = ~cellfun(@isempty, regexp(ids,knownExistentFields{fieldid,5}));
            if any(correctids)
                dbname = knownExistentFields{fieldid,1};
                for id = 1:numel(ids)
                    ccvTerm.addResource(['http://identifiers.org/' dbname '/' ids{id}]);
                end
            end
        end
    end
end

allTerms = getJSBMLBQBTerm('all');
for i = 1:numel(allTerms)
    BQual = allTerms{i};
    if CVMap.containsKey(BQual)
        ccvterm = CVMap.get(BQual);
        if ~(ccvterm.getResources().size() == 0)
            cAnnotation.addCVTerm(ccvterm);
        end
    end
end










