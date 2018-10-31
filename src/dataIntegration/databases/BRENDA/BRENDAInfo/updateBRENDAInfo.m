function updatedInfo = updateBRENDAInfo(brendaInfo,updateData)
% Update the BRENDA Info struct.
% USAGE: 
%    updatedInfo = updateBRENDAInfo(brendaInfo,updateData)
%
% INPUTS:
%    brendaInfo:        A Struct with the BRENDAInfo fields (see
%                       loadBrendaInfo)
%    updateData:        A Struct with a field ECNumber and additional
%                       fields which should be updated in the BRENDAInfo
%                       struct. Existing values will be overwritten.
% OUTPUT:
%    updatedInfo:       The updated information struct

updateData = columnVector(updateData);
existingEntries = {brendaInfo.ECNumber};
entriesToUpdate = {updateData.ECNumber};
[pres,pos] = ismember(entriesToUpdate,existingEntries);
fieldsToUpdate = setdiff(fieldnames(updateData),'ECNumber');
infoToAdd = getBRENDADefaultInfoStruct(entriesToUpdate(~pres));
% now, update the data in the fields from the update data
for i = 1:numel(fieldsToUpdate)
    cField = fieldsToUpdate{i};
    [infoToAdd.(cField)] = deal(updateData(~pres).(cField));
    newValues = num2cell(max([updateData(pres).(cField)],[brendaInfo(pos(pres)).(cField)]));
    [brendaInfo(pos(pres)).(cField)] = deal(newValues{:});
end
updatedInfo = [brendaInfo;infoToAdd];
end

