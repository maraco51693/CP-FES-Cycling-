% torque_converter
% given a matfile with srm_raw data, converter it to the equivalent filtered
% torque signal

%the following are constants retrieved from the SRM sensor:
%freq_range
%slope
%freq_zero

%the following are user specified parameters:
%ZOPM - Zero Offset of the Power Meter
%sample time - Will store values every time the sample time has elapsed
%run the sections separately
load('FESCycling_30_PRE_CONST_loaded_12Aug2014_085817.mat', 'srm_raw', 'Torque','parameters');
parameters.sample_time = 1;
model_sample_time = 1;
velocity_modifier = 0.15;
angle_shift = 20;
srm = srm_raw;
t = transpose(1:size(srm_raw,1));
freq_zero = -38.15;
freq_range = 1022.16;
slope = 15.81;

%% manual calculations of torque
% normalize srm_raw
% convert srm voltage to freq

srm = srm_raw.*(0.2);
t1 = (srm.*freq_range);
t2 = t1+freq_zero;
% convert freq to torque(nm)
t3 = t2 - parameters.srm_conversion.ZOPM;
t4 = t3 * 1/slope;
 
%% default simulink calculations
%run torque model to get values for comparison
sim('torque.slx');
%% confirm integrity

for i=1:size(srm_raw,1)
   if(srm(i,1) ~=  temp_srm(i+1, 1))
       disp('srm data incorrectly ported')
       break;
   end
end
% check whether calculations are the same
for i=1:size(srm_raw,1)
   if(t1(i,1) ~= T_srmXrange(i+1, 1))
       disp('srm * range incorrectly calculated')
       break;
   end
end
for i=1:size(srm_raw,1)
   if(t2(i,1) ~= added_zero(i+1, 1))
       disp('sum bus incorrectly calculated')
       break;
   end
end
for i=1:size(srm_raw,1)
    diff = t4(i,1) - slope_product(i+1, 1);
   if(diff ~= 0 && diff > 0.00001) % remove differences from rounding
       disp('1/slope result incorrectly calculated'); disp(i);
       disp(diff)
   end
end
%%
sim('filtered_torque.slx');
%%
%comparisons of output torque values

figure(1)
raw_torque = slope_product(2:14820,1);
plot(t, raw_torque);
axis([0 14819 -30 30])
title('raw, nonfiltered torque')

figure(2)
plot(t, Torque);
axis([0 14819 -30 30])
title('torque from collected output data')

figure(3)
plot(t, Torque_filtered(2:14820,1));
axis([0 14819 -30 0])
title('simulated filtered torque')
%%
for i=1:14819
    gain(i, 1) = Torque(i, 1) / Torque_filtered(i,1);
    diff(i, 1) = abs(Torque(i, 1) - Torque_filtered(i,1));
end
%%
figure;
plot(t, gain);
title('Gain')
figure;
plot(t,diff);
title('difference')
%%
p = polyfit(Torque(21:14819,1), Torque_filtered(21:14819,1), 2);
result = polyval(p, Torque(21:14819,1));
%%
figure;
plt = plot(t(21:14819,1), result, t(21:14819,1), Torque_filtered(21:14819,1));
plt(1).Color = 'red';
plt(2).Color = 'blue';
