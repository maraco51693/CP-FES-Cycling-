%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% incremental_load.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This script loads all parameters required by incremental test simulink
% model and opens incremental_nostim.mdl

% To change tricycle test system being used, alter "open" command at code
% line 75. i.e. "open('Incremental_NoStim_mt2.mdl');" Also change srm
% constants (code line 45 on) in line with current torque sensor in use.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calibration and General Constants
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Model step times
parameters.sample_time = 5;
parameters.model.sample_time = 1;
model_step_time = 0.01;


Tw = 6000;      % Warm up time period (10ms)
Ti = 6000;      % Increment time period (10ms)


% Muscle latency (s)
parameters.velocity_modifier = 0.15;

% Stim interpulse interval (ms)
cft_ipi = 30;
stim_max = 0.1;
stim_min = 0;

% power signal filter for animation
[b,a] = butter(2,0.02,'low');        

%Motor controller parameters
phio_mat = [1 -0.559 0.0775];
ro_mat = [0.7602 -0.2976 0.0591];
s_mat = [0.5025 -0.3467]*1e-3;
t_mat = [0.2987 -0.1660 0.0231]*1e-3;
Ts = 20;

%SRM Constants
freq_zero = 116.7756;
freq_range = 466.8;
slope = 14.1374;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% User Defined Constants
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f = gcf;
bla=findobj(f,'Style','edit','Tag','cadence');
cad_ref = str2double(get(bla,'String'));

bla=findobj(f,'Style','edit','Tag','zopm');
parameters.srm_conversion.ZOPM = str2double(get(bla,'String'));

bla=findobj(f,'Style','edit','Tag','wup');
Pw = str2double(get(bla,'String'));

bla=findobj(f,'Style','edit','Tag','pi');
Pi = str2double(get(bla,'String'));

bla=findobj(f,'Style','edit','Tag','angleshift');
parameters.angle_shift = str2double(get(bla,'String'));

bla=findobj(f,'Style','edit','Tag','uerror');
animation.upper_error = str2double(get(bla,'String'));

bla=findobj(f,'Style','edit','Tag','lerror');
animation.lower_error = str2double(get(bla,'String'));


open('Incremental_NoStim.mdl');
open_system('Incremental_NoStim/Animation/SimAnim');
close(f);

