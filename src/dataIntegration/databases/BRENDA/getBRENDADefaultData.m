function defaultData = getBRENDADefailtData(bclient,fieldName)
% get Default Data for BRENDA structure.
%

persistent datastore

if isempty(datastore)
    datastore = containers.Map();
end
if ~datastore.isKey(fieldName)
    switch fieldName
        case 'KM'
            data = bclient.getKmValue('ecNumber', '1.1.1.1');
        case 'MW'
            data = bclient.getMolecularWeight('ecNumber', '1.1.1.1');
        case 'PATH'
            data = bclient.getPathway('ecNumber', '1.1.1.1');
        case 'SEQ'
            data = bclient.getSequence('ecNumber', '1.1.1.1');
        case 'SA'
            data = bclient.getSpecificActivity('ecNumber', '1.1.1.1');
        case 'KCAT'
            data = bclient.getTurnoverNumber('ecNumber', '1.1.1.1');
    end
    data(1:end) = [];
    datastore(fieldName) = data;
end
defaultData = datastore(fieldName);

end

