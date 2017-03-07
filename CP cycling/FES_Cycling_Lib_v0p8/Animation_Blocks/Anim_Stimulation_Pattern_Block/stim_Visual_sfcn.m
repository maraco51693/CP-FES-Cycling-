function [sys,x0,str,ts] = stim_Visual_sfcn(t,x,u,flag, Ts, show)
% This s-function is used to open a visualisation GUI and to animate it's graphics

% Switch yard of the s-function
if flag==0,
    [sys,x0,str,ts]=mdlInitializeSizes(Ts);
elseif flag==3
    sys=mdlOutputs(t,x,u,show);
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

% Clear the UserData
set_param(gcbh, 'UserData', []);


%=============================================================================
% mdlOutputs
% Return the block outputs.
%=============================================================================

function sys=mdlOutputs(t,x,u, show)

% Set the output to null first (case of premature faliure)
sys = [];

% If show is turned off on this block then do nothing
if ~show
	return;
end

% Get the current display figure handle
visual_disp_fig_h = get_param(gcbh, 'UserData');

% If there is no figure handle then create one
if isempty(visual_disp_fig_h)
    % Initialisation of the s-Function GUI
    %disp(['Initialising the s-Function in block ', num2str(gcbh)]);
    visual_disp_fig_h = stim_Visual; % opens the GUI (if it is on the matlab path or in local dir)
    set_param(gcbh, 'UserData', visual_disp_fig_h);
end

% Check to make sure that the display figure handle is currently valid
if ~ishandle(visual_disp_fig_h) % figure has been closed
    return;
end

% %
% angle = u(1);
% vel   = u(2);
% thrtl = u(3);
% pw    = u(4);
% stimPat = [u(5:12)'; u(13:20)'];
% stimAct = [u(21:28)'];

debugging = 0;
if debugging
    disp(['stim_Visual_sfcn S-Function running ... :-) ']);
    disp(['Input Angle        = ', num2str(u(1))]);
    disp(['Input Vel.         = ', num2str(u(2))]);
    disp(['Input Throttle     = ', num2str(u(3))]);
    disp(['Input Pulsewidth   = ', num2str(u(4))]);
    disp(['Input Stim Pattern = ']);
    disp([num2str([u(5:12)'; u(13:20)'])]);
    disp(['Input Stim Activat = ', num2str([u(21:28)'])]);
    disp([' ']);
end

stim_Visual('update', visual_disp_fig_h, u(1), u(2), u(3), u(4), [u(5:12)'; u(13:20)'], [u(21:28)']);

