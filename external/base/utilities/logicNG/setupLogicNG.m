function setupLogicNG()
% setupLogicNG adds logicNG and the required antlr4 runtime to the java
% class path for logic support 
% 
% USAGE:
%
%    setupLogicNG()
%
% .. Author: - Thomas Pfau November 2018

folder = fileparts(which(mfilename)); % Get the folder of this file.

if exist('org.logicng.formulas.FormulaFactory', 'class') ~= 8
    oldfolder = cd(folder);    
    javaaddpath('antlr4-runtime-4.7.1.jar');
    javaaddpath('logicng-1.4.0.jar');
    cd(oldfolder);
end

end
