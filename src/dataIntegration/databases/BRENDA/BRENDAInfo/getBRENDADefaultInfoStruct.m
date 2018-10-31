function [brendaInfo] = initBRENDAInfo(ECNumbers)
% Initialize a BRENDA Info struct for the given EC Numbers
% USAGE:
%    [brendaInfo] = initBRENDAInfo(ECNumbers)
%
% INPUT:
%    ECNumbers:     A Cell array of EC Numbers.
%
% OUTPUT:
%    brendaInfo:     A Structure Array with ECNumbers and additional
%                    brendaInfo fields.


brendaInfo = columnVector(struct('ECNumber',ECNumbers,'KM',1,...
                             'MW',1,'PATH',1,...
                             'SA',1,'KCAT',1,'SEQ',1));      
end
