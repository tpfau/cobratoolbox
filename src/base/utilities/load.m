function varargout = load(varargin)
warnstat = warning();
warning off
path = fileparts(which(mfilename));
cleanUp = onCleanup(@() restore(path,warnstat)); 
rmpath(path);
if strcmp(varargin{1},'UseOriginalLoad')
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
                celem = convertOldStyleModel(celem);
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