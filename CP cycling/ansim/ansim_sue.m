function [sys,x0,str,ts] = ansim(t,x,u,flag,WorkingFig)
%   The general form of an M-File S-function syntax is:
%       [SYS,X0,STR,TS] = SFUNC(T,X,U,FLAG,P1,...,Pn)
%   
    
%   Written by: Loren Dean, Kevin Kohrt
%   Written on: March 1995, February 97
%   4/03/97 KGK Adapt to make use of new UserData structure in the animation figure
%   4/07/97 KGK Validate existance of Animation figure using new Tag = gcb ploy
%   $Author$  $State$
%	Copyright (c) 1990-97 by The MathWorks, Inc.
% 	$Revision$  $Date$
%
%=====================================================================
% Verify that the ANSIM block references a valid, open Working Figure
%---------------------------------------------------------------------
str='';
% Check to see if figure handle was not passed in correctly
if nargin < 5 %| ~ishandle( WorkingFig ),
    if flag == 0,
        % Check for alternate s-fcn
        local_OpenWindow; 
    end   
    WorkingFig = GetSFunctionGUI(gcb);
end

% Check to see if the "no GUI" flag has been set
if WorkingFig == -1,
    % Assume sys = [];
    if nargout, sys = []; end
    
    % "No figure" means nothing to do, so might as well 
    % return now. Be sure to return a proper SYS first, though.
    if flag == 0, 
       sys = [0 0 0 -1 0 0 0];
       x0  = [];
    end
    return;
end
%
% The switchyard is based on the general structure of an S-function.
%
switch flag,

  %%% SL Initialization 
  case 0,               [sys,x0,str,ts] = mdlInitializeSizes;
  %%% SL Update 
  case 2,               sys = mdlUpdate( t, x, u, WorkingFig );

  %%% SL misc flags 
  case {1, 3},       sys = []; % no derivitives, outputs, or termination

  case 9,

  %%% Other Local Functions
  case 'Start',                         local_StartingSimulation( WorkingFig );

  case 'Stop',                          local_EndingSimulation( WorkingFig );

  case 'NameChange',                    local_BlockNameChangeFcn;

  case { 'CopyBlock', 'LoadBlock' },    local_BlockLoadCopyFcn;

  case 'DeleteBlock',                   local_BlockDeleteFcn

  case 'UpdateBlock',                   local_SetBlockCallbacks( WorkingFig );

  case 'DeleteFigure',                  local_FigureDeleteFcn( WorkingFig );

  case 'SetFigure',                     SetSFunctionGUI( u, WorkingFig );

  case 'GetTs',                         sys = local_GetSamplePeriod( t );
    
  case 'SetTs',                         local_SetSamplePeriod( t, x );
    
  case 'OpenUp',                        local_OpenWindow;
    
    %%% Unexpected flags 
  otherwise
    if ischar(flag),
      errmsg = sprintf('Unhandled flag: ''%s''', flag);
    else
      errmsg = sprintf('Unhandled flag: %d', flag);
    end

    error(errmsg);

end

%
% end main
%

%
%#############################################################################
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%#############################################################################
%
function [sys,x0,str,ts]=mdlInitializeSizes

%
% Initialize the Animation Dashboard for simulation; 
% call simsizes for a sizes structure, fill it in and convert it to a
% sizes array.
%

%
% Initialize the system vector
%    sys=[0 0 0 -1 0 0];    
sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 1;
sizes.NumInputs      = -1;
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
% initialize the array of sample times = Inherited from driving blocks
%
ts = [ local_GetSamplePeriod( gcb ), 0];

% end mdlInitializeSizes

%
%#############################################################################
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%#############################################################################
%
function sys = mdlUpdate( t, x, u, hFig )

% Return empty matrix (eventually)
sys = [];

% % Update the Working Figure         % % % Too slow!!!
% % anfigure( '#Draw', hFig, u );     % % % Use new method, below...

% Note: We shall trust that the close function of hFig will disable this
% routine before cashing out. i.e. we shall assume hFig exists

% Get userData from the ansim figure
sFigUserData = get( hFig, 'UserData' );

% Get UserData from axes
hAxes = sFigUserData.h.axes.animation;
sAxesUserData = get( hAxes, 'UserData' );

