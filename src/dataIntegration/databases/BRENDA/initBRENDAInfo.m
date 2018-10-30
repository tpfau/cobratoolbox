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
brendaInfo = columnVector(struct('ECNumber',ECNumbers,'KM',0,...
                             'MW',0,'PATH',0,...
                             'SA',0,'KCAT',0));
end
