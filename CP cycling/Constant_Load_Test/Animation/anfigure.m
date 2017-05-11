function xOut = anfigure( Action, hFig, xData )

% Defined actions:
%------ Object Commands ---------
%   #NewObj
%   #PlaceObj
%   #SelectObj
%   #ModifyObj   -- not implemented
%   #DeselectObj
%   #DeleteObj
%------ Simulation Commands ------
%   #Draw
%   #Start/Stop
%   #Restart
%   #ToggleTrails
%   #ClearTrails
%   #Reset
%------ Configuration Commands ------
%   #SetIC
%   #NormalMode
%

%  5/30/97 KGK add #ButtonDown function 

%   Written By: Kevin Kohrt
%   Written On: April 1997
%   $Author$  $State$
%	Copyright (c) 1990-97 by The MathWorks, Inc.
% 	$Revision$  $Date$
%
%###############################################################################

% Get the figure's handle, if not provided 
% (assume call was made from object within the Working Figure)
if nargin == 1, [ hObj, hFig ] = gcbo; end

% Get the UserData for the Figure -- the key to all knowledge
sFigUserData = get( hFig, 'UserData' );


switch Action,
%%%%%%%%%%%%%%%%%
%%% Animation %%%
%%%%%%%%%%%%%%%%%
case '#Draw',
    % Check inputs
    if nargin < 3, xData = angetic( hFig ); end
    
    % Tell the axes to draw all objects
    anaxes( '#Draw', sFigUserData.h.axes.animation, xData )
    
    
