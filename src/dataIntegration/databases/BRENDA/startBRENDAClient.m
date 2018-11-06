function bclient = startBRENDAClient(userName,password)
% Start a reusable BRENDA client
% USAGE:
%    bclient = startBRENDAClient()
%
% OPTIONAL INPUTS:
%    userName:      The username to use Only valid with a password
%    password:      The password to use
% OUTPUT:
%    bclient:       A BrendaClient object.

persistent lbclient 

if isempty(lbclient)
    if nargin == 2
        lbclient = BrendaClient(userName,password);    
    else
        lbclient = BrendaClient();
    end
end

bclient = lbclient;
end

