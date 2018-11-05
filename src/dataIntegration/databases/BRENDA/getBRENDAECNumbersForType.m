function ECs = getBRENDAECNumbersForType(field, folderName)
% Get the ECNumbers which have the relevant information from BRENDA
% USAGE:
%    ecNumbers = getBRENDAECNumbersForType(bclient,field)
% INPUT:
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
    folderName = getBRENDADEfaultFolder();
end
field = getBRENDAFields(field);
if iscell(field)
    field = field{1};
end
% load the Info
BRENDAInfo = loadBRENDAInfo(folderName);
fieldInfo = [BRENDAInfo.(field)];
% get all ECs that are available or already downloaded.
relevants = fieldInfo >=2;
ECs = {BRENDAInfo(relevants).ECNumber}';


end
