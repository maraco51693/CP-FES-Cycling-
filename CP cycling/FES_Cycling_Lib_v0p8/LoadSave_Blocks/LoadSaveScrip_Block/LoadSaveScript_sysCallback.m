function status = LoadSaveScript_sysCallback(block_ref, op)
%status = LoadSaveScript_sysCallback(block_ref, op)
% This is to be called from simulink block callbacks for loading
% parameter variables used in the model and for saving data
% after. The argument block_ref should be the pathname to the
% block being used (eg gcb) and the argument op should be which
% opperation to perform.
%
% Benjamin A Saunders 29th Mar 2004

% Updates
% 29 June 2004: Benjamin A Saunders
%    Added the op argument so that this function can be used for
%    multiple callbacks.
% 20 July 2006: Benjamin A Saunders
%    Simplified the block to deal with m files and to make it
%    more flexable than the previouse version.

%disp(['Debugging (', block_ref, '): Current op = ', num2str(op)]);


% ---------------------------------------------------------------
% OP Switch Box

switch(op)
case 1, % LoadFcn
	status = load_fcn(block_ref);
case 11, % OpenFcn
	status = open_fcn(block_ref);
case 2, % InitFcn
	status = init_fcn(block_ref);
case 3, % StopFcn
	status = stop_fcn(block_ref);
otherwise
	disp(['Warning (', mfilename, ', ', block_ref, '): Invalid op argument.']);
	status = [];
end


% ===============================================================
function s = load_fcn(block_ref)

s = 1;

% -------------------------------------
% If this block is in a library then don't run this load function
try
    if ~strcmp(get_param(bdroot, 'BlockDiagramType'), 'model')
        return;
    end
end

% -------------------------------------
% Remember the Original Path
original_path = pwd;

% -------------------------------------
% If Parameter_Files Directory Exists Then Look There
try cd('Parameter_Files'); end;

