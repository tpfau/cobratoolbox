function keggData = getKEGGDataForOrganism(KEGGOrganism)
% parse a KEGG list response into a matlab struct.
% USAGE:
%    keggData = parseKEGGOrganismList(KEGGResponse)
%
% INPUT:
%    KEGGOrganism:      The KEGG organism identifier
%
% OUTPUT:
%    keggData:          The data returned in a struct array with the following fields:
%                        * organsim - the organism of the returned element
%                        * ID       - the ID (for hsa:763 the id would be 763 of the element)
%                        * symbols  - The symbols returned for the element
%                        * description - The description of the element
%
% .. Author - Thomas Pfau Oct 2018
%    

KEGGResponse = webread(['http://rest.kegg.jp/list/' KEGGOrganism]);

KEGGLines = strsplit(KEGGResponse,'\n');
% we have to remove empy lines (mostly the last one, but just to make
% sure...
KEGGLines = KEGGLines(~cellfun(@isempty, KEGGLines));
keggData = cellfun(@buildKEGGList, KEGGLines);
end





function resstruct = buildKEGGList(listLine)
% get a struct with fields organism, ID, symbols, description
resstruct = struct('organism','','ID','','symbols',cell(1),'description','');
fields = strsplit(listLine,{'\t',';'});
fieldCount = numel(fields);
% the first entry is always the organism/id 
org_and_id = strsplit(fields{1},':');
resstruct.organism = org_and_id{1};
resstruct.ID = org_and_id{2};
% if there are more fields, add the symbols
if fieldCount > 1
    resstruct.symbols = strsplit(fields{2},{',',' '});
else
    resstruct.symbols = cell(0);
end
% if there are still more, add the description
if fieldCount > 2
    resstruct.description = strtrim(fields{3});
end
end