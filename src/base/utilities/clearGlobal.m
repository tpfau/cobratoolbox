function clearGlobal(globalName)
% Safely clear a global variable.
%
% USAGE:
%    clearGlobal(globalName)
%
% INPUTS:
%    globalName:    The name of the global variable to clear.
    if isoctave
        eval(['global ' globalName]);
        eval([globalName ' = []']);
    else
        clearvars('-global',globalName);  
    end    
end