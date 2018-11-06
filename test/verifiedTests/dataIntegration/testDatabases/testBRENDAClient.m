% The COBRAToolbox: testBRENDAClient.m
%
% Purpose:
%     - To test the functionality of the BRENDA database IO.
%       
% Authors:
%     - Thomas Pfau Nov 2018

prepareTest('needsWebAddress','http://www.brenda-enzymes.org/soap/brenda_server.php')

% get the user directory
if ispc
    userDir = winqueryreg('HKEY_CURRENT_USER',...
        ['Software\Microsoft\Windows\CurrentVersion\' ...
         'Explorer\Shell Folders'],'Personal');
else
    userDir = char(java.lang.System.getProperty('user.home'));
end

global CBT_MISSING_REQUIREMENTS_ERROR_ID

if ~exist([userDir filesep 'BRENDA' filesep 'BRENDALogin.mat'],'file')
    error(CBT_MISSING_REQUIREMENTS_ERROR_ID, 'Need to Access the BRENDA database but no login details were available.\nTo provide login details please save a ''username'' and a ''password'' to %s%sBRENDALogin.mat',userDir,filesep);
end
login = load([userDir filesep 'BRENDA' filesep 'BRENDALogin.mat']);

fprintf('Testing the BRENDA client ... \n');
% test all functions of the BrendaClient
bclient = startBRENDAClient(login.username,login.password);

% We cannot test all the different methods, but since they are
% auto-generated they should be ok.... 

% Now, test some explicit functions.
res = bclient.getEcNumbersFromSequence();
assert(iscell(res));
% we allow some changes...
assert(numel(res)>= 5000);

% get a struct
res = bclient.getKmValue('ecnumber','1.2.3.4');
assert(isfield(res,'kmValue'))
assert(isfield(res,'organism'))
assert(isfield(res,'commentary'))

fprintf('Done\n\n');