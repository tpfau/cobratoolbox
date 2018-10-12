function initEquilibrator()
% this function tests, whether the equilibrator is installed, and tries to
% set up the correct python version.

if verLessThan('MATLAB','9.1')
   error('Python 3.6 is not supported by matlab prior to 2016b')
end

pv = pyversion;

infoString = ['Using the eQuilibrator requires python 3.6 to be installed. We strongly recommend that\n',...
              'you install python 3.6. yourself either via your system package managing (linux/mac)\n',...
              'or by downloading and installing it from https://www.python.org/downloads/release/python-366/\n',...
              'However, if you want this setup tool can download and install python for you.\n',...
              'If you want the setup tool to install python please type Yes at the prompt.\n',...
              'If you are sure that you have installed python 3.6. please enter the full path to \n',...
              'python 3.6. at the prompt.\n',...
              'If an invalid path is provided, this setup will be aborted\n'];

if str2double(pv) < 3.6
    % lets try to install python 3.6 on the system, after confirmation
    if ispc
        winURL = 'https://www.python.org/ftp/python/3.6.6/python-3.6.6.exe';
        file = websave('python3.6.exe',winURL);
        % install python
        s = input(infoString,'s');
        
    end
    
    if isunix
        % we will ask the user to do the installation himself via the
        % appropriate package manager. But if not possible, we will do it.        
        s = input(
                  
    end
    ....
    % now, assuming python is installed.
end

    