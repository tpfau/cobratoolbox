function url = getRegistryURL(rest)
%Get the url of the identifiers.org Registry
% OPTIONAL INPUT 
%   rest        Whether the URL of the REST API is requested or not
% OUTPUT
%   url         The requested URL. Either the basic url for ids, or the URL
%               of the REST api (if the REST argument is provided

if nargin > 0
    if rest
        url = 'http://identifiers.org/rest'
        return
    end
end

url = 'http://identifiers.org/';
end