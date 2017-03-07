function [sys,x0,str,ts] = FuzzyController_sFcn(t,x,u,flag, b)
% This s-function is used to run a fuzzy logic controller.

% Switch yard of the s-function
if flag==0,
    [sys,x0,str,ts]=mdlInitializeSizes;
elseif flag==3
    sys=mdlOutputs(t,x,u,b);
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
function [sys,x0,str,ts]=mdlInitializeSizes()

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
sizes.NumOutputs     = 1;
sizes.NumInputs      = -1; % DYNAMICALLY_SIZED
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
ts  = [-1 0];


%=============================================================================
% mdlOutputs
% Return the block outputs.
%=============================================================================
function sys=mdlOutputs(t,x,u, b)

sys = [];

sys = fuzzy_controller_ben(u, b);


%=============================================================================
% mdlTerminate
% Terminates the simulation.
%=============================================================================
function sys=mdlTerminate(t,x,u, ctrlFileName, mdl_order, ctrObs_dyn, refMdl_dyn, Ts)

sys = [];