% Check for animated objects
if sAxesUserData.IsAnimated,

    % Assignment for use with stand-alone s-fcn
    h = sAxesUserData.hAllObjects;
    
    % Evaluate draw command
    eval( sAxesUserData.DrawString, 'disp(lasterr)' )
    
    % Check axes scaling (as long as we have the UserData already...)
    % WARNING: Following text must not be changed if 
    % Save As S-fcn is to work (it searches for "ScaleCmd...")
    ScaleCmd = strcmp( get( sFigUserData.h.menu.ViewAutoScale,'Checked' ),'on');
    
    % rescale the axes
    if ScaleCmd,
        anscale( hAxes, sAxesUserData.hAllObjects, ScaleCmd )
    end % if ScaleCmd,
    
end % if sAxesUserData.IsAnimated



% end mdlUpdate


%#############################################################################
% local_StartingSimulation
% Function that is called when the simulation starts.  Initializes the GUI.
%#############################################################################
%
function local_StartingSimulation( WorkingFig )

%=====================================================================
% Initialize the Working Figure
%=====================================================================
% Check to see if we've initialized already 
% (SL does it at least twice for some reason)
% Don't initialize the figure for startup if it has not been done yet
%---------------------------------------------------------------------
sFigUserData = get( WorkingFig, 'UserData' );
if strcmp('sFigUserData.d.FigureStatus','animated'),  
    % Figure has been initialized
    % Note: exact string for sFigUserData.d.FigureStatus (when SL is
    %       running) is set within anfigure.m. Other possible values
    %       can be found in ansimini. For now, it is 'animated' or 'edit'
    disp('double trouble')
    return;
end;

%%% Determine if a Properties dialog for this figure is already open
%%% and close it using OK if it is
Figs = findobj( allchild(0) , 'flat'                    , ...
                'Type'      , 'figure'                  , ...
                'Tag'       , 'Property Dialog Figure'    ...
              );
close( Figs ); 

% Set up the figure for animation
anfigure('#Start/Stop',WorkingFig,'SL says go!') % Change buttons and menus

drawnow;

% end local_StartingSimulation

%
%#############################################################################
% local_EndingSimulation
% At the end of the simulation, tell the GUI to wrap things up.
%#############################################################################
%
function local_EndingSimulation( hFig )

% Tell the GUI it's all over with
if ishandle(hFig),
    anfigure( '#Start/Stop', hFig, 'SL says stop!' )  
    testsue = 3
end

testsue =2

% end local_EndingSimulation

%
%#############################################################################
% local_BlockNameChangeFcn
% Function that handles name changes on the Graph scope block.
%#############################################################################
%
function local_BlockNameChangeFcn

% get the figure associated with this block and check it
FigHandle = GetSFunctionGUI(gcb);
if ~ishandle(FigHandle), return; end % No figure. Nothing to do.
 
% Get the old figure name and the new block name   
OldFigName = get(FigHandle,'Name');
NewBlockName = get_param(gcb,'Name');

% Determine where the block name is in the old figure name
Place1 = 12; % position of start of old block name in old fig name
Place2 = findstr('File:',OldFigName) - 4; % End position of old block name in old fig name

% Remove the old block name and insert the new one
OldFigName(Place1:Place2) = []; % Zap old block name
NewFigName = [ OldFigName( 1 : Place1 - 1 ), NewBlockName, OldFigName( Place1 : end ) ];
set( FigHandle, 'Name', NewFigName );

% end local_BlockNameChangeFcn

%
%#############################################################################
% local_BlockLoadCopyFcn
% This is the S-functions block's LoadFcn and CopyFcn.  It reinitializes the 
% block so that it does not point to any existing GUI.
%#############################################################################
%
function local_BlockLoadCopyFcn

SetSFunctionGUI(gcb,-1);

% end local_BlockLoadCopyFcn

%
%#############################################################################
% local_BlockDeleteFcn
% This is the ansim block's DeleteFcn.  Delete the block's figure window,
% if present, upon deletion of the block.
%#############################################################################
%
function local_BlockDeleteFcn


% Get the figure handle associated with the block
FigHandle = GetSFunctionGUI(gcb);

% if the handle exists, delete the associated figure.
if ishandle(FigHandle),
  anfile('#Close', FigHandle);
  SetSFunctionGUI(gcb,-1);
end

%%% Determine if a Properties dialog for this figure is already open
%%% and close it using OK if it is
Figs = findobj( allchild(0) , 'flat'                    , ...
                'Type'      , 'figure'                  , ...
                'Tag'       , 'Property Dialog Figure'    ...
              );
close( Figs ); 

% end local_BlockDeleteFcn

