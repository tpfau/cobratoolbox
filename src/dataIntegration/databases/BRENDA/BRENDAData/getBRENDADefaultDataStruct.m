function [brendaData] = getDefaultBrendaDataStruct(ECNumbers)
% get the default Brenda Data struct array for the given EC Numbers (or an
% empty struct if no ECNumbers are given.
% USAGE:
%    [brendaData] = getDefaultBrendaDataStruct(ECNumbers)
%
% OPTIONAL INPUT:
%    ECNumbers:     A Cell array of EC Numbers.
%
% OUTPUT:
%    brendaData:     A Structure Array with ECNumbers and additional
%                    brendaData fields.

if ~exist('ECNumbers','var')
    ECNumbers = {};
end
brendaData = struct('ECNumber',ECNumbers,'KM',getBRENDADefaultData('KM'),...
    'MW',getBRENDADefaultData('MW'),'PATH',getBRENDADefaultData('PATH'),...
    'SA',getBRENDADefaultData('SA'),'KCAT',getBRENDADefaultData('KCAT'),...
    'SEQ',getBRENDADefaultData('SEQ'));
end
