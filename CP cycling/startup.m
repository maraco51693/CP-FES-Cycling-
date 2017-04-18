clc;

time = transpose(0:0.05:14818*0.05);
shaft_encoder_validity= zeros(14819,1);
throttle_validity = zeros(14819,1);
load FESCycling_30_PRE_CONST_loaded_12Aug2014_085817.mat;
select_test;