%
%#############################################################################
% local_FigureDeleteFcn
% This updates the S-function block to reflect that the associated figure 
% (HG GUI) window is being deleted.
%#############################################################################
%
function local_FigureDeleteFcn( WorkingFig )

% Block handle is stored in the figure's userdata
ud = get(gcbf,'UserData');

% Set the block's figure to -1 (i.e. no figure)
%hou SetSFunctionGUI(ud.m.hAnsimBlock,-1)

% end local_FigureDeleteFcn
%
%#############################################################################
% local_GetSamplePeriod
% This gets the initial sample period form the S-function block's userdata
%#############################################################################
%
function Ts = local_GetSamplePeriod( theBlock )

% The initial sample period should be stored in this block's userdata 
sBlockData = get_param( theBlock, 'UserData' );

% Check for old blocks where figure handle was stored in the parameter field
if isempty(sBlockData) | ~isstruct(sBlockData),
    % Value not set correctly. Just inheret.
    disp('default Ts')
    Ts = -1;
else,
    eval('Ts = sBlockData.samplePeriod;','Ts = -1;')
% In ML 5.2 and later use:
%     try
%         Ts = sBlockData.samplePeriod;
%     catch
%         Ts = -1;
%     end
end

%
%#############################################################################
% local_SetSamplePeriod
% This gets the initial sample period form the S-function block's userdata
%#############################################################################
%
function local_SetSamplePeriod( theBlock, Ts )

% The sample period should be stored in this block's userdata 
sBlockData = get_param( theBlock, 'UserData' );
sBlockData.samplePeriod = Ts;
set_param( theBlock, 'UserData', sBlockData );

%
%#############################################################################
% GetSFunctionGUI
% Retrieves the handle of the figure window associated with this S-function 
%#############################################################################
%
function FigHandle = GetSFunctionGUI(block)

% The figure handle should be stored in the S-function block's userdata 
sBlockData = get_param( block, 'UserData' );

% Check for old blocks where figure handle was stored in the parameter field
if isempty(sBlockData) | ~isstruct(sBlockData),
    % First, be sure this is not the ansim subsystem block
    if strcmp( get_param(block,'BlockType'), 'SubSystem' ),
        % Have the subsystem. Need the ansim block.
        block = find_system( block, 'name', 'ansim' );
    end
    % Verify this is the original Ansim block
    blockname = get_param(block,'name');
    if strcmp( blockname, 'ansim'),
        % With ansim block, Pull the figure handle from the parameter list
        FigHandleString = get_param(block,'Parameters');
        FigHandle = eval( FigHandleString, -1);
    else,
        % May be generic s-fcn
        % Open figure for them the first time
        FigHandle = figure('name', blockname);
        % Let them open it the next time
        set(block,'openfcn', [mfilename '([],[],[],''OpenUp'');'])
    end
    
    % Reset the userdata so that it complies with the new handle-storage algorithm
    SetSFunctionGUI( block, FigHandle )
        
else,
    eval('FigHandle = sBlockData.MyFigure;','FigHandle = -1;')
% In ML 5.2 and later use:
%     try
%         FigHandle = sBlockData.MyFigure;
%     catch
%         FigHandle = -1;
%     end
end

% Verify that if we think we have a handle, we really do have a handle
if FigHandle ~= -1,
    % We think it is a handle -- but we should double check
    if ~ishandle( FigHandle ), FigHandle = -1; end
end
% end GetSFunctionGUI

%
%#############################################################################
% SetSFunctionGUI
% Stores the figure window associated with this S-function ansim block
% in the block's parameter field.
%#############################################################################
%
function SetSFunctionGUI(block,FigHandle)

% The figure handle is stored in the S-function block's parameter list,
% as well as the userdata struct (more robust, but not as fast to access).
block

sBlockData = get_param( block, 'UserData')
sBlockData.MyFigure = FigHandle
set_param( block, 'UserData', sBlockData, 'Parameters', num2str(FigHandle) );

% end SetSFunctionGUI

%
%#############################################################################
% local_SetBlockCallbacks
% This sets the callbacks of the block if it is not a reference.
%#############################################################################
%
function local_SetBlockCallbacks(hFig)

% Block handles are stored in the figure's userdata
ud = get(hFig,'UserData');

