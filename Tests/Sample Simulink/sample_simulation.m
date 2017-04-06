load FESCycling_30_PRE_CONST_loaded_12Aug2014_085817.mat;
t = zeros(14819,1);
for i=1:14819
    t(i,1) = i;
end
x = srm_raw;
y = throttle_raw;
wave.time = t;
wave.signals.values = [x];
wave.signals.dimensions = 1;
sim('sample_model.slx');