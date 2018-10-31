function bclient = startBRENDAClient()
% Start a reusable BRENDA client
% USAGE:
%    bclient = startBRENDAClient()
%
% OUTPUT:
%    bclient:       A BrendaClient object.

persistent lbclient 

if isempty(lbclient)
    lbclient = BrendaClient();    
end

bclient = lbclient;
end

