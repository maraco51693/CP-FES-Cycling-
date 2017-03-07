function [sys,x0,str,ts] = ControllerDesign_sFcn(t,x,u,flag, mdl_order, ctrObs_dyn, refMdl_dyn, Ts_param)
% This s-function is used to design a controller.  Most
% of the work will be done during termination of the
% simulink model.  After collecting the identification
% data a controller will be designed and saved in a mat
% file.

% Switch yard of the s-function
if flag==0,
    [sys,x0,str,ts]=mdlInitializeSizes(Ts_param);
elseif flag==3
    sys=mdlOutputs(t,x,u);
elseif flag==9
    sys=mdlTerminate(t,x,u, mdl_order, ctrObs_dyn, refMdl_dyn, Ts_param);
elseif flag==1|flag==2|flag==4,
    sys=[];
else
    error(['Unhandled flag = ',num2str(flag)]);
end


%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
function [sys,x0,str,ts]=mdlInitializeSizes(Ts_param)

% call simsizes for a sizes structure, fill it in and convert it to a
% sizes array.
%
% Note that in this example, the values are hard coded.  This is not a
% recommended practice as the characteristics of the block are typically
% defined by the S-function parameters.
%
sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 0;
sizes.NumInputs      = 2;
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;   % at least one sample time is needed

sys = simsizes(sizes);

%
% initialize the initial conditions
%
x0  = [];

%
% str is always an empty matrix
%
str = [];

%
% initialize the array of sample times
% ts = [period, offset];
% if Ts_param == -1
	ts = [-1  0]; % Inherited sample time
% elseif Ts_param == 0
% 	ts = [ 0  0]; % Continuous sample time, offset to 0.
% else
% 	ts = [Ts_param, 0];
% end

set_param(gcb, 'UserData', []);


%=============================================================================
% mdlOutputs
% Return the block outputs.
%=============================================================================
function sys=mdlOutputs(t,x,u)

sys = [];

if ((t == 0))
    % Initialisation of the s-Function
    
    % Clear this blocks userData to store the data for identification
    set_param(gcb, 'UserData', []);

end

% Add this steps input dara to the blocks userData
set_param(gcb, 'UserData', [get_param(gcb, 'UserData'); [t u(1) u(2)]]);


%=============================================================================
% mdlTerminate
% Terminates the simulation.
%=============================================================================
function sys=mdlTerminate(t,x,u, mdl_order, ctrObs_dyn, refMdl_dyn, Ts_param)

% some reason gcb changes after calling an m-script so save it now.
this_gcb = gcb;

sys = [];

% Empty structure for save preparation
controllerData = [];

% -----------------------------------
% Ask if wish to design a controller
button = questdlg('Do you want to continue with Controller Design?', ...
	'Initiating Controller Design','Yes','Cancel','Yes');
if strcmp(button, 'Cancel')
	return;
end

% -----------------------------------
% Identify a model

% Get the identification data
ident_data = get_param(this_gcb, 'UserData');

% Run an identification script
id_mdl = [];
[id_mdl id_range] = mdl_ident_ben(ident_data, mdl_order, Ts_param);

if isempty(id_mdl)
    warning('Model identification did not work.');
else
    % Prepare structure to save data
    controllerData.ident.raw_data	= ident_data;
    controllerData.ident.id_range	= id_range;
    controllerData.ident.mdl_order	= mdl_order;
    controllerData.ident.id_mdl		= id_mdl;
	controllerData.ident.Ts			= Ts_param;
end


% -----------------------------------
% Design an RST controller

% only do controller design if a model was successfully identified
rst_ctrl = [];
if ~isempty(id_mdl)
    
    rst_ctrl = rst_design_ben(id_mdl, ctrObs_dyn, refMdl_dyn);
    
    if isempty(rst_ctrl)
        warning('Controller design did not work.');
    else
        % Prepare structure to save data
        controllerData.rst.rise_time		= ctrObs_dyn(1);
        controllerData.rst.damping			= ctrObs_dyn(2);
        controllerData.rst.model_rise_time	= refMdl_dyn(1);
        controllerData.rst.model_damping	= refMdl_dyn(2);
		controllerData.rst.rst_ctrl			= rst_ctrl;
    end
    
end


% -----------------------------------
% Save results to a mat file (as named in the mask)

% only if control design was successful (if not warning message has been given already)
if ~isempty(rst_ctrl)
	
	% ---------------------
	% Generate a File Name.
	try    
		% Add Center ID
		fname = evalin('base', 'parameters.test_subject.center');
		
		% Add Test Subject ID
		fname = [fname, '_', evalin('base', 'parameters.test_subject.id')];
		
	catch
		warning('No parameters variable exists.');
		fname = ['NoCen_NoName'];
	end
	
	% Add Date (in reverse order)
	fname = [fname, '_', datestr(date, 'yy'), '_', datestr(date, 'mm'), '_', datestr(date, 'dd')];
	
	% Add Data Type
	fname = [fname, '_controller'];
	
	% ---------------------
	% Save data
	
	% Remember the current path
	original_path = pwd;
	
	% If 'Controllers' directory exists then save there
	try cd('Controllers'); end;
	
	% Ask user to confirm name (and whether to save or not)
	[fname, pname] = uiputfile([fname, '.ctr'], 'Save Controller');
	if isequal(fname,0)|isequal(pname,0)
		% Don't save controller to a mat file
		disp([' ']);
		warning('Controller data was not saved!!');
		disp([' ']);
    else
        % Check to make sure if a file extension is needed
        [p, n, e, v] = fileparts([pname, fname]);
        if isempty(e) fname = [fname, '.ctr']; end
        
        % Save file
        save([pname, fname], 'controllerData');
	end
	
	% Return to the current path
	cd(original_path);
end
