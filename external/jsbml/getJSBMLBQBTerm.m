function jsbmlBQTerm = getJSBMLBQBTerm(term)

setupJSBML();
import org.sbml.jsbml.CVTerm;

persistent BQBTermMap

if isempty(BQBTermMap) 
    BQBTermMap = {'encodes', 'encodement',javaMethod('valueOf','org.sbml.jsbml.CVTerm$Qualifier','BQB_ENCODES');...
        'hasPart', 'part',javaMethod('valueOf','org.sbml.jsbml.CVTerm$Qualifier','BQB_HAS_PART');...
        'hasProperty', 'property',javaMethod('valueOf','org.sbml.jsbml.CVTerm$Qualifier','BQB_HAS_PROPERTY');...
        'hasVersion', 'version',javaMethod('valueOf','org.sbml.jsbml.CVTerm$Qualifier','BQB_HAS_VERSION');...
        'is', 'identity',javaMethod('valueOf','org.sbml.jsbml.CVTerm$Qualifier','BQB_IS');...
        'isDescribedBy', 'description',javaMethod('valueOf','org.sbml.jsbml.CVTerm$Qualifier','BQB_IS_DESCRIBED_BY');...
        'isEncodedBy', 'encoder',javaMethod('valueOf','org.sbml.jsbml.CVTerm$Qualifier','BQB_IS_ENCODED_BY');...
        'isHomologTo', 'homolog',javaMethod('valueOf','org.sbml.jsbml.CVTerm$Qualifier','BQB_IS_HOMOLOG_TO');...
        'isPartOf', 'parthood',javaMethod('valueOf','org.sbml.jsbml.CVTerm$Qualifier','BQB_IS_PART_OF');...
        'isPropertyOf', 'propertyBearer',javaMethod('valueOf','org.sbml.jsbml.CVTerm$Qualifier','BQB_IS_PROPERTY_OF');...
        'isVersionOf', 'hypernym',javaMethod('valueOf','org.sbml.jsbml.CVTerm$Qualifier','BQB_IS_VERSION_OF');...
        'occursIn', 'container',javaMethod('valueOf','org.sbml.jsbml.CVTerm$Qualifier','BQB_OCCURS_IN');...
        'hasTaxon', 'taxon',javaMethod('valueOf','org.sbml.jsbml.CVTerm$Qualifier','BQB_HAS_TAXON');...
        'isRelatedTo', 'relation',javaMethod('valueOf','org.sbml.jsbml.CVTerm$Qualifier','BQB_IS_RELATED_TO')};
end

if strcmp(term,'all')
    jsbmlBQTerm = BQBTermMap(:,3);
    return
end

pos = ismember(BQBTermMap(:,1),term);
if ~any(pos)
    pos = ismember(BQBTermMap(:,2),term);
end
if any(pos)
   jsbmlBQTerm = BQBTermMap{pos,3};
else
   jsbmlBQTerm = javaMethod('valueOf','org.sbml.jsbml.CVTerm$Qualifier','BQB_UNKNOWN');
end
end    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    