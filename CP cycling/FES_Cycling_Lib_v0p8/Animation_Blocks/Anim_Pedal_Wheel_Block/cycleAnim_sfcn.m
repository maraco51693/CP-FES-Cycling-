function [sys,x0,str,ts] = cycleAnim_sfcn(t,x,u,flag, Ts, show)
% This s-function is used to open a visualisation GUI and to animate it's graphics

% Switch yard of the s-function
if flag==0,
    [sys,x0,str,ts]=mdlInitializeSizes(Ts);
elseif flag==3
    sys=mdlOutputs(t,x,u,Ts,show);
elseif flag==1|flag==2|flag==4|flag==9,
    sys=[];
else
    error(['Unhandled flag = ',num2str(flag)]);
end


%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts]=mdlInitializeSizes(Ts)

% call simsizes for a sizes structure, fill it in and convert it to a
% sizes array.
%
% Note that in this example, the values are hard coded.  This is not a
% recommended practice as the characteristics of the block are typically
% defined by the S-function parameters.
%
sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 0;
sizes.NumInputs      = 2;
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;   % at least one sample time is needed

sys = simsizes(sizes);

%
% initialize the initial conditions
%
x0  = [];

%
% str is always an empty matrix
%
str = [];

%
% initialize the array of sample times
%
ts  = [Ts 0];

% end mdlInitializeSizes

%=============================================================================
% mdlOutputs
% Return the block outputs.
%=============================================================================

function sys=mdlOutputs(t,x,u, Ts, show)

sys = [];

if ((t == 0) & show)
    % Initialisation of the s-Function GUI
    %disp(['Initialising the s-Function in block ', num2str(gcbh)]);
    h = cycleAnim; % opens the GUI (if it is on the matlab path or in local dir)
    set_param(gcbh, 'UserData', h);
end

h = get_param(gcbh, 'UserData');
if ~ishandle(h) % figure has been closed
    return;
end

vel_wheel = (180 * u(1))/pi; % from rad/s into deg/s
vel_pedal = (180 * u(2))/pi; % from rad/s into deg/s

shift_angle_wheel = vel_wheel * Ts;
shift_angle_pedal = vel_pedal * Ts;

%disp(['Wheel shift angle = ', num2str(shift_angle_wheel),'; pedal shift angle = ', num2str(shift_angle_pedal)]);
%disp(['Wheel from ', num2str(u(1)),' rads/s to = ', num2str(vel_wheel), ' degs/s']);
%disp(' ');

cycleAnim('shift_wheel_angle', h, shift_angle_wheel);
cycleAnim('shift_pedal_angle', h, shift_angle_pedal);
