% param.m
%
% Defines sensor DAQ and frequency control parameters used by VFT cycling
% model.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DAQ Toolbox Analog Output Setup (comment out if not using toolbox or if DAQ is not connected)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ao = analogoutput('nidaq','Dev2');    % Set USB DAQ analog output object parameters 
% chans = addchannel(ao,0:1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cadence Controller Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cad_ref = 0;
phio_mat = [1 -0.559 0.0775];
ro_mat = [0.7602 -0.2976 0.0591];
s_mat = [0.5025 -0.3467]*1e-3;
t_mat = [0.2987 -0.1660 0.0231]*1e-3;
% Ts = 0.2;
Ts = 20;

freq_zero = 39.49;
freq_range = 865.41;
slope = 14.1374;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Incremental Test Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Pw = 0;         % Target power during warmup (W)
Pi = 5;         % Target power increment (W)
Pstep = 114;
Tw = 6000;      % Warm up time period (10ms)
Ti = 6000;      % Increment time period (10ms)        

stim_min = 0;  % Minimum stimulation level
stim_max = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Animation Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
animation.upper_error =1;
animation.lower_error = 1; % Highlight window upper and lower in watts

[b,a] = butter(2,0.02,'low');        % power signal filter constants



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Force Profile Factors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Tau_pw = 202.28;
Tau_f = 207.3212;
f0 = 20;
pw0 = 74.42;
pw_max = 435;
f_min = 30;

pw1 = 181;
f1 = 30;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sensor and DAQ Factors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parameters.srm_conversion.ZOPM = 390;
% parameters.sample_time = 0.05;
parameters.sample_time = 5;
parameters.angle_shift = 20;
parameters.velocity_modifier = 0.15;
parameters.torque_threshold = 5;
increment_time = 3000;
torque_increment = 0.1;
initial_torque_increment = 0.6;
muscle_response_time = 300; %in increments of 10ms
no_of_revs = 1080; %number of revolutions below threshold before next step in degrees



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Frequency Control Factors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Overall model step time in seconds.
% parameters.model.sample_time = 0.05; 
parameters.model.sample_time = 1;
model_step_time = 0.01;
cft_ipi = 30; % (ms)
% Lookup table data

V = [2 2 2 2 2 3 3 2 2 2 2 2 2 2 2 1 1 1 2 2 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
C = [2 2 2 2 2 4 4 3 3 3 3 3 3 3 3 2 2 2 4 4 2 2 2 2 3 3 3 3 3 3 3 3 3 3];
SF =[0.011 0.011 0.01 0.01 0.01 0.007 0.007 0.009 0.009 0.009 0.008 0.008 0.008 0.008 0.008 0.011 0.011 0.011 0.007 0.007 0.01 0.01 0.01 0.01 0.009 0.009 0.009 0.009 0.009 0.009 0.009 0.009 0.009 0.009]; 



profile_det_pw_forward = [150 350 250 150 500 350 150 500 350 250 500 350 500 250 150 250 500 250 350 150];
profile_det_pw_reverse = [150 350 250 500 250 150 250 500 350 500 250 350 500 150 350 500 150 250 350 150];
profile_det_Ts_forward = [0.05 0.08 0.012 0.02 0.05 0.03 0.012 0.08 0.02 0.05 0.03 0.012 0.02 0.08 0.03 0.02 0.012 0.03 0.05 0.08];
profile_det_Ts_reverse = [0.08 0.05 0.03 0.012 0.02 0.03 0.08 0.02 0.012 0.03 0.05 0.02 0.08 0.012 0.03 0.05 0.02 0.012 0.08 0.05];








% .ref values are used for both frequency reference (desired pulse period divided by model 
% sample time) and counter reference.

parameters.no_of_steps = 5;

parameters.pw_step1 = 181;
parameters.pw_step2 = 208;
parameters.pw_step3 = 247;
parameters.pw_step4 = 310;
parameters.pw_step5 = 435;
% 
% parameters.cf.ref = 17;          
% parameters.vf_step1.ref = 12;   
% parameters.vf_step2.ref = 10;
% parameters.vf_step3.ref = 8;
% 
% %Actual frequency values for each step.
% parameters.cf.frequency = 1/((parameters.cf.ref + 1)*parameters.model.sample_time);
% parameters.vf_step1.frequency = 1/((parameters.vf_step1.ref + 1)*parameters.model.sample_time);
% parameters.vf_step2.frequency = 1/((parameters.vf_step2.ref + 1)*parameters.model.sample_time);
% parameters.vf_step3.frequency = 1/((parameters.vf_step3.ref + 1)*parameters.model.sample_time);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Additional/Alternative Values Required by Pulse Generator Approach
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% parameters.cf.samples = 18;
% parameters.vf_step1.samples = 14;
% parameters.vf_step2.samples = 9;
% parameters.vf_step3.samples = 8;
% 
% 
% parameters.cf.frequency = 1/(parameters.cf.samples*parameters.model.sample_time);
% parameters.cf.counter = parameters.cf.samples - 1;
% 
% parameters.vf_step1.frequency = 1/(parameters.vf_step1.samples*parameters.model.sample_time);
% parameters.vf_step1.counter = parameters.vf_step1.samples - 1;
% parameters.vf_step2.frequency = 1/(parameters.vf_step2.samples*parameters.model.sample_time);
% parameters.vf_step2.counter = parameters.vf_step2.samples - 1;
% parameters.vf_step3.frequency = 1/(parameters.vf_step3.samples*parameters.model.sample_time);
% parameters.vf_step3.counter = parameters.vf_step3.samples - 1;