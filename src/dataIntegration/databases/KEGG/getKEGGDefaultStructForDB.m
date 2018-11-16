function KEGGDefaultStruct = getKEGGDefaultStructForDB(db)

ReferenceStruct = struct('reference',{},'authors',{},'title',{},'journal',{});
persistent defaultStructs

if isempty(defaultStructs)
    defaultStructs = containers.Map();    
    keggStructData = readKEGGFieldData('KEGGFields.csv');
    databases = fieldnames(keggStructData);
    for field = 1:numel(databases)        
        cField = databases{field};
        flatFields = keggStructData.(cField).flat;
        structfields = cell(1,2*numel(flatFields));
        for f = 1:numel(flatFields)
            structfields{2*f -1} = lower(flatFields{f});
            if strcmp(flatFields{f},'REFERENCE')
                structfields{2*f} = ReferenceStruct;
            else
                structfields(2*f) = {{}};
            end
        end
        defaultStructs(cField) = struct('id',{},structfields{:});
    end
end

if defaultStructs.isKey(db)
    KEGGDefaultStruct = defaultStructs(db)
else
    error('The requested database has no default struct.')
end

end