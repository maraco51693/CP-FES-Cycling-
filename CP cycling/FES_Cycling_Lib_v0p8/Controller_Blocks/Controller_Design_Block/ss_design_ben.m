function cntrl = ss_design_ben(Phi_p, Gma_p, C_p,  Ts, r_d_p, r_d_m)
% cntrl = ss_design_ben(Phi_p, Gma_p, C_p, Ts)
%   This m function is used to design a state-space
%   controller based on a plant model described as:
%
%      x(k+1) = (Phi_p * x(k)) + (Gma_p * u(k))
%        y(k) = C_p * x(k)
%
%   with a sample time of Ts.
%
%   The user will be prompted for controller properties
%   like rise time etc.
%
%   cntrl: is a structure describing the controller,
%   which is based on the control structure:
%
%      u(k) = -L_p*x(k) + L_c*u_c(k)
%
%   cntrl has the following feilds:
%      'L_p': the state space feedback gain matrix.
%      'L_c': the command signal gain matrix.
%
% cntrl = ss_design_ben(Phi_p, Gma_p, C_p, Ts, [r_p d_p])
%   By providing a rise time r_p and damping d_p as
%   inputs means that no prompting is necessary. This
%   will also assume that no model reference is wanted.
%
% cntrl = ss_design_ben(Phi_p, Gma_p, C_p, Ts, [r_p d_p], [r_m d_m])
%   Can be used to include a model reference component
%   with specified model rise time r_m and model
%   damping d_m.  This makes a 2 degree of freedom
%   controller.  If ommited then no model referenc will
%   be used at all (single degree of freedom).
%

% Author : Benjamin A Saunders
%   Date : 07 June 2004
% University of Glasgow - Mechanical Engineering

% Updates:
%   07 Jun 2004 : Benjamin A Saunders
%      Added main functionality of this function


% ------------------------------------------------------
% Check inputs

% Set default outputs (if function should fail)
cntrl = [];

% set debugging mode:
debugging = 1;

if nargin < 4
    error('At least 4 input arguments are required for this function.');
else
	% Check Phi_p %%%%%%%%%%%%%%%%%%%%%%% To Do
	% Check Gma_p %%%%%%%%%%%%%%%%%%%%%%% To Do
	% Check C_p   %%%%%%%%%%%%%%%%%%%%%%% To Do
	% Check Ts    %%%%%%%%%%%%%%%%%%%%%%% To Do
end

get_rdp_from_GUI = 1;
if nargin > 4
	get_rdp_from_GUI = 0;
	r_p = r_d_p(1);
	d_p = r_d_p(2);
end

calculate_model_reference = 0;
get_rdm_from_GUI = 1;
if nargin > 4 % ouly use GUI when no dynamics were set
	get_rdm_from_GUI = 0;
	if nargin > 5
		calculate_model_reference = 1;
		r_m = r_d_m(1);
		d_m = r_d_m(2);
	end
end


% ------------------------------------------------------
% Use a GUI to get parameters that are not provieded

if get_rdp_from_GUI
	accepted_all = 0;
	while ~accepted_all
		
		% Get the plant controller dynamics
		r_d_p_input = inputdlg({'Please enter a rise time:', ...
				'Please enter a damping coefficient:'}, ...
			'Controller Dynamics Input');
		
		% Check if user pressed the 'Cancel' button
		if length(r_d_p_input) ~= 2
			% cancel whole controller design
			return;
		end
		
		% Check inputs of user
		r_p = str2num(r_d_p_input{1});
		d_p = str2num(r_d_p_input{2});
		if (isempty(r_p) | isempty(d_p))
			uiwait(msgbox('Incorrect input values!', ...
				'Controller Dynamics Input','error'));
			continue; % start the while accepted_all loop again
		end
		
		accepted_all = 1;
	end
	
	% Ask if the user wants to use a model reference
	button = questdlg(['Do you want to design a reference model?'], ...
		'Model Reference Selection', 'Yes', 'No', 'Cancel Design', 'Yes');
	
	if strcmp(button, 'Cancel Design')
		% cancel whole controller design
		return;
	elseif strcmp(button, 'No')
		calculate_model_reference = 0;
		get_rdm_from_GUI = 0;
	else
		calculate_model_reference = 1;
		get_rdm_from_GUI = 1;
	end
	
