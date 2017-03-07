function status = rst_controller_sysCallback(block_ref, op)
%status = rst_controller_sysCallback(block_ref, op)
% This is to be called from simulink block callbacks for loading
% controller parameter variables used in the model. The argument
% block_ref should be the pathname to the block being used (eg
% gcb) and the argument op should be which opperation to perform.
%
% Benjamin A Saunders 23rd Aug 2004

% disp(['Debugging (', block_ref, '): Current op = ', num2str(op)]);


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

% Remember the Original Path
original_path = pwd;

% If Parameter_Files Directory Exists Then Look There
try cd('Controllers'); end;

% While Invalid Controller File has Been Loaded Repeat
s = -1;
while s == -1
   
   % Get the parameter file name from the user
   [fname, pname] = uigetfile('*.ctr','Load Controller File');
   
   % If user pressed the cancel button then don't load any parameter file.
   if fname == 0
      
      % return to the original path
      cd(original_path);
      
      % 		%set_param(block_ref, 'MaskDisplay', ['text(0.5,0.5,''? ? ? ? ? ?'', ''VerticalAlignment'', ''middle'', ''HorizontalAlignment'', ''center'')']);
      % 		icon_str = get_param(gcb, 'MaskDisplay');
      % 		set_param(gcb, 'MaskDisplay', icon_str);
      s = 0;
      return;
   end
   
   % Try loading the parameter file
   
   try
      % Find out how many controller data sets are in the work space
      if evalin('base', ['exist(''controller_sets'', ''var'');'])
         lngthControllerData = evalin('base', ['length(controller_sets);']);
         
         % Find the index of the controller set that matches the current block
         idx = -1;
         for i = 1 : lngthControllerData
            if strcmp(evalin('base', ['controller_sets(', num2str(i), ').block_ref;']), block_ref)
               if idx ~= -1
                  % the next error is caught by the try loop
                  error('multiple copies of this block saved in the workspace variable controller_sets.');
               end
               idx = i;
            end
         end
         
         % Was not found so add it to the end
         if idx == -1
            idx = lngthControllerData + 1;
         end
         
         evalin('base', ['controller_sets(', num2str(idx), ').block_ref = ''', block_ref, ''';']);
         evalin('base', ['controller_sets(', num2str(idx), ').controller_filename = ''', pname, fname, ''';']);
         evalin('base', ['temp = load(''', pname, fname, ''', ''-mat'');']);
         evalin('base', ['controller_sets(', num2str(idx), ').controllerData = temp.controllerData;']);
         
      else
         
         evalin('base', ['controller_sets(1).block_ref = ''', block_ref, ''';']);
         evalin('base', ['controller_sets(1).controller_filename = ''', pname, fname, ''';']);
         evalin('base', ['temp = load(''', pname, fname, ''', ''-mat'');']);
         evalin('base', ['controller_sets(1).controllerData = temp.controllerData;']);
         
      end
      s = 1;
      
   catch
      s = -1;
      %error(['Could not load controller file info: ', lasterr]);
      disp(['Error (', mfilename, '): Could not load controller file info: ', lasterr]);
   end
   
end

% Save Parameter File Name in Current System UserData
set_param(block_ref, 'UserData', [pname, fname]);

% Return to the Original Path
cd(original_path);

% Set the display of the block to show the file name being used
%set_param(block_ref, 'MaskDisplay', ['text(0.5,0.5,''', fname, ''', ''VerticalAlignment'', ''middle'', ''HorizontalAlignment'', ''center'')']);
icon_str = get_param(block_ref, 'MaskDisplay');
set_param(block_ref, 'MaskDisplay', icon_str);


% ===============================================================
function s = open_fcn(block_ref)

s = load_fcn(block_ref);


% ===============================================================
function s = init_fcn(block_ref)

s = 1;

ctr_file_name = get_param(block_ref, 'UserData');
if isempty(ctr_file_name)
   %     s = sprintf('No controller file loaded in block:\n%s', block_ref);
   %     msgbox(s, 'Controller Block Error');
   error(['No controller file loaded in block: ', block_ref]);
   s = -1;
end


% ===============================================================
function s = stop_fcn(block_ref)

s = 1;


% ===============================================================
% End of File