%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% constant_load_load.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This script loads all parameters required by constant load test simulink
% model and opens constant_load_test.mdl
%
% To change tricycle test system being used, alter "open" command at code
% line 80. i.e. "open('Stim_Thresholding_mt2.mdl');" Also change srm
% constants (code line 39 on) in line with current torque sensor in use.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calibration and General Constants
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Model step times
parameters.sample_time = 5;
parameters.model.sample_time = 1;
model_step_time = 0.01;

% Muscle latency (s)
parameters.velocity_modifier = 0.15;

% Stim interpulse interval (ms)
cft_ipi = 30;               

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

bla=findobj(f,'Style','edit','Tag','angleshift');
parameters.angle_shift = str2double(get(bla,'String'));

bla=findobj(f,'Style','edit','Tag','zopm');
parameters.srm_conversion.ZOPM = str2double(get(bla,'String'));

bla=findobj(f,'Style','edit','Tag','stimmax');
stim_max = str2double(get(bla,'String'));

bla=findobj(f,'Style','edit','Tag','stimmin');
stim_min = str2double(get(bla,'String'));

bla=findobj(f,'Style','edit','Tag','qr');
Current_QR= str2double(get(bla,'String'));

bla=findobj(f,'Style','edit','Tag','ql');
Current_QL = str2double(get(bla,'String'));

bla=findobj(f,'Style','edit','Tag','stim_frequency');
ipi = str2double(get(bla,'String'));
ipi = round((1/ipi)*1000);

bla=findobj(f,'Style','toggle','Tag','motor');

if get(bla,'Value') == 0
    
    cad_ref = 0;
end

open('Stim_Thresholding.mdl');


