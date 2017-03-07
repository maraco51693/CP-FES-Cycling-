function controller_redesign
%  Loads data from a previously created controller file
%  and re-designes a controller based on new parameters
%
%  Controller file and new parameters are input via GUI's

% -----------------------------------
% Load data from previously created controller file

old_dir = pwd;
try cd('Controllers'); end;

[filename, pathname] = uigetfile('*.ctr', 'Load Controller Data');

cd(old_dir);

temp = load([pathname, filename], '-mat');
controllerData = temp.controllerData;


% -----------------------------------
% re-Identify a model

% ask first if we should re-identifiy
button = questdlg('Do you want to re-identify the model first?', 'Re-Identify Model','Yes');
if strcmp(button, 'Yes')
	
	% Get the identification data
	ident_data = controllerData.ident.raw_data;
	
	% Choose new parameters to identify with
	answer = inputdlg({'Identification model order:', 'Sample time:'}, ...
		'Identification Parameters', [1 30; 1 30], ...
		{['[', num2str(controllerData.ident.mdl_order), ']'], ...
			num2str(controllerData.ident.Ts)});
	
	if isempty(answer)
		return;
	end
	
	mdl_order = str2num(answer{1});
	Ts = str2num(answer{2});
	
	% Run an identification script
	id_mdl = [];
	[id_mdl id_range] = mdl_ident_ben(ident_data, mdl_order, Ts);
	
	if isempty(id_mdl)
		warning('Model identification did not work.');
	else
		% Prepare structure to save data
		newControllerData.ident.raw_data	= ident_data;
		newControllerData.ident.id_range	= id_range;
		newControllerData.ident.mdl_order	= mdl_order;
		newControllerData.ident.id_mdl		= id_mdl;
		newControllerData.ident.Ts			= Ts;
	end
elseif strcmp(button, 'Cancel')
	return;
else
	id_mdl = controllerData.ident.id_mdl;
end


% -----------------------------------
% Design an RST controller

% only do controller design if a model was successfully identified
rst_ctrl = [];
if ~isempty(id_mdl)
    
	% Choose new data to identify with
	answer = inputdlg({'Controller rist time:', 'Controller damping:', ...
			'Model rist time:', 'Model damping:'}, ...
		'Controller Parameters', [1 30; 1 30; 1 30; 1 30], ...
		{num2str(controllerData.rst.rise_time), num2str(controllerData.rst.damping), ...
		num2str(controllerData.rst.model_rise_time), num2str(controllerData.rst.model_damping)});
	
	if isempty(answer)
		return;
	end
	
	ctrObs_dyn = [str2num(answer{1}) str2num(answer{2})];
	refMdl_dyn = [str2num(answer{3}) str2num(answer{4})];
	
    rst_ctrl = rst_design_ben(id_mdl, ctrObs_dyn, refMdl_dyn);
    
    if isempty(rst_ctrl)
        warning('Controller design did not work.');
    else
        % Prepare structure to save data
        newControllerData.rst.rise_time			= ctrObs_dyn(1);
        newControllerData.rst.damping			= ctrObs_dyn(2);
        newControllerData.rst.model_rise_time	= refMdl_dyn(1);
        newControllerData.rst.model_damping		= refMdl_dyn(2);
        newControllerData.rst.rst_ctrl			= rst_ctrl;
    end
    
end


% -----------------------------------
% Save results to a mat file

% only if control design was successful
if ~isempty(rst_ctrl)
	
	old_dir = pwd;
	try cd('Controllers'); end;
	
	oldControllerData = controllerData;
	controllerData = newControllerData;

	% Ask user to confirm name (and whether to save or not)
	[fname, pname] = uiputfile([filename, '.ctr'], 'Save Controller');
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
	
	cd(old_dir);
    
end
