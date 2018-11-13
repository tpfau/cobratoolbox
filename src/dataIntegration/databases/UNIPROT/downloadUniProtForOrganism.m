function uniprotStruct = downloadUniProtForOrganism(organismName, varargin)
% Download the uniprot data for a specifgic organism
% By default, only the following data will be downloaded:
% Entry, Protein Name, Gene Names, EC Number, Sequence
% Other fields are not yet implemented.
% USAGE:
%    uniprotStruct = downloadUniProtForOrganism(organismName, varargin)
% 
% INPUTS:
%    organismName:      The name of the organism
%    varargin:          Fields and function names for additional fields to
%                       parse (e.g. 'SubUnits',str2func(parseComponents));
%                       The function needs to work on the basic struct
%                       returned by uniprot, and return a structural array
%                       that will be assigned to the given field name
%                       (which must be valid)
%                       Also allowed is the keyword 'maxResults' which will
%                       restrict the number of obtained results.
%                       In addition the keyword 'startPos' is allowed which will
%                       indicate the position at which to start the search
%
% OUTPUT:
%    uniprotStruct:     a struct containing data from the Uniprot Database.
%                       basic fields are: 
%                        * EC - The EC number
%                        * Entry - The Accession number
%                        * Sequence - The Sequence
%                        * Genes - The Associated Genes
%                        * Proteins - The associated proteins (recommended Name is the first element, if available)
%                                   


maxResults = inf;
startResult = 0;
if numel(varargin) > 0    
    maxPos = find(ismember(varargin(1:2:end),'maxResults'));        
    if ~isempty(maxPos)
        maxResults = varargin{2*maxPos};
        % delete the entry
        varargin((2*maxPos-1):2*maxPos) = []; 
    end
    startPos = find(ismember(varargin(1:2:end),'startPos'));        
    if ~isempty(startPos)
        startResult = varargin{2*startPos};
        % delete the entry
        varargin((2*startPos-1):2*startPos) = []; 
    end
end

% we first want to know how many responses there are to fetch.
request = matlab.net.http.RequestMessage(); 
numberOfEntryHeader = 'X-Pagination-TotalRecords';
responseCount = 0;
[response] = request.send(['https://www.ebi.ac.uk/proteins/api/proteins?offset=0&size=1&organism=' urlencode('Homo Sapiens')]);
% get the right header and determine the responseCount.
for i = 1:numel(response.Header)
    if strcmp(numberOfEntryHeader,response.Header(i).Name)
        responseCount = min(startResult+maxResults,str2num(char(response.Header(i).Value)));
    end
end

outputs = cell(ceil((responseCount-startResult)/100),1);
for entry=1:ceil((responseCount-startResult)/100)
    offset = startResult + (entry-1) * 100;
    response = webread('https://www.ebi.ac.uk/proteins/api/proteins','offset',offset,'size',100,'organism',organismName);
    if iscell(response)
        data = cellfun(@(x) parseUniProtData(x,varargin{:}), response);
    else
        data = cellfun(@(x) parseUniProtData(x,varargin{:}), mat2cell(response,ones(numel(response),1),1));
    end
    outputs{entry,1} = data;   
end
uniprotStruct = vertcat(outputs{:});
if maxResults < numel(uniprotStruct)
    uniprotStruct = uniprotStruct(1:maxResults);
end
end

