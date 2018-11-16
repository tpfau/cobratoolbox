function KEGGData = parseKEGGSimpleData(KEGGResponse,entryName,valueName)
% parse a simple KEGG data response, starting with IDs separated by
% whitespace, and values separated by ;
%
% USAGE:
%    KEGGData = parseKEGGSimpleData(KEGGResponse,entryName,valueName)
%
% INPUT:
%    KEGGResponse:      The chararray returned by KEGG
%    entryName:         The name of the entry field
%    valueName:         The name of the value field

entries = strsplit(KEGGResponse,'\n');

KEGGData = cellfun(@(x) createKEGGStruct(x,entryName,valueName),entries);


function KEGGStruct = createKEGGStruct(line,entryName,valueName)
% parse a simple KEGG data response, starting with IDs separated by
% whitespace, and values separated by ;
%
% USAGE:
%    KEGGData = parseKEGGSimpleData(KEGGRepsonse,entryName,valueName)
%
% INPUT:
%    line:              One line from a KEGG response
%    entryName:         The name of the entry field
%    valueName:         The name of the value field

separator = regexp(line,'\s','ONCE');
KEGGStruct.(entryName) = line(1:separator);
KEGGStruct.(valueName) = strsplit(line(separator+1:end),'; ');