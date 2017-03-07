 clc, close all, clear all

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


%Sue and Anastasia's SRM calibration constants - 23Jan2012
freq_zero = -38.15;
freq_range = 1022.16;
slope = 15.81;

%User Input
parameters.angle_shift = 20;
% parameters.srm_conversion.ZOPM = 402;   Testing trike; Jan 30,2012  1st pedaling trial and 2 load tests; 
% parameters.srm_conversion.ZOPM = 405;  Testing trike; Jan 30,2012  rest for that day and 1st 2 trials on testing trike on Jan 31,2012
% parameters.srm_conversion.ZOPM = 397;  % Testing trike; Jan 31,2012  rest of trials on this day
% parameters.srm_conversion.ZOPM = 403;  % Testing trike; Feb 1,2012  rest of trials on this day
%parameters.srm_conversion.ZOPM = 408;  % Testing trike; Feb 1,2012  3rd trial on
%parameters.srm_conversion.ZOPM = 398;  % Testing trike; Feb 2,2012  testing trike
% parameters.srm_conversion.ZOPM = 402;  % Training trike; Feb 2,2012, Feb 8, 2012 
% parameters.srm_conversion.ZOPM = 410;  % Training trike; March 9,2012
% parameters.srm_conversion.ZOPM = 393;  % Training trike; March 22,2013
% parameters.srm_conversion.ZOPM = 395;  % Training trike; May 21,2013
parameters.srm_conversion.ZOPM = 385;  % Training trike; July 26,2013


% CrankLength = 0.11  %Crank length in meters, to attachment point with shaft of pedal;
% CrankLength = 0.134  %Crank length in meters; starting last trial on Jan 31, 2012
CrankLength = 0.17  %Crank length in meters, to attachment point with shaft of pedal; Training trike 3, white trike.


%NOTE:  New rear tire (not rim, but tube and tire) on Training Trike 2 (orange) on Feb 1, 2012, all tests.




open('Sue_CalibTrainTrike_NoStim');