% -------------------------------------
% While Invalid Parameter File has Been Loaded Repeat
s = -1;
while s == -1
    
    % Get the parameter file name from the user
    [fname, pname] = uigetfile('*.m','Run Parameter File');
    
    % If user pressed the cancel button then don't load any parameter file.
    if fname == 0
		
        disp([' ']);
        disp(['Warning (', block_ref, '): No parameter file loaded !!']);
        disp([' ']);
		
		% return to the original path
        cd(original_path);
		
		set_param(block_ref, 'UserData', '');
		%set_param(block_ref, 'MaskDisplay', ['text(0.5,0.5,''? ? ? ? ? ?'', ''VerticalAlignment'', ''middle'', ''HorizontalAlignment'', ''center'')']);
		set_param(block_ref, 'MaskDisplay', ['text(0.5,0.5,''? ? ? ? ? ?'', ''VerticalAlignment'', ''middle'', ''HorizontalAlignment'', ''center''); text(0.02,0.98,''m-script'', ''VerticalAlignment'', ''top'', ''HorizontalAlignment'', ''left'')']);
		
        s = -1;
        return;
    end
    
    % Try running the parameter file
    try
        evalin('base', ['run(''', pname, fname, ''');']);
        evalin('base', ['parameter_filename = ''', pname, fname, ''';']);
        s = 1;
    catch
        s = -1;
		disp(['Warning (', mfilename, '): Problem running the parameter file! ', lasterr]);
		cd(original_path);
		return;
    end
    
end

% Save Parameter File Name in Current System UserData
set_param(block_ref, 'UserData', [pname, fname]);

% Return to the Original Path
cd(original_path);

% Set the display of the block to show the file name being used
set_param(block_ref, 'MaskDisplay', ['text(0.5,0.5,''', fname, ''', ''VerticalAlignment'', ''middle'', ''HorizontalAlignment'', ''center''); text(0.02,0.98,''m-script'', ''VerticalAlignment'', ''top'', ''HorizontalAlignment'', ''left'')']);


% ===============================================================
function s = open_fcn(block_ref)

s = 1;

% -------------------------------------
% Remember the Original Path
original_path = pwd;

% -------------------------------------
% Get the current file name and path
current_file = get_param(block_ref, 'UserData');

if ~isempty(current_file)
    % Extract just the file parts
    [path, name, ext, versn] = fileparts(current_file);
    name = [name, ext];
    try
        % Go to the same path as the origianl file
        cd(path);
    catch
        try cd('Parameter_Files'); end
        name = '';
    end
else
    try cd('Parameter_Files'); end
    name = '';
end

% -------------------------------------
% While Invalid Parameter File has Been Loaded Repeat
s = -1;
while s == -1
    
    % Get the parameter file name from the user
    [fname, pname] = uigetfile('*.m','Run Parameter File', name);
    
    % If user pressed the cancel button then don't load any parameter file.
    if fname == 0
		
        disp([' ']);
        disp(['Warning (', block_ref, '): No parameter file loaded !!']);
        disp([' ']);
		
		% return to the original path
        cd(original_path);
		
		set_param(block_ref, 'UserData', '');
		set_param(block_ref, 'MaskDisplay', ['text(0.5,0.5,''? ? ? ? ? ?'', ''VerticalAlignment'', ''middle'', ''HorizontalAlignment'', ''center''); text(0.02,0.98,''m-script'', ''VerticalAlignment'', ''top'', ''HorizontalAlignment'', ''left'')']);
		
        s = -1;
        return;
    end
    
    % Try running the parameter file
    try
        evalin('base', ['run(''', pname, fname, ''');']);
        evalin('base', ['parameter_filename = ''', pname, fname, ''';']);
        s = 1;
    catch
        s = -1;
		disp(['Warning (', mfilename, '): Problem running the parameter file! ', lasterr]);
		cd(original_path);
		return;
    end
    
end

% Return to the Original Path
cd(original_path);

% Save Parameter File Name in Current System UserData
set_param(block_ref, 'UserData', [pname, fname]);

% Set the display of the block to show the file name being used
set_param(block_ref, 'MaskDisplay', ['text(0.5,0.5,''', fname, ''', ''VerticalAlignment'', ''middle'', ''HorizontalAlignment'', ''center''); text(0.02,0.98,''m-script'', ''VerticalAlignment'', ''top'', ''HorizontalAlignment'', ''left'')']);


% ===============================================================
function s = init_fcn(block_ref)

s = 1;

% -------------------------------------
% Get the name (and path) of the parameter file
pathname = get_param(block_ref, 'UserData');

% -------------------------------------
% Run the parameter file
try evalin('base', ['run(''', pathname, ''');']);
   evalin('base', ['parameter_filename = ''', pathname, ''';']);
catch
	set_param(gcb, 'MaskDisplay', ['text(0.5,0.5,''Error'', ''VerticalAlignment'', ''middle'', ''HorizontalAlignment'', ''center'')']);
	s = -1;
	disp(['Warning (', block_ref, '): Error running parameter file. ', lasterr]);
	error(lasterr);
	return;
end

% -------------------------------------
% Extract just the parameter file name
[path, name, ext, versn] = fileparts(pathname);

% -------------------------------------
% Set the display of the block to show the file name being used
set_param(block_ref, 'MaskDisplay', ['text(0.5,0.5,''', name, '.', ext, ''', ''VerticalAlignment'', ''middle'', ''HorizontalAlignment'', ''center''); text(0.02,0.98,''m-script'', ''VerticalAlignment'', ''top'', ''HorizontalAlignment'', ''left'')']);


% ===============================================================
function s = stop_fcn(block_ref)

s = 1;

% -------------------------------------
% Determine the model root
mdl_root = bdroot(block_ref);

% -------------------------------------
% Check if the model ends before it starts
% i.e. the stimulation time is the same as
% the start time (then there was obviously
% an error and no simulation data has been
% generated so we don't need to save
% anything.

% to do

%disp(['Debugging (', mfilename, '): Model time ', num2str(get_param(mdl_root, 'SimulationTime'), '%4.2f'), ', (while start time = ', get_param(mdl_root, 'StartTime'), ')']);
% note that get_param(mdl_root, 'StartTime') may return a
% variable name or a function name rather than just a number.


% -------------------------------------
% Remember the Original Path
original_path = pwd;

% -------------------------------------
% If Results Directory Exists Then Save There
try cd('Results'); end;

% -------------------------------------
% Generate a File Name.

% Use the system root name followed by the date
% as a temporary name:
fname = mdl_root;

% Add Date (in reverse order)
fname = [fname, '_', datestr(date, 'yy'), datestr(date, 'mm'), datestr(date, 'dd')];

% -------------------------------------
% Preperation of Restults:

% No preperation at this time --- to do later (maybe)

% Include details of when the test was done.
evalin('base', ['testDate = datestr(now ,''dd-mmm-yyyy HH:MM:SS'');']);


% -------------------------------------
% Save data

% Ask user to confirm name (and whether to save or not)
[fname, pname] = uiputfile([fname, '.mat'], 'Save Results');
if isequal(fname,0)|isequal(pname,0)
    disp([' ']);
    disp(['Warning (', block_ref, '): Data not saved!!']);
    disp([' ']);
    cd(original_path); % return to the original path
    s = -1;
    return;
else
    evalin('base', ['save(''', pname, fname, ''');']);
    disp(['Info (', block_ref, '): Data saved to ', pname, fname]);
end

% -------------------------------------
% Return to the Original Path
cd(original_path);
s = 1;


% ===============================================================
% End of File