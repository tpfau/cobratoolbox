function result = getBioModelsQuery( query )
% Get all results form a query to bioModels.
% Biomodels can return a maximum number of 100 elements per query, so we
% will fill up the query.
%
% USAGE:
%    result = getBioModelsQuery( query )
%
% INPUT:
%    query:        A Query to the biomodels search:
%                  'https://wwwdev.ebi.ac.uk/biomodels/search?query='
%
% OUTPUT:
%    result:       A struct reflecting all results obtainable for the
%                  requested query.

bioModelsQueryURL = 'https://wwwdev.ebi.ac.uk/biomodels/search?query=';
numResults = '100';
result = webread([bioModelsQueryURL query '&numResults=100']);
count = result.matches;


for offset = 100:100:count
   results = webread([bioModelsQueryURL query '&offset=' num2str(offset) '&numResults=' numResults '&sortBy=' result.queryParameters.sortBy]);
   result.models = [result.models ; results.models];
end

end

