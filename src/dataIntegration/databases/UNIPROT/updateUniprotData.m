function updateUniprotData(organismName, newData, folderName)

if ~exist('folderName','var')
    folderName = getUniProtDefaultFolder();
end
% create Folder if necessary
if ~exist(folderName,'file')
    mkdir(folderName);
end

% load the existing data
orgFile = [folderName filesep organismName '.mat'];
if exist(orgFile,'file')
    data = load(orgFile);
    uniprotData = data.uniprotData;
else
    uniprotData = struct('Entry',{});
end

newfields = fieldnames(newData);
% add new Entries
positionsToAdd = find(~ismember({newData.Entry},{uniprotData.Entry}));
[uniprotData(end+1:end+numel(positionsToAdd)).Entry] = deal(newData(positionsToAdd).Entry);
% now, fill up the data
[positionsToUpdate, newDataPos] = ismember({uniprotData.Entry},{newData.Entry});
updateData = newData(newDataPos(positionsToUpdate));
originalData = uniprotData(positionsToUpdate);
for i = 1:numel(newfields)
   nonEmpty = ~cellfun(@isempty, {updateData.(newfields{i})});
   [originalData(nonEmpty).(newfields{i})] = deal(updateData(nonEmpty).(newfields{i}));
end
for i = 1:numel(newfields)
    [uniprotData(positionsToUpdate).(newfields{i})] = deal(originalData.(newfields{i}));
end

save(orgFile,'uniprotData');

