% The COBRAToolbox: testBRENDA.m
%
% Purpose:
%     - To test the functionality of the BRENDA database functions
%       
% Authors:
%     - Thomas Pfau Nov 2018

prepareTest('needsWebAddress','http://www.brenda-enzymes.org/soap/brenda_server.php');

% switch to the test dir
testDir = fileparts(which('testBRENDA.m'));
currentDir = cd(testDir);

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

% first clear any persistent data
clearBRENDAPersistent(true);

fprintf('Testing the BRENDA Functions ... \n');
% test all functions of the BrendaClient
bclient = startBRENDAClient(login.username,login.password);
BRENDAFolder = [testDir filesep 'BRENDA'];

% initialize the Brenda Info DB
initTime = clock();
brendaInfo = loadBRENDAInfo(BRENDAFolder);
spenttime1 = etime(clock(),initTime);
assert(isdir(BRENDAFolder))
assert(isfile([BRENDAFolder filesep 'BRENDAReg.mat']));
% and load it again (this should be much faster as it is stored in memory
initTime = clock();
brendaInfo = loadBRENDAInfo(BRENDAFolder);
spenttime2 = etime(clock(),initTime);
assert(spenttime1 > spenttime2);
% we wont download the SEQuences as they are pretty big..
fieldsToTest = setdiff(getBRENDAFields(),{'SEQ'});
initTime = clock();
brendaData = loadBRENDAData('ECNumbers',{'1.3.1.81'},'fields',fieldsToTest,'folderName',BRENDAFolder);
spenttime = etime(clock(),initTime);
% enough entries
assert(numel(brendaData.KM) > 3);
defaultFieldNames = fieldnames(getBRENDADefaultData('KM'));
% and its the correct fields.
assert(isempty(setxor(defaultFieldNames,fieldnames(brendaData.KM))));
% assert, that the file was succesfully created.
assert(exist([BRENDAFolder filesep '1.3.1.81.mat'],'file')>0)
initTime = clock();
brendaData = loadBRENDAData('ECNumbers',{'1.3.1.81'},'fields',fieldsToTest,'folderName',BRENDAFolder);
spenttime2 = etime(clock(),initTime);
% loading from memory should be much faster
assert(spenttime2 < spenttime)

% cleanup
rmdir(BRENDAFolder,'s');
cd(currentDir);

fprintf('Done\n\n');