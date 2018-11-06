function defaultData = getBRENDADefaultData(fieldName)
% get Default Data for BRENDA structure.
%

persistent datastore
folder = fileparts(which(mfilename));
if isempty(datastore)    
    % try loading the Defaults, if they don't exist, initialize an empty
    % map.
    try
        load([folder filesep 'BRENDADefaults.mat'],'datastore');
    catch ME
        datastore = containers.Map();
    end
end
changed = false;
% if a field is missing, initialize it
if ~datastore.isKey(fieldName)
    bclient = startBRENDAClient();
    changed = true;
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
if changed
    save([folder filesep 'BRENDADefaults.mat'],'datastore');
end

end

