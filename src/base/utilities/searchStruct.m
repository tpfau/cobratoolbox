function results = searchStruct(searchstruct,searchTerm,minSim)

if ~exist('minSim','var')
    minSim = 0.8;
end

pos = [];

fields = fieldnames(searchstruct);
for i = 1:numel(fields)
    cField = fields{i};
    [~,positions,~] = findMatchingFieldEntries({searchstruct.(cField)},searchTerm,false,minSim);
    pos(end+1:end+(numel(positions))) = positions;
end

[finalPos,ia,ic] = unique(pos);
results = searchstruct(finalPos);