%%%%%%%%%%%%%%%%%%%%%
%%% Buttonm Press %%%
%%%%%%%%%%%%%%%%%%%%%
case '#ButtonDown',
    % Only worry if the axes is turned off (because it won't handle the event then)
    if strcmp( get(sFigUserData.h.menu.ViewAxisOn,'checked'), 'off' )
        % Get the current mouse position
        MousePos = get( hFig, 'CurrentPoint' );
        % Get the current axes position in the same units as the mouse position!
        hAxes = sFigUserData.h.axes.animation;
        AxesUnits = get( hAxes, 'units' );
        FigUnits = get( hFig, 'units' );
        if strcmp( AxesUnits, FigUnits ),
            AxPos = get( hAxes, 'Pos' );
        else,
            set(  hAxes, 'units', FigUnits );
            AxPos = get( hAxes, 'Pos' );
            set(  hAxes, 'units', AxesUnits );
        end;
        % Find out if the buttonpress was within the axes
        if MousePos(1) < AxPos(1) | MousePos(2) < AxPos(2) | ...
           MousePos(1) > AxPos(1)+AxPos(3) | MousePos(2) > AxPos(2)+AxPos(4),
           % out of axes. Do nothing. (it was a fast check, though!)
        else,
           % Activate axes button click
           anaxes( '#ButtonPress', hAxes );
        end % if ...
    end % if strcmp( ...
       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% New Object to be added %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case '#NewObj',
    % Set the axes mode to receive the new object
    anaxes( '#ChangeMode', sFigUserData.h.axes.animation, {'AddObjPrep', xData} )
    % Update change flag
    filetracker( 'NewChange', hFig ); % set( sFigUserData.h.menu.File, 'UserData', 1 );
  
%%%%%%%%%%%%%%%%%%%
%%% Normal mode %%%
%%%%%%%%%%%%%%%%%%%
case '#NormalMode',
    % Set the axes mode to normal
    anaxes( '#ChangeMode', sFigUserData.h.axes.animation, 'Normal' )
    % That's it. Now wait for the user to select something
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% New Object is being placed %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case '#PlaceObj',
    % Make sure the object is placed on the figure using the xData method
    anaxes( '#PlaceObj', sFigUserData.h.axes.animation, xData )

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Object is selected %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
case '#SelectObj',        
    % Make sure the object (passed in as hFig) is selected using the xData method
    numObj = anaxes( '#SelectObj', sFigUserData.h.axes.animation, xData );
    
    % Update Menus and controls as necessary
    if numObj == 1; % Can modify OR delete
        local_ToggleControls( sFigUserData, 'select' )    
    else, % too many objects, turn off modify menu
        set( sFigUserData.h.menu.EditModify, 'Enable', 'off' );
    end % if

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Object(s) deselected %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case '#DeselectObj',
    % If a specific object handle was not passed in, deselect all (shown by passing in [])
    if nargin ~= 3,  xData = [];  end
    
    % Make sure the object (passed in as hFig) is selected using the xData method
    numObj = anaxes( '#DeselectObj', sFigUserData.h.axes.animation, xData );
    
    % Update Menus and controls as necessary
    if numObj == 1; % Enable all edit controls
        local_ToggleControls( sFigUserData, 'select' )    
    elseif numObj == 0, % No more objects selected--turn off edit controls
        local_ToggleControls( sFigUserData, 'deselect' )  
    else,
        % too many objects, turn off modify menu
        set( sFigUserData.h.menu.EditModify, 'Enable', 'off' );
    end % if
    
    % Simulate a button press on the first button, the selection arrow
    set(0,'currentfigure',hFig); % must be done for btnpress to work
    btnpress( hFig, 'ObjectButtons', 1 );
    
    % Update change flag
    filetracker( 'NewChange', hFig ); %set( sFigUserData.h.menu.File, 'UserData', 1 );
    
%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Object(s) deleted %%%
%%%%%%%%%%%%%%%%%%%%%%%%%
case '#DeleteObj',
    % Make sure object (passed in as hFig) is selected using method  'xData' 
    numObj = anaxes( '#DeleteObj', sFigUserData.h.axes.animation );
    % No more selected objects--turn off edit controls
    local_ToggleControls( sFigUserData, 'deselect' ) 
    
%%%%%%%%%%%%%%%%%%%%%%%%
%%% Modify Object(s) %%%
%%%%%%%%%%%%%%%%%%%%%%%%
case '#ModifyObj',
    % Let the axes handle this
    anaxes( '#ModifyObj', sFigUserData.h.axes.animation );
  
%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Simulation Command %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
case '#SimCmd',
    % The user wants to either start or stop simulink
    theSimulation = sFigUserData.m.Name;
    CurrentStatus = get_param(theSimulation, 'SimulationStatus' );
    
    % Check status of the simulation
    if strcmp( CurrentStatus, 'stopped' ),
        % Simulation is stopped, start it up again
        set_param( theSimulation, 'SimulationCommand', 'start' );
    elseif  ~strcmp( CurrentStatus, 'terminating' ),
        % User isn't allowed to "re-quit", but they can stop in any other run state
        % Question: is this necessary? Will SL get upset if you tell it to
        % stop while it is already stopping?
        set_param( theSimulation, 'SimulationCommand', 'stop' );
    end % if
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Simulation Start/Stop %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case '#Start/Stop',
     
    % Perform pre or post simulation set up on the figure
    local_StartStop( hFig, sFigUserData );
    
%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Simulation Record %%%
%%%%%%%%%%%%%%%%%%%%%%%%%
case '#SimRecord',

    % Let the user know we are recording
    anfigure( '#Message', hFig, 'Recording simulation data. Please wait...' )
    
    % Add a To Workspace block and connect it to the Ansim Subsystem inport
    add_block( 'built-in/To Workspace'                              , ...
               [ sFigUserData.m.AnsimSubSysName '/Data Recorder' ]  , ...
               'VariableName'   , 'AnsimRecordedOutput'             , ...
               'Buffer'         ,'inf'                              , ...
               'SampleTime'     ,'-1'                               ...
             )
    add_line( sFigUserData.m.AnsimSubSysName, 'in_1/1', 'Data Recorder/1' )

    % Run the simulation with the Ansim GUI hidden
    set_param( sFigUserData.m.hAnsimBlock, 'parameters', num2str( -hFig ) );
    sim( sFigUserData.m.Name )
    set_param( sFigUserData.m.hAnsimBlock, 'parameters', num2str( hFig ) );

    % Extract the output variable from the Base Workspace and then zap it
    sFigUserData.d.SimData = evalin( 'base', 'AnsimRecordedOutput' );
%     evalin( 'base', 'clear AnsimRecordedOutput');
    set( hFig, 'UserData', sFigUserData )

    % Remove To Workspace block and connecting line
    delete_line( sFigUserData.m.AnsimSubSysName, 'in_1/1', 'Data Recorder/1' )
    delete_block( [ sFigUserData.m.AnsimSubSysName '/Data Recorder' ] )

    % Enable the playback and save menus
    set( [ sFigUserData.h.menu.SimPlay, sFigUserData.h.menu.FileSaveAsMovie ], ...
            'Enable', 'on' )

    % Let the user know we are done
    anfigure( '#Message', hFig, 'The simulation data has been recorded.' )
  
%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Simulation Playback %%%
%%%%%%%%%%%%%%%%%%%%%%%%%
case '#PlayBack',
    
    % Get Data
    u = sFigUserData.d.SimData;
    
    % Check data  doing
    if length(u) == 1,
        anfigure('#Message',hFig,'Pre-recorded data not found. Playback Aborted.')
        return
    end
    
    % Set up figure for a run and let the user know what we are in playback mode
    anfigure( '#Start/Stop', hFig )
    anfigure( '#Message', hFig, '*** Playing back pre-recorded input data ***' )
    
    % Ooops! Disable the start/stop controls so the user cannot screw things up
    DisableList = [
                    sFigUserData.h.menu.SimStart
                    sFigUserData.h.ctrl.pushStartStop 
                  ];
    set( DisableList, 'Enable', 'off' );
    
    % Loop through the data and animate the axes objects
    for idx = 1 : size(u,1)
        anaxes( '#Draw', sFigUserData.h.axes.animation, u(idx,:) )
        drawnow
    end
    
    % Let the user know we are done
    set( DisableList, 'Enable', 'on' );
    anfigure( '#Start/Stop', hFig )
    anfigure( '#Message', hFig, 'Playback finished.' )
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Simulation Show Trails %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case '#ToggleTrails',  
    % Change the Working Axes' mode based on the Show Trails checkbox
    if get( sFigUserData.h.ctrl.checkShowTrails, 'Value' ),
        % Box is checked. Draw fast (show trails)
        anaxes( '#ChangeMode', sFigUserData.h.axes.animation, 'RunFast' )
    else,
        % Box is not checked. Draw normally ('xor')
        anaxes( '#ChangeMode', sFigUserData.h.axes.animation, 'Run' )
    end
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Simulation Clear Trails %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case '#ClearTrails',   
    % force axes plot to update 
    set( sFigUserData.h.axes.animation, 'DrawMode', 'normal' , ...
                                        'DrawMode', 'fast'   );
    
    
%%%%%%%%%%%%%
%%% Reset %%%
%%%%%%%%%%%%%
case '#Reset',
    % Reset the axes drawstring
    anaxes( '#UpdateDrawString', sFigUserData.h.axes.animation );
	
    % Reset the axes
    anaxes( '#Draw', sFigUserData.h.axes.animation, angetic( hFig ) );

    % Change the axes mode back to normal
    anaxes( '#ChangeMode', sFigUserData.h.axes.animation, 'Normal' );

    % Turn menus and controls on and off as necessary
    local_ToggleControls( sFigUserData, 'reset' )    
 
%%%%%%%%%%%%%%%%%%%%%
%%% ChangeMessage %%%
%%%%%%%%%%%%%%%%%%%%%   
case '#Message',
    local_SetStatusMessage( sFigUserData, xData )
    
%%%%%%%%%%%%%%%%
%%% KeyPress %%%
%%%%%%%%%%%%%%%%
case '#KeyPress',
    AsciiVal = abs(get(hFig,'CurrentCharacter'));
    %disp(AsciiVal);
    % Mac:  del[x]      control-x        delete
    % PC:   delete       ctrl-x         backspace
    if AsciiVal==127 | AsciiVal==24 | AsciiVal==8,
        anfigure( '#DeleteObj', hFig )
    elseif AsciiVal==20,
%         anfigure( '#Start/Stop', hFig )
    end %if abs
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Set Input Initial Conditions %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case '#SetIC',
    
    hTarget       = sFigUserData.h.menu.SimSetIC;
    cLabels = {'Initial Condition Vector:'};
    cProperty    = {'UserData'};

    CurrentData  = get( hTarget, 'UserData' );    
    if CurrentData(1)   ~= '[', CurrentData = ['[ ' CurrentData];  end
    if CurrentData(end) ~= ']', CurrentData = [CurrentData ' ]'];  end
    
    Method   = 'anfigure';
    FigTag   = 'SetICFig';
    FigTitle = ['Initial Input Vector: ' get_param(sFigUserData.m.Name,'Name')];
    
    FigHelp  = [ 'This vector determines the positioning of the objects'
                 'when Reset is selected.  The vector sets the values  '
                 'of the signals for objects whose position depends on '
                 'a signal.  The vector allows for up to 100 input     '
                 'signals and the default value for all signals is 0.  '
               ];
    
    anprpdlg( '#Initialize' , hTarget       , hFig           , ...
              cLabels       , cProperty     , {CurrentData}, cProperty , ... 
              'anfigure'    , '#UpdateIC'   , FigTitle       ,  FigHelp    ...                        ...
            );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Set Input Initial Conditions %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case '#SetTs',

    % Get the current sample period
    Ts = ansim( sFigUserData.m.hAnsimBlock, [], [], 'GetTs', hFig );

    % Set up parameters for a dialog box
    Title    = 'Change Sample Period';
    cLabels  = {'Sample Period (seconds)'};
    cDefault = { num2str(Ts) };
    % Get a new valid sample period from inputdlg
    cTs = inputdlg( cLabels, Title, 1, cDefault );
    
    % See if user hit the cancel button
    if isempty(cTs),  return;   end
    
    % Validate input
    eval( ['Ts = ' cTs{1} ';'], 'disp(''Invalid entry for Ts was ignored.''); return') 
    if iscell(Ts),
        disp('Ts must be a scalar real number. Cell entry was ignored.')
        return
    end
    if length(Ts) ~=1
        disp('Only the 1st element of Ts will be used.')
        Ts=Ts(1);
    end

    % Store the value in the figure and in the ansim block
    sFigUserData.d.Ts = Ts;
    set( hFig, 'UserData', sFigUserData );
    ansim( sFigUserData.m.hAnsimBlock, Ts, [], 'SetTs', hFig );

%%%%%%%%%%%%%%%%%%%%%%%%
%%% Change Look Stub %%%
%%%%%%%%%%%%%%%%%%%%%%%%
case '#ChangeLook',
    % The IC has been changed in a property dialog box. Just ignore it.
    if nargout, xOut = 1; end;

%%%%%%%%%%%%%%%%%%%%%%%%
%%% Update IC Vector %%%
%%%%%%%%%%%%%%%%%%%%%%%%
case '#UpdateIC',
    % Note: Only called from prpdlg figure
    
    % we were mislead up above; As stated in ansimltn #SetIC, the target of 
    % this update is the Simulation-->SetIC menu itself, and has been passed 
    % back in as the WorkingFigure
    hSimSetICmenu   = hFig; 
    hFig            = get(get(hSimSetICmenu,'Parent'),'Parent');
    sFigUserData    = get( hFig, 'UserData' );
    
    % Get the IC string from the data structure and clean it up
    ICVectString = xData.UserData;
    ICVectString = deblank(fliplr(ICVectString)); % clean up the front
    ICVectString = deblank(fliplr(ICVectString)); % clean up the end
    
    if ICVectString(1)~='[',
        ICVectString=['[ ' ICVectString];
    end  
    if ICVectString( length(ICVectString) ) ~= ']' ,
        ICVectString = [ICVectString ' ]'];
    end

    % Put it back in the UserData of the SetIC menu 
    set( hSimSetICmenu, 'UserData', ICVectString );
    
    % Reset the axes
    % Note: Must pass in WorkingFig: parent of the parent of the SetIC menu 
    anfigure( '#Reset', hFig );
  
    % Update change flag
    filetracker( 'NewChange', hFig );%    set( sFigUserData.h.menu.File, 'UserData', 1 );
    
%%%%%%%%%%%%%%%%%%
%%%   ERROR    %%%
%%%%%%%%%%%%%%%%%%
otherwise,
    error( ['Action "' Action '" not handled by anfigure']);


    
end % Switch
    
%#############################################################################
%         %                                                                   %
%   END   %   main                                                            %
%         %                                                                   %
%#############################################################################

%#############################################################################
%         %                                                                   %
%  BEGIN  %  local function local_StartStop()                                 %
%         %                                                                   %
%#############################################################################

function local_StartStop( hFig, sFigUserData ) % % %, xData )

%------------------------------------------------------------------------------
% This function sets up the Animation figure and axes when the Simulation is
% started or stoped
% Have to use the string on the Ansim start button to toggle state!
%
% Generate the proper label & callback for the Start/Stop menu & btn,
% the proper state for the Reset btn, and the appropriate status msg
% (Note: uicontrols must be prepared to reverse the action of the simulation)
%------------------------------------------------------------------------------

% chatty = strncmp( computer, 'MA', 2 );
 chatty = 0;
%%%%%%%%%%%%%%%%
%%% Start Up %%%
%%%%%%%%%%%%%%%%
if strcmp( get( sFigUserData.h.ctrl.pushStartStop, 'String' ), 'Start' ),     
    % Simulation is currently stopped (think about it). 
    % Let's get things ready to run again

    if chatty, speak('Starting simulation','zarvox'); end
    %--------------------------------------------------------------------------
    % Tell the axes to enter Run mode (It will deselect everything for us)
    %--------------------------------------------------------------------------
    anaxes( '#ChangeMode', sFigUserData.h.axes.animation, 'Run' )
    
    % 'RunFast' if show trails is selected 
    % Note: must still do 'Run' first, or it won't "do the right thing"
    if get( sFigUserData.h.ctrl.checkShowTrails, 'value' ),
        anaxes( '#ChangeMode', sFigUserData.h.axes.animation, 'RunFast' )
    end % if

    %--------------------------------------------------------------------------
    % Turn menus and controls on/off as necessary
    %--------------------------------------------------------------------------
    local_ToggleControls( sFigUserData, 'starting' )
    
    sFigUserData.d.FigureStatus = 'animated';
    
%%%%%%%%%%%%%
%%% Stop  %%%
%%%%%%%%%%%%%
else,     % we are 'paused', 'running', or something else. So stop.
    if chatty, speak('Simulation Ending','zarvox'); end

    %--------------------------------------------------------------------------
    % Tell the axes to change modes again
    %--------------------------------------------------------------------------
    anaxes( '#ChangeMode', sFigUserData.h.axes.animation, 'Stop' )
    
    %--------------------------------------------------------------------------
    % Turn menus and controls on and off as necessary
    %--------------------------------------------------------------------------
    local_ToggleControls( sFigUserData, 'stopping' )
    
    sFigUserData.d.FigureStatus = 'active';
 
%%%%%%%%%%%%
%%% End  %%%
%%%%%%%%%%%%
end % if strcmp

% Since we changed the figure status, we need to reset the userdata
set( hFig, 'UserData', sFigUserData )
    
    
%#############################################################################
%         %                                                                   %
%   END   %   local_StartStop                                                 %
%         %                                                                   %
%#############################################################################

%#############################################################################
%         %                                                                   %
%  BEGIN  %   local_ToggleControls                                            %
%         %                                                                   %
%#############################################################################

function local_ToggleControls( sFigUserData, State )

% This function toggles the lables and callbacks on the Start/Stop 
% menu and Start/Stop button; changes the Status Bar message;  and enables
% or disables most other menus and controls that are sensitive to operating
% state
%
%===============================================================================
%                  Table of Menu/Ctrl Enabling
%        + enable, - disable, 0 do nothing, T toggle/change text
%===============================================================================
% ------CTRLS------   -----------STATE-----------   ----------------
%                    starting   stopping    reset   select  deselect
% ===== MENUS =====  ========   ========    =====   ======  ========
% FileLoad              -           +         0
% FileSave              -           0         +
% FileClose             0           0         0
% EditNew               -           0         +
% EditDelete            0           0         0       +       -
% EditModify            0           0         0       +       -
% EditAxisLimits        -           +         0
% ViewFindAll           -           +         0
% SimStart              T           T         0
% SimReset              0           +         -
% SimSetIC              -           0         +
% == STATUS CTRLS ==
% pushStartStop         T           T         0 
% pushReset             0           +         -
% checkShowTrails       +           -         0
% pushClearTrails       +           -         0
% textStatusMessage     T           T         T
%
%===============================================================================

%-------------------------------------------------------------------------------
%  Get a shortcut to menu and control handles
%-------------------------------------------------------------------------------
sMenus = sFigUserData.h.menu;
sCtrls = sFigUserData.h.ctrl;

% Do it (Toggle controls)
switch State,

%-------------------------------------------------------------------------------
% Simulation is starting
%-------------------------------------------------------------------------------
case 'starting',    
    
    StatMsg    = 'Simulation Running.';   

    DisableList = [ sMenus.FileLoad
                    sMenus.EditNew
                    sMenus.EditAxisLimits
                    sMenus.ViewFindAll
                    sMenus.SimReset
                    sMenus.SimSetIC
                  ];
                  
    EnableList = [ ];
    
    % Temporarily turn off the File Save menus
    filetracker( 'TempDisable', sFigUserData.h.fig.Animation )
    
    % Show/hide simulation-sensitive controls (if allowed)
    if strcmp( get( sMenus.ViewSeeStatus, 'checked' ), 'on' ),
        set(  sCtrls.pushReset                                ,'Visible', 'off')
        set([ sCtrls.checkShowTrails, sCtrls.pushClearTrails ],'Visible', 'on' )
    end % if
    
    % Toggle Start buttons/menus to Stop buttons/menus
    set( sCtrls.pushStartStop , 'String'  , 'Stop' );
    set( sMenus.SimStart      , 'Label'   , 'Stop' );

%-------------------------------------------------------------------------------
% Simulation is stopping
%-------------------------------------------------------------------------------
case 'stopping',    
    
    StatMsg    = 'Simulation Stopped. To Add/Modify objects, press Reset.';

    DisableList = [ ];
                  
    EnableList = [  sMenus.FileLoad
                    sMenus.SimReset
                    sMenus.EditAxisLimits
                    sMenus.ViewFindAll
                 ];
                 
    % Revert File Save menus to their former state
    filetracker( 'Revert', sFigUserData.h.fig.Animation )
    
    % Show/hide simulation-sensitive controls (if allowed)
    if strcmp( get( sMenus.ViewSeeStatus, 'checked' ), 'on' ),
        set([ sCtrls.checkShowTrails, sCtrls.pushClearTrails ],'Visible','off')
        set(  sCtrls.pushReset                                ,'Visible','on' )
    end % if
    
    % Toggle Stop buttons/menus to Stop buttons/menus
    set( sCtrls.pushStartStop , 'String'  , 'Start' );
    set( sMenus.SimStart      , 'Label'   , 'Start' );

    
%-------------------------------------------------------------------------------
% Resetting figure
%-------------------------------------------------------------------------------
case 'reset',       

    StatMsg = 'Add/Modify objects using the toolbar or the Edit menu';

    DisableList = sMenus.SimReset;
                  
    EnableList = [  sMenus.FileSave
                    sMenus.EditNew
                    sMenus.SimSetIC
                 ];
                 
    % Show/hide simulation-sensitive controls (if allowed)
    if strcmp( get( sMenus.ViewSeeStatus, 'checked' ), 'on' ),
        set( sCtrls.pushReset, 'Visible', 'off')
    end
    
%-------------------------------------------------------------------------------
% One or more objects has been selected
%-------------------------------------------------------------------------------
case 'select',       
                 
    StatMsg = 'Add/Modify objects using the toolbar or the Edit menu';

    DisableList = [];
    
    EnableList = [  sMenus.EditDelete
                    sMenus.EditModify
                 ];
 
%-------------------------------------------------------------------------------
% All objects have been deselected
%-------------------------------------------------------------------------------
case 'deselect',       

    StatMsg = 'Add objects using the toolbar or the Edit menu';

    DisableList = [ sMenus.EditDelete
                    sMenus.EditModify
                  ];
    
    EnableList = [];
    
end % switch

%-------------------------------------------------------------------------------
% Disable simulation-sensitive controls
%-------------------------------------------------------------------------------
set( DisableList, 'Enable', 'off' )

%-------------------------------------------------------------------------------
% Enable runtime-only controls 
%-------------------------------------------------------------------------------
set( EnableList, 'Enable', 'on' )

%-------------------------------------------------------------------------------
% Change the status bar message
%-------------------------------------------------------------------------------
local_SetStatusMessage( sFigUserData, StatMsg )

%#############################################################################
%         %                                                                   %
%   END   %   local_ToggleControls                                            %
%         %                                                                   %
%#############################################################################

%#############################################################################
%         %                                                                   %
%  BEGIN  %   local_SetStatusMessage                                          %
%         %                                                                   %
%#############################################################################

function local_SetStatusMessage( sFigUserData, StatMsg )

%-------------------------------------------------------------------------------
% Change the status bar message
%-------------------------------------------------------------------------------
set( sFigUserData.h.ctrl.textStatusMessage , 'String', StatMsg );
