function [ calculated_angle ] = voltage_to_angle(volt, parameters)
% Converts an angle described as voltage between 0 and 1 to an angle in
% degrees
u = volt.* 0.2;
u = u * 360;
u = u + parameters.angle_shift;
calculated_angle = u - 360 * floor(u/360);
end