% Define the callbacks to be set
cAnsimCallbacks = { ...
                   'CopyFcn'       , 'ansim([],[],[],''CopyBlock'');'    , ...
                   'DeleteFcn'     , 'ansim([],[],[],''DeleteBlock'');'  , ...
                   'LoadFcn'       , 'ansim([],[],[],''LoadBlock'');'    , ...
                   'StartFcn'      , 'ansim([],[],[],''Start'');'        , ...
                   'StopFcn'       , 'ansim([],[],[],''Stop'');'         ...
                  };

% Set the callbacks
set_param(ud.m.hAnsimBlock      , cAnsimCallbacks{:})
set_param(ud.m.hAnimationBlock  , 'NameChangeFcn' , ...
                                  'ansim([],[],[],''NameChange'');' )

% end SetBlockCallbacks

%
%#############################################################################
% local_OpenWindow
% This code is for use with ansim saved as an S-function.
%#############################################################################
%
function local_OpenWindow

% Function for use with stand-alone s-fcn only

% Get block name
blockname =  get_param(gcb,'name');
% check
if strcmp( blockname, 'ansim' )
    % Regular ansim block should not call this function!
    return
end

% Find animation figure
hFig = findobj( allchild(0), 'flat', 'name', blockname );

if isempty( hFig )
    % make a new figure
    hFig = figure('name', blockname, 'color', 'black');
    % Store info in the block
    SetSFunctionGUI( gcb, hFig );
    % Add objects
    hAx = axes('color','black');
    [hObj, DrawString] = local_DrawAllObjects;
    
    % Store handles in correct spot
    sFigUserData.h.axes.animation = hAx;
    set(hFig, 'UserData', sFigUserData );
    
    sAxesUserData.hAllObjects = hObj;
    sAxesUserData.IsAnimated = 1;
    sAxesUserData.DrawString = DrawString;
    set(hAx, 'UserData', sAxesUserData );
end

% bring figure to front
figure( hFig )

%
%#############################################################################
% local_DrawAllObjects
% This code is for use with ansim saved as an S-function.
%#############################################################################
%
function [h, DrawString] = local_DrawAllObjects

h = [];
DrawString = [];

% Add draw code here

%#############################################################################
%
% Revision history
%
% 03/03/97  KGK Convert to std S-fcn Switch-block code
%
% REFERENCE
%   What is returned by SFUNC at a given point in time, T, depends on the 
%   value of the FLAG, the current state vector, X, and the current
%   input vector, U.
%   
%   FLAG   RESULT             DESCRIPTION
%   -----  ------             --------------------------------------------
%   0      [SIZES,X0,STR,TS]  Initialization, return system sizes in SYS, 
%                             initial state in X0, state ordering strings
%                             in STR, and sample times in TS.
%   1      DX                 Return continuous state derivatives in SYS.
%   2      DS                 Update discrete states SYS = X(n+1)
%   3      Y                  Return outputs in SYS.
%   4      TNEXT              Return next time hit for variable step sample
%                             time in SYS.
%   5                         Reserved for future (root finding).
%   9      []                 Termination, perform any cleanup SYS=[].
%   
%   Optional parameter: WorkingFig = Handel to Animation Dashboard.
%   
%   When SFUNC is called with FLAG = 0, the following information
%   should be returned:
%   
%      SYS(1) = Number of continuous states.
%      SYS(2) = Number of discrete states.
%      SYS(3) = Number of outputs.
%      SYS(4) = Number of inputs.
%  **** Any of the first four elements in SYS can be specified
%  **** as -1 indicating that they are dynamically sized. The
%  **** actual length for all other flags will be equal to the 
%  **** length of the input, U.
%      SYS(5) = Reserved for root finding. Must be zero.
%      SYS(6) = Direct feedthrough flag (1=yes, 0=no). The s-function
%               has direct feedthrough if U is used during the FLAG=3
%               call. Setting this to 0 is akin to making a promise that
%               U will not be used during FLAG=3. If you break the promise
%               then unpredictable results will occur.
%      SYS(7) = Number of sample times. This is the number of rows in TS.
%   
%      X0     = Initial state conditions or [] if no states.
%   
%      STR    = State ordering strings which is generally specified as [].
%   
%      TS     = An m-by-2 matrix containing the sample time 
%               (period, offset) information. 
%               
%               You can also specify that the sample time of the S-function
%               is inherited from the driving block. For functions which
%               change during minor steps, this is done by
%               specifying SYS(7) = 1 and TS = [-1 0]. For functions which
%               are held during minor steps, this is done by specifying 
%               SYS(7) = 1 and TS = [-1 0].
