function keggData = getKEGGOrganismData()
% Get the organism data from KEGG
% USAGE:
%    keggData = getKEGGOrganismData()
%
% OUTPUT:
%    keggData:          The data returned in a struct array with the following fields:
%                        * entry    - the KEGG Entry ID of the returned element
%                        * ID       - The KEGG organism abbreviation
%                        * name     - The name of the organism
%                        * lineage  - The lineage of the organism (cell array)
%
% .. Author - Thomas Pfau Oct 2018
%    

KEGGResponse = webread('http://rest.kegg.jp/list/organism');

KEGGLines = strsplit(KEGGResponse,'\n');
% we have to remove empy lines (mostly the last one, but just to make
% sure...
KEGGLines = KEGGLines(~cellfun(@isempty, KEGGLines));
keggData = cellfun(@buildKEGGList, KEGGLines);
end





function resstruct = buildKEGGList(listLine)
% get a struct with fields organism, ID, symbols, description
resstruct = struct('entry','','ID','','name','','lineage',cell(1));
fields = strsplit(listLine,{'\t'});
fieldCount = numel(fields);
% the first entry is always the organism/id 
resstruct.entry= strtrim(fields{1});
resstruct.ID = strtrim(fields{2});
% if there are more fields, add the symbols
if fieldCount > 2
    resstruct.name = strtrim(fields{3});
else
    resstruct.symbols = cell(0);
end
% if there are still more, add the description
if fieldCount > 3
    resstruct.lineage = strsplit(strtrim(fields{4}),';');
end
end