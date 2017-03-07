
clear all; clc;

figure(1); clf;

% ------------------------
% input parameters

op_range = [0 500];
nbr_mbrFcns = 5;

% ------------------------
% controller parameters

UoD = [-1 1];
UoD_op_range = [-0.8 0.8];


a(1) = 2;
a(2) = 0.05;


% ------------------------
% calculation of input scaling


d_op_range = op_range(2) - op_range(1);
p_op_range = d_op_range/10;

x = [op_range(1)-p_op_range : d_op_range/100 : op_range(2)+p_op_range];

y_1 = (a(1) ./ (1+exp(-a(2).*x)))-1;
y_2_t = 1+exp(-a(2).*x);
y_2 = (a(1) - y_2_t) ./ y_2_t;


a(2) = (log(UoD_op_range(1)-UoD_op_range(2)) + log(UoD_op_range(1)) - log(UoD_op_range(2))) / ...
	(2 * (op_range(1) - op_range(2)));

a(1) = (1 + UoD_op_range(1)) * (1 + exp((-a(2)) * UoD_op_range(1)));



a(1) = 2; a(2) = 0.05;
x = 0.2514;

y_t = 1 + exp((-a(2)) * x);
y = (a(1) - y_t) / y_t;

x_r = (log(y+1) - log(a(1)-y-1)) / a(2);
disp([' ']);
disp(['x = ', num2str(x), ' y = ', num2str(y), ' x_r = ', num2str(x_r)]);

% ------------------------
% ------------------------
% ------------------------

x = [-20:0.01:20];

a = [1 0];
y = ((a(1) .* x) ./ (((x+1).^2) .* ((x-1).^2))) + a(2);
plot(x, y, 'b');
hold on;

a = [2 0];
y = ((a(1) .* x) ./ (((x+1).^2) .* ((x-1).^2))) + a(2);
plot(x, y, 'r');

a = [0.5 0];
y = ((a(1) .* x) ./ (((x+1).^2) .* ((x-1).^2))) + a(2);
plot(x, y, 'm');

a = [1 2];
y = ((a(1) .* x) ./ (((x+1).^2) .* ((x-1).^2))) + (a(2) ./ x);
plot(x, y, 'b:');
hold on;

a = [1 -0.5];
y = ((a(1) .* x) ./ (((x+1).^2) .* ((x-1).^2))) + a(2);
plot(x, y, 'b-.');
hold on;


axis([-20 20 -8 8]);


