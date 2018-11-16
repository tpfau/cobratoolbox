function [fieldData] = readKEGGFieldData(fileName)
% This function provides the same raw output as tdfread from the 
% statistics toolbox, making sure, that we don't need that as a
% prerequesite
%
% USAGE:
%
%    [raw] = descFileRead(fileName)
%
% INPUT:
%    fileName:             The filename of a tab delimited data file. The
%                          first row of the file will be considered to be headers (with spaces
%                          being replaced by '_'.
%
% OUTPUTS:
%    fieldData:            A struct with one field per Database (lower
%                          case) containing the fields "web" and "flat"
%                          
%
% .. Author: - Thomas Pfau Nov 2018

f = fopen(fileName);

% get the headers
header = fgetl(f);
headers = strsplit(header,'\t','CollapseDelimiters',true);
if isempty(headers{end})
    headers = headers(1:end-1);
end
% initialize the data struct
data = struct();
data.web =  {};
data.flat = {};
cellForConversion = cell(2,numel(headers));
cellForConversion(1,:) = lower(headers);
cellForConversion(2,:) = {data};
fieldData = struct(cellForConversion{:});

% skip the flat/web line
cline = fgetl(f);
cline = fgetl(f);

% now, read all lines
lines = cell(50,1);
currentLine = 1;

while cline ~= -1
    lines{currentLine} = cline;
    %Keep empty entries.
    currentLine = currentLine + 1;    
    cline = fgetl(f);
end
%Walk through the lines
    
fclose(f);

for i = 1:size(lines,1)
    if isempty(lines{i})
        break
    end
    values = strsplit(lines{i},'\t','CollapseDelimiters',false);
    for field = 1:numel(headers)
        cheader = lower(headers{field});
        if ~isempty(values{2*field})
            % if its empty, there is no data, so we can skip it
            webVal = values{2*field-1};
            flatVal = values{2*field};
            if isempty([fieldData.(cheader).web])
                fieldData.(cheader).web = {webVal};
            else
                fieldData.(cheader).web{end+1} = webVal;
            end
            if isempty([fieldData.(cheader).flat])
                fieldData.(cheader).flat = {flatVal};
            else
                fieldData.(cheader).flat{end+1} = flatVal;
            end
        end
    end
        
end
    
end

