% DAQ Simulator
% Simulates reading input from hardware by reading it from file instead
% converts shaft encoder to cadence angle and cadence rpm
% evaluates throttle percent according to the throttle output and validity
% Run the code by section to simulate the various parts of the CPFES system

load('FESCycling_30_PRE_CONST_loaded_12Aug2014_085817.mat', ...
     'shaft_encoder_raw','throttle_raw', 'srm_raw', 'parameters', 'Metabolic_Sync', ... %known input
     'vel_rpm', 'angle_deg', 'phio_mat', 'Ts', 't_mat', 'slope', 'freq_range', 'freq_zero', ....
     's_mat', 'ro_mat', 'cad_ref', 'Vmotor'); %known output
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
p = plot(t, angle_deg_new(2:14820,1), t, angle_deg(1:14819,1));
title('simulated vs baseline angle in degrees')
p(1).Color = 'red';
p(2).Color = 'blue';

figure(2)
p2 = plot(t, calculated_angle(1:14819,1), t, angle_deg(1:14819,1));
title('calculated angle in degrees vs baseline angle in degrees')
p2(1).Color = 'red';
p2(2).Color = 'blue';
%% Throttle Conversion
calculated_throttle_percent = Throttle_valuation(throttle_raw, throttle_validity);

% calculated throttle percentage and simulated throttle percentage
figure(4)

p = plot(t, throttle_percent_new(2:14820,1), t, calculated_throttle_percent(1:14819,1));
title('simulated throttle percent')
p(1).Color = 'red';
p(2).Color = 'blue';
%% Simulate Power
sim('Vmotor_cadence_control');
plot(t, Power_rel(2:14820,1));
title('simulated Power ')

%% Simulate Cadence Control / Vmotor
p = plot(t, Vmotor_new(2:14820,1),t, Vmotor);
p(1).Color = 'blue';
p(2).Color = 'red';
title('Vmotor output')
%% Because there is such a large difference between the two curves, find a function that best fits p(2).Color = 'red';
% our result to the known result
figure(1)
p = polyfit(Vmotor_new(2:14820,1), Vmotor, 2);
result = polyval(p, Vmotor_new(2:14820,1));
p = plot(t, result,t, Vmotor);
p(1).Color = 'blue';
title('Vmotor output using polyval')

figure(2)
dividend = Vmotor_new(2:14820,1) / Vmotor;
p2 = plot(t,dividend);
title('divisor');

%% Animation, missing library for the actual Animation block
sim('Animation.slx');

