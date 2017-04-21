function [ throttle_percent ] = Throttle_valuation(throttle, validity)
% Converts an angle described as voltage between 0 and 1 to an angle in
% degrees
u = throttle.* 0.2;
u = u.*100;

if (validity > 0.5 | validity < 0.1)
    convert = 1;
end
throttle_percent = u * convert;
end

