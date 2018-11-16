function [keggData] = loadKEGGData(varargin)
% Load data from the KEGG database (either the local KEGG database or
% online 
% USAGE:
%    [keggData] = loadKEGGData(varargin)
%
% OPTIONAL INPUTS:
%    varargin:      Parameters to determine what to load as parameter/value
%                   pairs or a parameter struct
%                    * `fieldToDownload` - The field for which to download data. If empty, the whole list of genes for the given organism is downloaded. 
%                    * `organism` - The organism for which to download data, if empty, the whole database given by fieldToDownload is downloaded.
%                    * `updateData` - Ignore locally saved data and directly load from the KEGG website, otherwise, only missing data is retrieved (Default: false)
% NOTE:
%    Allowed fields are the KEGG database fields:
%    pathway | brite | module | ko | genome | vg | ag | compound | glycan | reaction | rclass | enzyme | network | variant | disease | drug | dgroup | environ | organism 
%    Organism can only be used with pathway and module databases.
%    
%    
parser = inputParser();

parser.addParameter('fieldToDownload','',@(x) ischar(x) && any(ismember(x,getKEGGDatabaseFields())));
parser.addParameter('organism','',@(x) ischar(x));
parser.addParameter('updateData',false,@(x) islogical(x) || isnumeric(x) && (x ==1 || x == 0));



end

