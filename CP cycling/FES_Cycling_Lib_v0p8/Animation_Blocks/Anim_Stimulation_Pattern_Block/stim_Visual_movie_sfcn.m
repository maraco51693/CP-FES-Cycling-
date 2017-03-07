function [sys,x0,str,ts] = stim_Visual_movie_sfcn(t,x,u,flag, Ts, show)
% This s-function is used to open a visualisation GUI and to animate it's graphics

global movie_h;

% Switch yard of the s-function
if flag==0,
    [sys,x0,str,ts]=mdlInitializeSizes(Ts);
elseif flag==3
    sys=mdlOutputs(t,x,u,show);
elseif flag==9
    sys=mdlTerminate(t,x,u);
elseif flag==1|flag==2|flag==4,
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

global movie_h;

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
sizes.NumInputs      = 28;
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


movie_h = avifile('movie_file.avi')

% end mdlInitializeSizes

%=============================================================================
% mdlOutputs
% Return the block outputs.
%=============================================================================

function sys=mdlOutputs(t,x,u, show)

global movie_h;

sys = [];

vidioCapture_on = 1; % set video capture on(1) or off(0)

if ((t == 0) & show)
    % Initialisation of the s-Function GUI
    %disp(['Initialising the s-Function in block ', num2str(gcbh)]);
    h = stim_Visual; % opens the GUI (if it is on the matlab path or in local dir)
    set_param(gcbh, 'UserData', h);
end

h = get_param(gcbh, 'UserData');
if ~ishandle(h) % figure has been closed
    return;
end

angle = u(1);
vel   = u(2);
thrtl = u(3);
pw    = u(4);
stimPat = [u(5:12)'; u(13:20)'];
stimAct = [u(21:28)'];

debugging = 0;
if debugging
    disp(['stim_Visual_sfcn S-Function running ... :-) ']);
    disp(['Input Angle        = ', num2str(angle)]);
    disp(['Input Vel.         = ', num2str(vel)]);
    disp(['Input Throttle     = ', num2str(thrtl)]);
    disp(['Input Pulsewidth   = ', num2str(pw)]);
    disp(['Input Stim Pattern = ']);
    disp([num2str(stimPat)]);
    disp(['Input Stim Activat = ', num2str(stimAct)]);
    disp([' ']);
end

stim_Visual('update', h, angle, vel, thrtl, pw, stimPat, stimAct);



% capture video output
if vidioCapture_on
	frame_h = getframe(h);
	movie_h = addframe(movie_h, frame_h);
end




%=============================================================================
% mdlTerminate
% Terminates the simulation.
%=============================================================================
function sys=mdlTerminate(t,x,u)

global movie_h;

sys = [];

movie_h = close(movie_h);	
