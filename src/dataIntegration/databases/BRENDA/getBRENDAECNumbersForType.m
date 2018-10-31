function ECs = getBrendaECNumbersForType(bclient, field, folderName)
% Get the ECNumbers which have the relevant information from BRENDA
% USAGE:
%    ecNumbers = getBrendaECNumbersForType(bclient,field)
% INPUT:
%    bclient:           The BrendaClient to use to connect to BRENDA.
%    field:             The field to retrieve data for
%                       must be one of: {'KM','MW','PATH','SA','KCAT'});
% OPTIONAL INPUT:
%    folderName:        The local folder for the BRENDA Database, if an
%                       empty string is supplied the local database will
%                       not be updated. If not supplied, the default
%                       database will be updated. If a folder is supplied,
%                       the database in the given folder will be updated.
% 
% OUTPUT:
%    ECs:               The EC numbers of all relevant elements.
%                        
%

if ~exist('folderName','var')
    CBT_Folder = fileparts(which('initCobraToolbox.m'));
    % define the default FolderName
    folderName = [CBT_Folder filesep 'databases' filesep 'BRENDA'];
end

if ~exist(folderName','file')
    mkdir(folderName);
end

switch field
    case 'KM'
        ECs = bclient.getEcNumbersFromKmValue();        
    case 'MW'
        ECs = bclient.getEcNumbersFromMolecularWeight();
    case 'PATH'
        ECs = bclient.getEcNumbersFromPathway();
    case 'SEQ'
        ECs = bclient.getEcNumbersFromSequence();
    case 'SA'
        ECs = bclient.getEcNumbersFromSpecificActivity();
    case 'KCAT'
        ECs = bclient.getEcNumbersFromTurnoverNumber();
end
updateData = struct('ECNumber',ECs,field,2);
% get all elements not in the update list, these can'T have the respective
% field, i.e. value of 1.
brendaInfo = loadBRENDAInfo(folderName);
existingEntries = {brendaInfo.ECNumber};
foundEntries = {updateData.ECNumber};
updateData2 = struct('ECNumber',setdiff(existingEntries,foundEntries),field,1);
updateData = [columnVector(updateData);columnVector(updateData2)];
updateLocalBRENDAInfo(updateData,folderName);
end
