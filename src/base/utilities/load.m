function varargout = load(varargin)
% This function overrides the matlab builtin load function to automatically
% convert potential COBRA Models into a valid model struct (if thats even
% possible).
% USAGE:
%    varargout = load(varagin)
%
% INPUTS:
%    varargin:      Normal options for the MATLAB load command (in
%                   addition, we allow a keyword 'UseOriginalLoad', to
%                   bypass this functionality.
%
% OUTPUTS:
%    nargout:       The default matlab outputs of load. If no outputs are
%                   given, than the variables are created in the calling
%                   workspace.
%
% ..Author:         Thomas Pfau 2018

warnstat = warning();
warning off
path = fileparts(which(mfilename));
cleanUp = onCleanup(@() restore(path,warnstat)); 
rmpath(path);
if numel(varargin) > 0 && ischar(varargin{1}) && strcmp(varargin{1},'UseOriginalLoad')
    varargin(1) = [];
    res = load(varargin{:});
    addpath(path); %Make sure that after the load call we are again working with the correct path.
    if nargout == 1
        varargout{1} = res;
        return;
    else
        if nargout == 0
            elements = fieldnames(res);
            for i = 1: numel(elements)
                assignin('caller',elements{i},res.(elements{i}));
            end
            return
        end
    end
else
    res = load(varargin{:});
    addpath(path); %Make sure that after the load call we are again working with the correct path.
    elements = fieldnames(res);
    %Now, convert all models
    for i = 1:numel(elements)
        celem = res.(elements{i});
        if isstruct(celem)
            if all(ismember({'S','rxns','mets'},fieldnames(celem)))
                try
                    celem = convertOldStyleModel(celem);
                catch
                    % don't do anything if it doesn't work... 
                end
                res.(elements{i}) = celem;
            end
        end
    end
    if nargout == 1
        varargout{1} = res;
        return;
    else
        if nargout == 0
            for i = 1: numel(elements)
                assignin('caller',elements{i},res.(elements{i}));
            end
            return
        end
    end
end


function restore(pathname,warnstat)
warning(warnstat);
addpath(pathname);