function setupJSBML()
%setupxlwrite setup all folders and pathes necessary to use xlwrite from Matlab file Exchange.
% 
% USAGE:
%
%    setupxlwrite()
% NOTE:
% This function will look for the external folder 
% .. Author: - Thomas Pfau May 2017

global CBTDIR
if isempty(CBTDIR)
    initCobraToolbox
end


%If the class does not exist, add the jar.
if ~exist('org.sbml.jsbml.SBMLReader','class')
    disp('Adding JSBML to Java Path');
    jsbmlFilePath = [CBTDIR filesep 'external' filesep 'jsbml'];
    javaaddpath([jsbmlFilePath filesep 'jsbml.jar']);
end

end
