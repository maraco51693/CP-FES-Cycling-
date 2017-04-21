% DAQ Simulator
% Simulates reading input from hardware by reading it from file instead
% converts shaft encoder to cadence angle and cadence rpm
% evaluates throttle percent according to the throttle output and validity

load('FESCycling_30_PRE_CONST_loaded_12Aug2014_085817.mat', ...
     'shaft_encoder_raw','throttle_raw', 'srm_raw', 'parameters', 'Metabolic_Sync', ... %known input
     'vel_rpm', 'angle_deg'); %known output
%time vector for From Workspace block
t = transpose(1:size(srm_raw,1));
%no known values for these so set them to 0 for now
shaft_encoder_validity = transpose(1:size(srm_raw,1));
throttle_validity = transpose(1:size(srm_raw,1));
parameters.sample_time = 1;
%%
sim('DAQ_Input_Simulation');

%% Angle Conversion
% convert a voltage between 0 and 1 to an angle in degrees

calculated_angle = voltage_to_angle(shaft_encoder_raw, parameters);
calculated_vel_rpm = calculated_angle / 6;
%show calculated angle vs simulated angle vs known output angle

figure(1)
plot(t, angle_deg_new(2:14820,1));
title('simulated angle in degrees')

figure(2)
plot(t, calculated_angle(1:14819,1));
title('calculated angle in degrees')

figure(3)
plot(t, angle_deg(1:14819,1));
title('known output angle in degrees')

%% Throttle Conversion
calculated_throttle_percent = Throttle_valuation(throttle_raw, throttle_validity);

% calculated throttle percentage and simulated throttle percentage
figure(4)
plot(t, throttle_percent_new(2:14820,1));
title('simulated throttle percent')

figure(5)
plot(t, calculated_throttle_percent(1:14819,1));
title('calculated throttle percent')



