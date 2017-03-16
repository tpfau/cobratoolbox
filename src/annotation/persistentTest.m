function persistentTest()
%PERSISTENTTEST Summary of this function goes here
%   Detailed explanation goes here
persistent TESTMODE;

if isempty(TESTMODE)
    TESTMODE = 0;
else
    persistent USERINPUT1;
    persistent USERINPUT2;
    persistent USERINPUT3;
end
if ~TESTMODE
    disp('Not Testing')
    TESTMODE = 1;
else
    disp('Testing')
end

end

