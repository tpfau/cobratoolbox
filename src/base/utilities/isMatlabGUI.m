function tf = isMatlabGUI()
% Whether matlab was run with a gui or not.
% USAGE:
%    isMatlabGUI()
%
% OUTPUTS:
%    tf:      Whether matlab was opened in a GUI or not.
%

if usejava('jvm') && ~feature('ShowFigureWindows')
     tf = false;
else
     tf = true;     
end
 
end