end

if get_rdm_from_GUI
	accepted_all = 0;
	while ~accepted_all
		
		% Get the plant controller dynamics
		r_d_m_input = inputdlg({'Please enter a rise time:', ...
				'Please enter a damping coefficient:'}, ...
			'Model Reference Dynamics Input');
		
		% Check if user pressed the 'Cancel' button
		if length(r_d_m_input) ~= 2
			% cancel whole controller design
			return;
		end
		
		% Check inputs of user
		r_m = str2num(r_d_m_input{1});
		d_m = str2num(r_d_m_input{2});
		if (isempty(r_m) | isempty(d_m))
			uiwait(msgbox('Incorrect input values!', ...
				'Model Reference Dynamics Input','error'));
			continue; % start the while accepted_all loop again
		end
		
		accepted_all = 1;
	end
end

% Calculate the desired natural frequency from the desired rise time
% This calculation is based on an underdamped second order model
if (d_p <= 0)
	disp(['Warning d_p must be between 0 and 1 (underdamped case), will use 0.01']);
	d_p = 0.01;
elseif (d_p >= 1)
	disp(['Warning d_p must be between 0 and 1 (underdamped case), will use 0.99']);
	d_p = 0.99;
end
temp_nfd = sqrt(1-(d_p^2));
%nf_p = (1/(r_p*temp_nfd))*atan(-(temp_nfd/d_p));
nf_p = (1/(r_p*temp_nfd))*(pi-atan(-(temp_nfd/d_p))); % atan gives an answer between -pi and pi

if debugging
	disp(['Debugging (', mfilename, '): Control dynamics = [', num2str([r_p d_p]), ']']);
	if calculate_model_reference
		disp(['Debugging (', mfilename, '): Model dynamics   = [', num2str([r_m d_m]), ']']);
	else
		disp(['Debugging (', mfilename, '): Model dynamics   = Not used.']);
	end
	disp(['Debugging (', mfilename, '): Calculated nf_p = [', num2str(nf_p), ']']);
end


% ------------------------------------------------------
% Naive Control: u_p = (-L_p * x_p) + (L_c * u_c)

% Is the system controllable?
Wc_p = []; % the controllability matrix
for i = 1 : length(C_p)
	Wc_p(:,i) = (Phi_p^(i-1))*Gma_p;
end

if rank(Wc_p) ~= length(C_p)
	disp(['Error (', mfilename, '): The model provided is not controllable.']);
	return;
end

%des_char_p = [1 (-2)*exp((-d_p)*nf_p*Ts)*cos(nf_p*Ts*sqrt(1-(d_p^2))) exp((-2)*d_p*nf_p*Ts)];
%P_p = des_char_p(1)*Phi_p^2 + des_char_p(2)*Phi_p + des_char_p(3)*eye(length(C_p));

des_char_p = [1 (-2)*exp((-d_p)*nf_p*Ts)*cos(nf_p*Ts*sqrt(1-(d_p^2))) exp((-2)*d_p*nf_p*Ts)];
P_p = des_char_p(1)*Phi_p^4 + des_char_p(2)*Phi_p^3 + des_char_p(3)*Phi_p^2;

% Ackermann's Formula
temp_ackermans = zeros(1,length(C_p));
temp_ackermans(end) = 1;
L_p = temp_ackermans*pinv(Wc_p)*P_p;

cntrl.L_p = L_p;

steadystate_gain = dcgain(tf(idss(Phi_p-(Gma_p*L_p), Gma_p, C_p, 0)));
cntrl.L_c = 1/steadystate_gain(1);



% ------------------------------------------------------
% Analysis








