function [brendaInfo] = buildBRENDAInfo(ECNumbers,varargin)
% Build a Brenda Info Array for the given EC Numbers.
% USAGE:
%    [brendaInfo] = loadBRENDAInfo(ECNumbers,varargin)
%
% INPUT:
%    ECNumbers:     A Cell array of EC Numbers.
%    varargin:      Additional Fields and their corresponding values.
%
% OUTPUT:
%    brendaInfo:     A Structure Array with ECNumbers and additional
%                    brendaInfo fields.
brendaInfo = struct('ECNumber',ECNumbers,varargin{:});
end

