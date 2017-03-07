function varargout = LoadSaveCycleControl_GUI(varargin)
% LoadSaveCycleControl_GUI Application M-file for LoadSaveCycleControl_GUI.fig
%    FIG = LoadSaveCycleControl_GUI launch LoadSaveCycleControl_GUI GUI.
%    LoadSaveCycleControl_GUI('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 10-Jan-2005 15:38:38

if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');

	% Use system color scheme for figure:
	set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);

	if nargout > 0
		varargout{1} = fig;
	end
elseif (strcmp(varargin{1}, 'open'))  % LAUNCH GUI for loading a file

	fig = openfig(mfilename,'reuse');

	% Use system color scheme for figure:
	set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);
	
	if nargin > 2
		try % Test if arg 3 is a block reference
			if strcmp(get_param(varargin{3}, 'MaskType'), 'LoadParameterScript_SaveResults_Block')
				setappdata(handles.parameter_GUI, 'block_ref', varargin{3});
			else
				error('Not a ''LoadParameterScript_SaveResults_Block'' block reference.');
			end
		catch
			disp(lasterr);
			return;
		end
	end
	
	% Load the file
	if (exist(varargin{2}) == 2)
		load_file(handles, varargin{2});
	end
	
	if nargout > 0
		varargout{1} = fig;
	end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

	try
		if (nargout)
			[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
		else
			feval(varargin{:}); % FEVAL switchyard
		end
	catch
		disp(lasterr);
	end

end


%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and 
%| sets objects' callback properties to call them through the FEVAL 
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the 
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.

%disp(['Debugging (', mfilename,'): Got to here.']);


% --------------------------------------------------------------------
function load_file(handles, load_file_name)

% Get the name of the file to load
if exist(load_file_name) ~= 2
	disp(['Warning (', mfilename, '): File not found, ', eventdata]);
	return;
end

% Save new path and file name
%[loadfile_p loadfile_n loadfile_e loadfile_v] = fileparts(which(load_file_name));
[loadfile_p loadfile_n loadfile_e loadfile_v] = fileparts(load_file_name);
parameter_file_name.path = [loadfile_p, '\'];
parameter_file_name.name = [loadfile_n, loadfile_e];
setappdata(handles.parameter_GUI, 'save_file_name', parameter_file_name);

% Load the file
temp = load([parameter_file_name.path parameter_file_name.name], '-mat');
parameters = temp.parameters;

% Save Parameter Data
setappdata(handles.parameter_GUI, 'Parameter_Data', parameters);

% Update the display
fullDisplayUpdate(handles);

% Update the Title
set(handles.parameter_GUI_title, 'String', ['Parameters: ', parameters.test_subject.id, ' (', parameters.test_subject.center, ')'])

% Modify the Fig Name
full_parameter_file_name = [parameter_file_name.path parameter_file_name.name];
if length(full_parameter_file_name) > 75
	full_parameter_file_name = [full_parameter_file_name(1:20), '...', full_parameter_file_name(end-50:end)];
end
set(handles.parameter_GUI, 'Name', full_parameter_file_name);

% If there is a block reference then update this too
if isappdata(handles.parameter_GUI, 'block_ref')
	b_ref = getappdata(handles.parameter_GUI, 'block_ref');
	set_param(b_ref, 'UserData', [parameter_file_name.path parameter_file_name.name]);
	set_param(b_ref, 'MaskDisplay', ['text(0.5,0.5,''', parameter_file_name.name, ''', ''VerticalAlignment'', ''middle'', ''HorizontalAlignment'', ''center''); text(0.02,0.98,''prm-file'', ''VerticalAlignment'', ''top'', ''HorizontalAlignment'', ''left'');']);
    %disp(['Debugging(', mfilename,'): Updated the block.']);
end


% --------------------------------------------------------------------
function p = getParameters()

% Get the config file path and name
[cfg_path cfg_name cfg_extn cfg_vrsn] = fileparts(which(mfilename));
cfg_extn = '.cfg';
cfg_filename = [cfg_path, '\', cfg_name, cfg_extn];

if exist(cfg_filename) == 2
	p = load(cfg_filename, '-mat');
	p = p.parameters;
	return;
end
% Else we need to create a CFG file:

p = []; % start with an empty structure

p.test_subject.center = 'GLA';
p.test_subject.id = 'Config';

p.sample_time = 0.05; % used to run the main model
p.model.sample_time = 0.01; % simulation parameters sample time

p.motor_tirke_system.angle_shift = 0;

p.motor_tirke_system.frequency_to_voltage.zero_frequency  = 300; % GLA LON
p.motor_tirke_system.frequency_to_voltage.frequency_range = 700; % GLA LON
p.motor_tirke_system.SRM_conversion.ZOPM                  = 353;
%p.motor_tirke_system.SRM_conversion.slope                 = 15.75; % GLA
p.motor_tirke_system.SRM_conversion.slope                 = 20.12; % LON

p.stimulation.current.R.quad = 0;
p.stimulation.current.R.hams = 0;
p.stimulation.current.R.glut = 0;
p.stimulation.current.R.calf = 0;
p.stimulation.current.L.quad = 0;
p.stimulation.current.L.hams = 0;
p.stimulation.current.L.glut = 0;
p.stimulation.current.L.calf = 0;

p.stimulation.pulsewidth_activation.R.quad = [0 510];
p.stimulation.pulsewidth_activation.R.hams = [0 510];
p.stimulation.pulsewidth_activation.R.glut = [0 510];
p.stimulation.pulsewidth_activation.R.calf = [0 510];
p.stimulation.pulsewidth_activation.L.quad = [0 510];
p.stimulation.pulsewidth_activation.L.hams = [0 510];
p.stimulation.pulsewidth_activation.L.glut = [0 510];
p.stimulation.pulsewidth_activation.L.calf = [0 510];

% % Angles for GLA
% p.stimulation.staticAngles.R.quad = [ 55 155];
% p.stimulation.staticAngles.R.hams = [188 265];
% p.stimulation.staticAngles.R.glut = [ 90 180];
% p.stimulation.staticAngles.R.calf = [  0   1];
% p.stimulation.staticAngles.L.quad = [235 335];
% p.stimulation.staticAngles.L.hams = [  8  85];
% p.stimulation.staticAngles.L.glut = [270 360];
% p.stimulation.staticAngles.L.calf = [180 181];

% Angles for LON
p.stimulation.staticAngles.R.quad = [186 282];
p.stimulation.staticAngles.R.hams = [294  31];
p.stimulation.staticAngles.R.glut = [212 305];
p.stimulation.staticAngles.R.calf = [322  45];
p.stimulation.staticAngles.L.quad = [  6 102];
p.stimulation.staticAngles.L.hams = [113 212];
p.stimulation.staticAngles.L.glut = [ 31 124];
p.stimulation.staticAngles.L.calf = [141 226];

p.stimulation.vel_modifyer = 0.15;

p.stimulation.sample_time = 0.02;

p.stimulation.stim_chan   = [1 2 3 5 6 7];
p.stimulation.model_con   = [1 2 3 5 6 7];

p.motor_identification.total_time = 100;

p.motor_PRBS.output_limits = [50 70];
p.motor_PRBS.min_same_time = 55;
p.motor_PRBS.total_time    = p.motor_identification.total_time;
%p.motor_PRBS.ramp_slope    = 4;
%p.motor_PRBS.sample_time   = 0.05;

p.motor_control_design.orders                    = [2 2 1 1];
p.motor_control_design.control_observer_dynamics = [3 0.99];
p.motor_control_design.reference_model_dynamics  = [3 0.99];
%p.motor_control_design.sample_time               = 0.05;

p.motor_controller.input_ref = 50;
p.motor_controller.saturation_limit = [0 100];
p.motor_controller.sample_time = 0.3;

p.power_identification.total_time = 100;

p.power_PRBS.output_limits = [0.2 0.5];
p.power_PRBS.min_same_time = 60;
p.power_PRBS.total_time    = p.power_identification.total_time;
%p.power_PRBS.ramp_slope    = 40;
%p.power_PRBS.sample_time   = 0.05;

p.power_control_design.orders                    = [2 2 1 1];
p.power_control_design.control_observer_dynamics = [9 0.99];
p.power_control_design.reference_model_dynamics  = [9 0.99];
%p.power_control_design.sample_time               = 0.05;

p.power_controller.saturation_limit = [0 1];
p.power_controller.sample_time = 0.5;

parameters = p;
save(cfg_filename, 'parameters');


% --------------------------------------------------------------------
function fullDisplayUpdate(handles)

% Load Parameter Data
parameters = getappdata(handles.parameter_GUI, 'Parameter_Data');
if isempty(parameters)
	msgbox('No file has be loaded yet.','No File Loaded','error');
	return;
end

set(handles.se_offset, 'String', num2str(parameters.motor_tirke_system.angle_shift));
set(handles.srm_zopm, 'String', num2str(parameters.motor_tirke_system.SRM_conversion.ZOPM));

set(handles.current_r_q, 'String', num2str(parameters.stimulation.current.R.quad));
set(handles.current_r_h, 'String', num2str(parameters.stimulation.current.R.hams));
set(handles.current_r_g, 'String', num2str(parameters.stimulation.current.R.glut));
set(handles.current_r_c, 'String', num2str(parameters.stimulation.current.R.calf));
set(handles.current_l_q, 'String', num2str(parameters.stimulation.current.L.quad));
set(handles.current_l_h, 'String', num2str(parameters.stimulation.current.L.hams));
set(handles.current_l_g, 'String', num2str(parameters.stimulation.current.L.glut));
set(handles.current_l_c, 'String', num2str(parameters.stimulation.current.L.calf));

set(handles.pwa_r_q, 'String', ['[', num2str(parameters.stimulation.pulsewidth_activation.R.quad), ']']);
set(handles.pwa_r_h, 'String', ['[', num2str(parameters.stimulation.pulsewidth_activation.R.hams), ']']);
set(handles.pwa_r_g, 'String', ['[', num2str(parameters.stimulation.pulsewidth_activation.R.glut), ']']);
set(handles.pwa_r_c, 'String', ['[', num2str(parameters.stimulation.pulsewidth_activation.R.calf), ']']);
set(handles.pwa_l_q, 'String', ['[', num2str(parameters.stimulation.pulsewidth_activation.L.quad), ']']);
set(handles.pwa_l_h, 'String', ['[', num2str(parameters.stimulation.pulsewidth_activation.L.hams), ']']);
set(handles.pwa_l_g, 'String', ['[', num2str(parameters.stimulation.pulsewidth_activation.L.glut), ']']);
set(handles.pwa_l_c, 'String', ['[', num2str(parameters.stimulation.pulsewidth_activation.L.calf), ']']);

set(handles.angles_r_q, 'String', ['[', num2str(parameters.stimulation.staticAngles.R.quad), ']']);
set(handles.angles_r_h, 'String', ['[', num2str(parameters.stimulation.staticAngles.R.hams), ']']);
set(handles.angles_r_g, 'String', ['[', num2str(parameters.stimulation.staticAngles.R.glut), ']']);
set(handles.angles_r_c, 'String', ['[', num2str(parameters.stimulation.staticAngles.R.calf), ']']);
set(handles.angles_l_q, 'String', ['[', num2str(parameters.stimulation.staticAngles.L.quad), ']']);
set(handles.angles_l_h, 'String', ['[', num2str(parameters.stimulation.staticAngles.L.hams), ']']);
set(handles.angles_l_g, 'String', ['[', num2str(parameters.stimulation.staticAngles.L.glut), ']']);
set(handles.angles_l_c, 'String', ['[', num2str(parameters.stimulation.staticAngles.L.calf), ']']);

switch(parameters.stimulation.sample_time)
case 0.01, set(handles.stim_freq, 'Value', 5);
case 0.02, set(handles.stim_freq, 'Value', 4);
case 0.03, set(handles.stim_freq, 'Value', 3);
case 0.04, set(handles.stim_freq, 'Value', 2);
case 0.05, set(handles.stim_freq, 'Value', 1);
otherwise
	error('Stimulation sample time is incorrectly set.');
end

i = find(parameters.stimulation.model_con == 1); if length(i) > 1 error('Multiple model channel indexes.'); end;
if length(i) == 0 set(handles.channel_r_q, 'String', 'x'); else set(handles.channel_r_q, 'String', num2str(parameters.stimulation.stim_chan(i))); end;
i = find(parameters.stimulation.model_con == 2); if length(i) > 1 error('Multiple model channel indexes.'); end;
if length(i) == 0 set(handles.channel_r_h, 'String', 'x'); else set(handles.channel_r_h, 'String', num2str(parameters.stimulation.stim_chan(i))); end;
i = find(parameters.stimulation.model_con == 3); if length(i) > 1 error('Multiple model channel indexes.'); end;
if length(i) == 0 set(handles.channel_r_g, 'String', 'x'); else set(handles.channel_r_g, 'String', num2str(parameters.stimulation.stim_chan(i))); end;
i = find(parameters.stimulation.model_con == 4); if length(i) > 1 error('Multiple model channel indexes.'); end;
if length(i) == 0 set(handles.channel_r_c, 'String', 'x'); else set(handles.channel_r_c, 'String', num2str(parameters.stimulation.stim_chan(i))); end;
i = find(parameters.stimulation.model_con == 5); if length(i) > 1 error('Multiple model channel indexes.'); end;
if length(i) == 0 set(handles.channel_l_q, 'String', 'x'); else set(handles.channel_l_q, 'String', num2str(parameters.stimulation.stim_chan(i))); end;
i = find(parameters.stimulation.model_con == 6); if length(i) > 1 error('Multiple model channel indexes.'); end;
if length(i) == 0 set(handles.channel_l_h, 'String', 'x'); else set(handles.channel_l_h, 'String', num2str(parameters.stimulation.stim_chan(i))); end;
i = find(parameters.stimulation.model_con == 7); if length(i) > 1 error('Multiple model channel indexes.'); end;
if length(i) == 0 set(handles.channel_l_g, 'String', 'x'); else set(handles.channel_l_g, 'String', num2str(parameters.stimulation.stim_chan(i))); end;
i = find(parameters.stimulation.model_con == 8); if length(i) > 1 error('Multiple model channel indexes.'); end;
if length(i) == 0 set(handles.channel_l_c, 'String', 'x'); else set(handles.channel_l_c, 'String', num2str(parameters.stimulation.stim_chan(i))); end;

set(handles.motor_prbs_minmax, 'String', ['[', num2str(parameters.motor_PRBS.output_limits), ']']);
set(handles.motor_ident_orders, 'String', ['[', num2str(parameters.motor_control_design.orders), ']']);
set(handles.motor_contr_dyn, 'String', ['[', num2str(parameters.motor_control_design.reference_model_dynamics), ']']);
set(handles.motor_obsr_dyn, 'String', ['[', num2str(parameters.motor_control_design.control_observer_dynamics), ']']);
set(handles.motor_act_lims, 'String', ['[', num2str(parameters.motor_controller.saturation_limit), ']']);
set(handles.motor_contr_stime, 'String', num2str(parameters.motor_controller.sample_time));

set(handles.power_prbs_minmax, 'String', ['[', num2str(parameters.power_PRBS.output_limits), ']']);
set(handles.power_ident_orders, 'String', ['[', num2str(parameters.power_control_design.orders), ']']);
set(handles.power_obsr_dyn, 'String', ['[', num2str(parameters.power_control_design.reference_model_dynamics), ']']);
set(handles.power_contr_dyn, 'String', ['[', num2str(parameters.power_control_design.control_observer_dynamics), ']']);
set(handles.power_act_lims, 'String', ['[', num2str(parameters.power_controller.saturation_limit), ']']);
set(handles.power_contr_stime, 'String', num2str(parameters.power_controller.sample_time));


% --------------------------------------------------------------------
function varargout = editboxes_Callbacks(h, eventdata, handles, varargin)

% Load Parameter Data
parameters = getappdata(handles.parameter_GUI, 'Parameter_Data');
if isempty(parameters)
	msgbox('No file has be loaded yet.','No File Loaded','error');
	return;
end

value = get(gcbo, 'String');
value = str2num(value);
if (isempty(value) & (sum(eventdata == [31:38]) == 0))
	msgbox('Value could not be read properly.','Invalid Entry','warn');
	% Get the old value back
	fullDisplayUpdate(handles);
	return;
end

switch(eventdata)
case 1   % current r q
	parameters.stimulation.current.R.quad = value;
case 2   % current r h
	parameters.stimulation.current.R.hams = value;
case 3   % current r g
	parameters.stimulation.current.R.glut = value;
case 4   % current r c
	parameters.stimulation.current.R.calf = value;
case 5   % current l q
	parameters.stimulation.current.L.quad = value;
case 6   % current l h
	parameters.stimulation.current.L.hams = value;
case 7   % current l g
	parameters.stimulation.current.L.glut = value;
case 8   % current l c
	parameters.stimulation.current.L.calf = value;
case 11   % pwa r q
	parameters.stimulation.pulsewidth_activation.R.quad = value;
case 12   % pwa r h
	parameters.stimulation.pulsewidth_activation.R.hams = value;
case 13   % pwa r g
	parameters.stimulation.pulsewidth_activation.R.glut = value;
case 14   % pwa r c
	parameters.stimulation.pulsewidth_activation.R.calf = value;
case 15   % pwa l q
	parameters.stimulation.pulsewidth_activation.L.quad = value;
case 16   % pwa l h
	parameters.stimulation.pulsewidth_activation.L.hams = value;
case 17   % pwa l g
	parameters.stimulation.pulsewidth_activation.L.glut = value;
case 18   % pwa l c
	parameters.stimulation.pulsewidth_activation.L.calf = value;
case 21   % angles r q
	parameters.stimulation.staticAngles.R.quad = value;
case 22  % angles r h
	parameters.stimulation.staticAngles.R.hams = value;
case 23  % angles r g
	parameters.stimulation.staticAngles.R.glut = value;
case 24  % angles r c
	parameters.stimulation.staticAngles.R.calf = value;
case 25  % angles l q
	parameters.stimulation.staticAngles.L.quad = value;
case 26  % angles l h
	parameters.stimulation.staticAngles.L.hams = value;
case 27  % angles l g
	parameters.stimulation.staticAngles.L.glut = value;
case 28  % angles l c
	parameters.stimulation.staticAngles.L.calf = value;
case {31, 32, 33, 34, 35, 36, 37, 38}  % channels
	i = find(parameters.stimulation.model_con == eventdata-30);
	if length(i) > 1 error('Multiple model channel connections.'); end;
	if length(i) == 0 % need to add to list
		if ~isempty(value) % as long as its a proper value
			parameters.stimulation.model_con(end+1) = eventdata-30;
			parameters.stimulation.stim_chan(end+1) = value;
			[parameters.stimulation.model_con sorted_i] = sort(parameters.stimulation.model_con);
			parameters.stimulation.stim_chan = parameters.stimulation.stim_chan(sorted_i);
		end
	else
		if isempty(value) % remove from model_con
			parameters.stimulation.model_con = [parameters.stimulation.model_con(1:i-1) parameters.stimulation.model_con(i+1:end)];
			parameters.stimulation.stim_chan = [parameters.stimulation.stim_chan(1:i-1) parameters.stimulation.stim_chan(i+1:end)];
		else % just need to change stim_chan
			parameters.stimulation.stim_chan(i) = value;
		end
	end
case 101 % se_offset
	parameters.motor_tirke_system.angle_shift = value;
case 102 % srm_zopm
	parameters.motor_tirke_system.SRM_conversion.ZOPM = value;
case 201 % motor prbs limits
	parameters.motor_PRBS.output_limits = value;
case 202 % motor ident orders
	parameters.motor_control_design.orders = value;
case 203 % motor controller dynamics
	parameters.motor_control_design.reference_model_dynamics = value;
case 204 % motor observer dynamics
	parameters.motor_control_design.control_observer_dynamics = value;
case 205 % motor controller sample time
	parameters.motor_controller.sample_time = value;
case 206 % motor actuator limits
   parameters.motor_controller.saturation_limit = value;
case 301 % power prbs limits
	parameters.power_PRBS.output_limits = value;
case 302 % power ident orders
	parameters.power_control_design.orders = value;
case 303 % power controller dynamics
	parameters.power_control_design.reference_model_dynamics = value;
case 304 % power observer dynamics
	parameters.power_control_design.control_observer_dynamics = value;
case 305 % power controller sample time
	parameters.power_controller.sample_time = value;
case 306 % motor actuator limits
   parameters.power_controller.saturation_limit = value;
otherwise
	error('Invalid editboxes_Callbacks event.');
end

% Save new parameter value
setappdata(handles.parameter_GUI, 'Parameter_Data', parameters);

% Add a * to end of file name if needed
parameter_file_name = get(handles.parameter_GUI, 'Name');
if parameter_file_name(end) ~= '*'
	set(handles.parameter_GUI, 'Name', [parameter_file_name, '*']);
end;


% --------------------------------------------------------------------
function varargout = stim_freq_Callback(h, eventdata, handles, varargin)

% Load Parameter Data
parameters = getappdata(handles.parameter_GUI, 'Parameter_Data');
if isempty(parameters)
	msgbox('No file has be loaded yet.','No File Loaded','error');
	return;
end

% Update stimulation frequency parameter
choice = get(handles.stim_freq, 'Value');
switch choice
case 1, parameters.stimulation.sample_time = 0.05; % 20 Hz
case 2, parameters.stimulation.sample_time = 0.04; % 25 Hz
case 3, parameters.stimulation.sample_time = 0.03; % 33.3 Hz
case 4, parameters.stimulation.sample_time = 0.02; % 50 Hz
case 5, parameters.stimulation.sample_time = 0.01; % 100 Hz
otherwise, error('Unkown frequency for stimulation.');
end

% Save new parameter value
setappdata(handles.parameter_GUI, 'Parameter_Data', parameters);

% Add a * to end of file name if needed
parameter_file_name = get(handles.parameter_GUI, 'Name');
if parameter_file_name(end) ~= '*'
	set(handles.parameter_GUI, 'Name', [parameter_file_name, '*']);
end;


% --------------------------------------------------------------------
function varargout = close_but_Callback(h, eventdata, handles, varargin)

% Close the GUI
close(handles.parameter_GUI);


% --------------------------------------------------------------------
function varargout = save_but_Callback(h, eventdata, handles, varargin)

% Load Parameter Data
parameters = getappdata(handles.parameter_GUI, 'Parameter_Data');
if isempty(parameters)
	msgbox('No file has be loaded yet.','No File Loaded','error');
	return;
end

% Get the parameter file name
parameter_file_name = getappdata(handles.parameter_GUI, 'save_file_name');
full_parameter_file_name = [parameter_file_name.path parameter_file_name.name];

% Save current path and try to access the file path
current_pwd = pwd;
try cd(parameter_file_name.path); end;

% Ask to confirm file name or get a new one
[new_fname, new_pname] = uiputfile(parameter_file_name.name,'Save Parameter File');

% Check that cancel was not pressed
if isnumeric(new_fname) cd(current_pwd); return; end;

% Check to make sure if a file extension is needed
[p, n, e, v] = fileparts([new_pname, new_fname]);
if isempty(e) new_fname = [new_fname, '.prm']; end

% Save new path and file name
parameter_file_name.path = new_pname;
parameter_file_name.name = new_fname;
setappdata(handles.parameter_GUI, 'save_file_name', parameter_file_name);

% Save the file
save([parameter_file_name.path parameter_file_name.name], 'parameters');

% Return to the original path
cd(current_pwd);

% Modify the Fig Name
full_parameter_file_name = [parameter_file_name.path parameter_file_name.name];
if length(full_parameter_file_name) > 75
	full_parameter_file_name = [full_parameter_file_name(1:20), '...', full_parameter_file_name(end-50:end)];
end
set(handles.parameter_GUI, 'Name', full_parameter_file_name);

% If there is a block reference then update this too
if isappdata(handles.parameter_GUI, 'block_ref')
	b_ref = getappdata(handles.parameter_GUI, 'block_ref');
	set_param(b_ref, 'UserData', [parameter_file_name.path parameter_file_name.name]);
	set_param(b_ref, 'MaskDisplay', ['text(0.5,0.5,''', parameter_file_name.name, ''', ''VerticalAlignment'', ''middle'', ''HorizontalAlignment'', ''center''); text(0.02,0.98,''prm-file'', ''VerticalAlignment'', ''top'', ''HorizontalAlignment'', ''left'');']);
end


% --------------------------------------------------------------------
function varargout = file_menu_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = new_menu_Callback(h, eventdata, handles, varargin)

% Check for existing data
current_file_name = get(handles.parameter_GUI, 'Name');
if current_file_name(end) == '*'
	button = questdlg('Warning, existing data will be lost. Do you want to continue?','Creat New File','Yes','Cancel','Cancel');
	if strcmp(button, 'Cancel')
		return;
	end
end

parameters = getParameters;

% Get Centre and test subject id info
details = inputdlg({'Centre: ', 'Test subject ID: '}, 'Input Subject Details', 1, ...
	{parameters.test_subject.center, 'NoName'});
if isempty(details)
	return;
end

parameters.test_subject.center = details{1};
parameters.test_subject.id     = details{2};

% Get srm and freq. to volt. converter info
keep_trying = 1;
while keep_trying
	details = inputdlg({'Frequency to voltage zero frequency: ', 'Frequency to voltage frequency range: ', ...
			'SRM conversion slope (on back of SRM): '},'SRM Details',1, ...
		{num2str(parameters.motor_tirke_system.frequency_to_voltage.zero_frequency), ...
			num2str(parameters.motor_tirke_system.frequency_to_voltage.frequency_range), ...
			num2str(parameters.motor_tirke_system.SRM_conversion.slope)});
	if isempty(details)
		return;
	end
	if (~isempty(str2num(details{1})) & ~isempty(str2num(details{2})) & ~isempty(str2num(details{3})))
		keep_trying = 0;
	end
end

parameters.motor_tirke_system.frequency_to_voltage.zero_frequency  = str2num(details{1});
parameters.motor_tirke_system.frequency_to_voltage.frequency_range = str2num(details{2});
parameters.motor_tirke_system.SRM_conversion.slope                 = str2num(details{3});

% Save Parameter Data
setappdata(handles.parameter_GUI, 'Parameter_Data', parameters);

% Update the display
fullDisplayUpdate(handles);

% Update the Title
set(handles.parameter_GUI_title, 'String', ['Parameters: ', parameters.test_subject.id, ' (', parameters.test_subject.center, ')'])

% Generate File Name
parameter_file_name.name = [parameters.test_subject.center, '_', parameters.test_subject.id, '_Params.prm'];
parameter_file_name.path = [pwd, '\Parameter_Files\'];

% Save Parameter file name
setappdata(handles.parameter_GUI, 'save_file_name', parameter_file_name);

% Modify the Fig Name
full_parameter_file_name = [parameter_file_name.path parameter_file_name.name, '*'];
if length(full_parameter_file_name) > 75
	full_parameter_file_name = [full_parameter_file_name(1:20), '...', full_parameter_file_name(end-50:end)];
end
set(handles.parameter_GUI, 'Name', full_parameter_file_name);


% --------------------------------------------------------------------
function varargout = load_menu_Callback(h, eventdata, handles, varargin)

% Check for existing data
current_file_name = get(handles.parameter_GUI, 'Name');
if current_file_name(end) == '*'
	button = questdlg('Warning, existing data will be lost. Do you want to continue?','Creat New File','Yes','Cancel','Cancel');
	if strcmp(button, 'Cancel')
		return;
	end
end

current_pwd = pwd;
try cd('Parameter_Files'); end;

% Ask for a file name
[new_fname, new_pname] = uigetfile('*.prm','Load Parameter File');

% Return to original directory
cd(current_pwd);

% Check that cancel was not pressed
if isnumeric(new_fname) cd(current_pwd); return; end;

load_file(handles, [new_pname, new_fname]);


% --------------------------------------------------------------------
function varargout = save_menu_Callback(h, eventdata, handles, varargin)

% Load Parameter Data
parameters = getappdata(handles.parameter_GUI, 'Parameter_Data');
if isempty(parameters)
	msgbox('No file has be loaded yet.','No File Loaded','error');
	return;
end

% Get the parameter file name
parameter_file_name = getappdata(handles.parameter_GUI, 'save_file_name');
full_parameter_file_name = [parameter_file_name.path parameter_file_name.name];

% Save current path and try to access the file path
current_pwd = pwd;
try cd(parameter_file_name.path); end;

% Ask to confirm file name or get a new one
[new_fname, new_pname] = uiputfile(parameter_file_name.name,'Save Parameter File');

% Check that cancel was not pressed
if isnumeric(new_fname) cd(current_pwd); return; end;

% Check to make sure if a file extension is needed
[p, n, e, v] = fileparts([new_pname, new_fname]);
if isempty(e) new_fname = [new_fname, '.prm']; end

% Save new path and file name
parameter_file_name.path = new_pname;
parameter_file_name.name = new_fname;
setappdata(handles.parameter_GUI, 'save_file_name', parameter_file_name);

% Save the file
save([parameter_file_name.path parameter_file_name.name], 'parameters');

% Return to the original path
cd(current_pwd);

% Modify the Fig Name
full_parameter_file_name = [parameter_file_name.path parameter_file_name.name];
if length(full_parameter_file_name) > 75
	full_parameter_file_name = [full_parameter_file_name(1:20), '...', full_parameter_file_name(end-50:end)];
end
set(handles.parameter_GUI, 'Name', full_parameter_file_name);

% If there is a block reference then update this too
if isappdata(handles.parameter_GUI, 'block_ref')
	b_ref = getappdata(handles.parameter_GUI, 'block_ref');
	set_param(b_ref, 'UserData', [parameter_file_name.path parameter_file_name.name]);
	set_param(b_ref, 'MaskDisplay', ['text(0.5,0.5,''', parameter_file_name.name, ''', ''VerticalAlignment'', ''middle'', ''HorizontalAlignment'', ''center''); text(0.02,0.98,''prm-file'', ''VerticalAlignment'', ''top'', ''HorizontalAlignment'', ''left'');']);
end


% --------------------------------------------------------------------
function varargout = advanced_menu_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = stim_as_bits_menu_Callback(h, eventdata, handles, varargin)

% Load Parameter Data
parameters = getappdata(handles.parameter_GUI, 'Parameter_Data');
if isempty(parameters)
	msgbox('No file has be loaded yet.','No File Loaded','error');
	return;
end

% Get srm and freq. to volt. converter info
keep_trying = 1;
while keep_trying
	details = inputdlg({'Right Quad: ', 'Right Ham: ', 'Right Glut: ', 'Right Calf: ', ...
			'Left Quad: ', 'Left Ham: ', 'Left Glut: ', 'Left Calf: '}, ...
		'Static Stimulation Angles as Bytes (0-255)', 1, ...
		{['[', num2str(round((parameters.stimulation.staticAngles.R.quad.*255)./360)), ']'], ...
			['[', num2str(round((parameters.stimulation.staticAngles.R.hams.*255)./360)), ']'], ...
			['[', num2str(round((parameters.stimulation.staticAngles.R.glut.*255)./360)), ']'], ...
			['[', num2str(round((parameters.stimulation.staticAngles.R.calf.*255)./360)), ']'], ...
			['[', num2str(round((parameters.stimulation.staticAngles.L.quad.*255)./360)), ']'], ...
			['[', num2str(round((parameters.stimulation.staticAngles.L.hams.*255)./360)), ']'], ...
			['[', num2str(round((parameters.stimulation.staticAngles.L.glut.*255)./360)), ']'], ...
			['[', num2str(round((parameters.stimulation.staticAngles.L.calf.*255)./360)), ']']});
	if isempty(details)
		return;
	end
	if (~isempty(str2num(details{1})) & ~isempty(str2num(details{2})) & ~isempty(str2num(details{3})) & ~isempty(str2num(details{4})) & ...
			~isempty(str2num(details{5})) & ~isempty(str2num(details{6})) & ~isempty(str2num(details{7})) & ~isempty(str2num(details{8})))
		keep_trying = 0;
	end
end

parameters.stimulation.staticAngles.R.quad = round((360.*str2num(details{1}))./255);
parameters.stimulation.staticAngles.R.hams = round((360.*str2num(details{2}))./255);
parameters.stimulation.staticAngles.R.glut = round((360.*str2num(details{3}))./255);
parameters.stimulation.staticAngles.R.calf = round((360.*str2num(details{4}))./255);
parameters.stimulation.staticAngles.L.quad = round((360.*str2num(details{5}))./255);
parameters.stimulation.staticAngles.L.hams = round((360.*str2num(details{6}))./255);
parameters.stimulation.staticAngles.L.glut = round((360.*str2num(details{7}))./255);
parameters.stimulation.staticAngles.L.calf = round((360.*str2num(details{8}))./255);

% Save Parameter Data
setappdata(handles.parameter_GUI, 'Parameter_Data', parameters);

% Update the display
fullDisplayUpdate(handles);

% Set file modified *
current_file_name = get(handles.parameter_GUI, 'Name');
if current_file_name(end) ~= '*'
	current_file_name(end+1) = '*';
	set(handles.parameter_GUI, 'Name', current_file_name);
end


% --------------------------------------------------------------------
function varargout = srm_menu_Callback(h, eventdata, handles, varargin)

% Load Parameter Data
parameters = getappdata(handles.parameter_GUI, 'Parameter_Data');
if isempty(parameters)
	msgbox('No file has be loaded yet.','No File Loaded','error');
	return;
end

% Get srm and freq. to volt. converter info
keep_trying = 1;
while keep_trying
	details = inputdlg({'Frequency to voltage zero frequency: ', 'Frequency to voltage frequency range: ', ...
			'SRM conversion slope (on back of SRM): '},'SRM Details',1, ...
		{num2str(parameters.motor_tirke_system.frequency_to_voltage.zero_frequency), ...
			num2str(parameters.motor_tirke_system.frequency_to_voltage.frequency_range), ...
			num2str(parameters.motor_tirke_system.SRM_conversion.slope)});
	if isempty(details)
		return;
	end
	if (~isempty(str2num(details{1})) & ~isempty(str2num(details{2})) & ~isempty(str2num(details{3})))
		keep_trying = 0;
	end
end

parameters.motor_tirke_system.frequency_to_voltage.zero_frequency  = str2num(details{1});
parameters.motor_tirke_system.frequency_to_voltage.frequency_range = str2num(details{2});
parameters.motor_tirke_system.SRM_conversion.slope                 = str2num(details{3});

% Save Parameter Data
setappdata(handles.parameter_GUI, 'Parameter_Data', parameters);

% Set file modified *
current_file_name = get(handles.parameter_GUI, 'Name');
if current_file_name(end) ~= '*'
	current_file_name(end+1) = '*';
	set(handles.parameter_GUI, 'Name', current_file_name);
end


% --------------------------------------------------------------------
function varargout = subject_menu_Callback(h, eventdata, handles, varargin)

% Load Parameter Data
parameters = getappdata(handles.parameter_GUI, 'Parameter_Data');
if isempty(parameters)
	msgbox('No file has be loaded yet.','No File Loaded','error');
	return;
end

% Get Centre and test subject id info
details = inputdlg({'Centre: ', 'Test subject ID: '}, 'Input Subject Details', 1, ...
	{parameters.test_subject.center, parameters.test_subject.id});
if isempty(details)
	return;
end

parameters.test_subject.center = details{1};
parameters.test_subject.id     = details{2};

% Save Parameter Data
setappdata(handles.parameter_GUI, 'Parameter_Data', parameters);

% Save New Parameter file name
parameter_file_name = getappdata(handles.parameter_GUI, 'save_file_name');
parameter_file_name.name = [parameters.test_subject.center, '_', parameters.test_subject.id, '_Params.prm'];
setappdata(handles.parameter_GUI, 'save_file_name', parameter_file_name);

% Update the Title
set(handles.parameter_GUI_title, 'String', ['Parameters: ', parameters.test_subject.id, ' (', parameters.test_subject.center, ')'])

% Generate File Name
parameter_file_name = [pwd, '\', parameters.test_subject.center, '_', parameters.test_subject.id, '_Params.prm*'];
if length(parameter_file_name) > 75
	parameter_file_name = [parameter_file_name(1:20), '...', parameter_file_name(end-50:end)];
end
set(handles.parameter_GUI, 'Name', parameter_file_name);

% Set file modified *
current_file_name = get(handles.parameter_GUI, 'Name');
if current_file_name(end) ~= '*'
	current_file_name(end+1) = '*';
	set(handles.parameter_GUI, 'Name', current_file_name);
end


% --------------------------------------------------------------------
function varargout = prbs_menu_Callback(h, eventdata, handles, varargin)

% Load Parameter Data
parameters = getappdata(handles.parameter_GUI, 'Parameter_Data');
if isempty(parameters)
	msgbox('No file has be loaded yet.','No File Loaded','error');
	return;
end

keep_trying = 1;
while keep_trying
	% Get PRBS info
	details = inputdlg({'Motor identification, total time:', ...
			'Motor PRBS min_time_same variable: ', ...
			'Power identification, total time:', ...
			'Power PRBS min_time_same variable: '}, 'Advanced PRBS Data', 1, ...
		{num2str(parameters.motor_identification.total_time), ...
			num2str(parameters.motor_PRBS.min_same_time), ...
			num2str(parameters.power_identification.total_time), ...
			num2str(parameters.power_PRBS.min_same_time)});
	if isempty(details)
		return;
	end
	
	% make sure inputs are numbers
	if (~isempty(str2num(details{1})) & ~isempty(str2num(details{2})) & ...
			~isempty(str2num(details{3})) & ~isempty(str2num(details{4})))
		keep_trying = 0;
	end
end

parameters.motor_identification.total_time = str2num(details{1});
parameters.motor_PRBS.min_same_time        = str2num(details{2});
parameters.motor_PRBS.total_time           = parameters.motor_identification.total_time;

parameters.power_identification.total_time = str2num(details{3});
parameters.power_PRBS.min_same_time        = str2num(details{4});
parameters.power_PRBS.total_time           = parameters.power_identification.total_time;

% Save Parameter Data
setappdata(handles.parameter_GUI, 'Parameter_Data', parameters);

% Set file modified *
current_file_name = get(handles.parameter_GUI, 'Name');
if current_file_name(end) ~= '*'
	current_file_name(end+1) = '*';
	set(handles.parameter_GUI, 'Name', current_file_name);
end


% --------------------------------------------------------------------
function varargout = default_menu_Callback(h, eventdata, handles, varargin)

% Load Parameter Data
parameters = getappdata(handles.parameter_GUI, 'Parameter_Data');
if isempty(parameters)
	msgbox('No file has be loaded yet.','No File Loaded','error');
	return;
end

% Get the config file path and name
[cfg_path cfg_name cfg_extn cfg_vrsn] = fileparts(which(mfilename));
cfg_extn = '.cfg';
cfg_filename = [cfg_path, '\', cfg_name, cfg_extn];

% Confirm the replacement of default data
qest_str = sprintf(['Save current values as default?\n\nPreviouse default data will be lost!\nDefault data is stored in ', cfg_name, cfg_extn]);
button = questdlg(qest_str,'Confirm New Defaults','Yes','Cancel','Cancel');

if strcmp(button, 'Cancel')
	return;
else
	% Save the new default data
	parameters.test_subject.id = 'Config'; % Don't save the current subjects id
	save(cfg_filename, 'parameters');
end


% --------------------------------------------------------------------
function varargout = print2file_menu_Callback(h, eventdata, handles, varargin)

% Load Parameter Data
parameters = getappdata(handles.parameter_GUI, 'Parameter_Data');
if isempty(parameters)
	msgbox('No file has be loaded yet.','No File Loaded','error');
	return;
end

% Generate a Title
current_file_name = get(handles.parameter_GUI, 'Name');
%if current_file_name(end) == '*' current_file_name = current_file_name(1:end-1); end;
prt_str = sprintf('Parameter File: %s\n', current_file_name);
prt_str = sprintf('%s------------------------------ \n\n', prt_str);

% Generate a string of the parameters
prt_str_P = print2file_menu_subfunction('parameters', parameters);
prt_str = sprintf('%s%s\n\n', prt_str, prt_str_P);

% Ask for a file name
[new_fname, new_pname] = uiputfile('*.txt','Print Parameter Info to File');

% Check that cancel was not pressed
if isnumeric(new_fname) return; end;

temp_filename = [new_pname, new_fname];

% Try and open this file
try fid = fopen(temp_filename, 'w');
catch disp(['Error (', mfilename, '): Could not open a tempory file.']); return;
end

% Write to the file
try
	fprintf(fid, '%s', prt_str);
catch
	fclose(fid);
	disp(['Error (', mfilename, '): Could not write to the tempory file.']); return;
end

% Close the open file
fclose(fid);


% --------------------------------------------------------------------
function strOut = print2file_menu_subfunction(post_str, structureIn)

strOut = [''];

field_names = fieldnames(structureIn);
for i = 1 : length(field_names)
	inField = getfield(structureIn, field_names{i});
	if isnumeric(inField)
		strOut = sprintf('%s%s.%s = %s\n', strOut, post_str, field_names{i}, num2str(inField));
	elseif  ischar(inField)
		strOut = sprintf('%s%s.%s = %s\n', strOut, post_str, field_names{i}, inField);
	elseif  isstruct(inField)
		innerStr = print2file_menu_subfunction([post_str, '.', field_names{i}], inField);
		strOut = sprintf('%s%s', strOut, innerStr);
	else
		strOut = sprintf('%s%s.%s = <%s>\n', strOut, post_str, field_names{i}, class(inField));
	end
end


% --------------------------------------------------------------------
function varargout = print_win_menu_Callback(h, eventdata, handles, varargin)

% Load Parameter Data
parameters = getappdata(handles.parameter_GUI, 'Parameter_Data');
if isempty(parameters)
	msgbox('No file has be loaded yet.','No File Loaded','error');
	return;
end

printdlg(handles.parameter_GUI);


% --------------------------------------------------------------------
function varargout = close_menu_Callback(h, eventdata, handles, varargin)

% Close the GUI
close(handles.parameter_GUI);


% --------------------------------------------------------------------
function varargout = help_menu_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = about_menu_Callback(h, eventdata, handles, varargin)

s = sprintf(' Parameter GUI v1.0 \n---------------\n\nBenjamin A Saunders\n\nUniversity of Glasgow\nb.saunders@mech.gla.ac.uk');
msgbox(s,'About Parameter GUI','help');


% --------------------------------------------------------------------
function varargout = discription_menu_Callback(h, eventdata, handles, varargin)

s = sprintf([' Parameter GUI \n---------------\n\nThis GUI produces a *.prm type file which can be loaded into the matlab ', ...
	'workspace via the normal matlab load function.  The *.prm file contains a structure of all the parameters needed to ', ...
	'run the simulink FES cycling models.  The GUI can be used to change these parameters.']);
msgbox(s,'Parameter GUI','help');


