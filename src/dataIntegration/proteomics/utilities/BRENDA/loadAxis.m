function loadAxis()
% Add the whole Axis library to the java path.
% USAGE:
%    loadAxis()
%

global CBTDIR
%Check, whether the library is loaded.
import org.apache.axis.client.*;

if ~exist('org.apache.axis.client.Service','class')
    axisFolder = [CBTDIR filesep 'external' filesep 'axis-1_4' filesep 'lib'];
    files = dir(axisFolder);
    for i = 1:size(files,1)
        name = files(i).name;
        if ~isempty(regexp(name,'\.jar$'))
            javaaddpath([axisFolder filesep name])
        end
    end
end

end

