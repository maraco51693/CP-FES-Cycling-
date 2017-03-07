function anoption(Action,WorkingFig)

%ANOPTION Animation option menu function.
%	ANOPTION(ACTION) is the callback function for the Option menu 
%	on the animation figure window.
%
%	ACTION may be one of 7 strings:
%	          '#Grid'  Toggle the grid on/off.
%	        '#AxisOn'  Toggle the axis on/off
%	           '#Box'  Toggle the axis box on/off.
%	      '#TickMark'  Toggle TickMarks on/off.
%	'#AutoExpandAxis'  Toggle the automatic scaling on/off.
%	       '#SetAxisLimits'  Set axis limits.
%	    '#SquareAxis'  Toggle square axis on/off
%	   'ChangeLabels'  Change axis labels
%	   'UpdateLabels'  Update axis labels
%	   '#FindObjects'  Find all objects.
%	    '#ShowStatus'  Toggle status bar display.
%	 '#ShowTools'  Toggle object button icon display
%	   '#FindModel'  Find Simulink Diagram
%
%
%	See also ANSIMINI.

%	Loren Dean  March, 1995.
%   3/25/97 KGK Convert from if/else to switch/case
%   3/25/97 KGK add "case otherwise" error message
%   4/03/97 KGK Make default WorkingFig = gcbf
%   4/03/97 KGK Convert to basic use of new UserData structure for WorkingFig (111
%   4/03/97 KGK Upgrade #ShowStatus action to new menu syntax and new UserData structure
%   4/03/97 KGK Upgrade #ShowTools action to new menu syntax and new UserData structure
%   4/7/97  KGK convert Tags, TextStrings, & Values to cell arrays for prpdlg
%   4/7/97  KGK make one prpdlg callback for all fields
%   5/30/97 KGK Fix #FindObjects case
%   $Author$  $State$
%	Copyright (c) 1990-97 by The MathWorks, Inc.
% 	$Revision$  $Date$

% Check inputs
if nargin==1,
    WorkingFig = gcbf; % findobj(0, 'Type', 'figure', 'Tag', 'WorkingFig' );
end  

% Retrieve useful information
sUD   = get( WorkingFig, 'UserData' ); % UserData structure (see ansimini for field names)
if isstruct( sUD ), 
    % Should work for all cases except '#UpdateLabels', which doesn't need it
    WorkingAxes = sUD.h.axes.animation;
end

switch Action,
%%%%%%%%%%%%
%%% Grid %%%
%%%%%%%%%%%%
case '#Grid',
    HOptnGrid = sUD.h.menu.ViewGridOn;
    if strcmp( get( HOptnGrid, 'Checked' ), 'on' ),
        set( HOptnGrid  , 'Checked' , 'off' );
        set( WorkingAxes, 'XGrid'   , 'off', 'YGrid', 'off' );
    else,
        set( HOptnGrid  , 'Checked' , 'on' );
        set( WorkingAxes, 'XGrid'   , 'on', 'YGrid', 'on' );
    end %if strcmp
  
%%%%%%%%%%%%%%%%%%%
%%% Axis On/Off %%%
%%%%%%%%%%%%%%%%%%%
case '#AxisOn',
    AxisOnHandle = sUD.h.menu.ViewAxisOn;
    if strcmp( 'off', get( AxisOnHandle, 'Checked' ) ),
        set( AxisOnHandle, 'Checked', 'on' );
        set( WorkingAxes, 'Visible', 'on' );
    else,
        set( AxisOnHandle, 'Checked', 'off' );
        set( WorkingAxes, 'Visible', 'off' )
    end % if strcmp off
   
%%%%%%%%%%%%%%%%
%%% Axis Box %%%
%%%%%%%%%%%%%%%%
case '#Box',
    BoxHandle = sUD.h.menu.ViewBoxOn;
    if strcmp( 'off', get( BoxHandle, 'Checked' ) ),
        set( BoxHandle, 'Checked', 'on' );
        set( WorkingAxes, 'Box', 'on' );
    else,
        set( BoxHandle, 'Checked', 'off' );
        set( WorkingAxes, 'Box', 'off' );
    end % if strcmp off
  
%%%%%%%%%%%%%%%%%
%%% Tick Mark %%%
%%%%%%%%%%%%%%%%%
case '#TickMark',
    TickHandle = sUD.h.menu.ViewTickLabelsOn;
    if strcmp( 'on',get( TickHandle, 'Checked' ) ),
        set( TickHandle, 'Checked', 'off' );
        set( WorkingAxes, 'XTick',[], 'YTick',[]);
    else,
        set( TickHandle, 'Checked', 'on' );
        set( WorkingAxes, 'XTickMode', 'auto', 'YTickMode', 'auto' );
    end % if strcmp on

%%%%%%%%%%%%%%%%%%%
%%% Square Axis %%%
%%%%%%%%%%%%%%%%%%%
case '#SquareAxis',
    SquareHandle = sUD.h.menu.ViewSquareAxis;
    if strcmp( 'on',get( SquareHandle, 'Checked' ) ),
        set( SquareHandle, 'Checked', 'off' );
        set( WorkingAxes , 'PlotBoxAspectRatioMode', 'auto' );
    else,
        set( SquareHandle, 'Checked', 'on' );
        set( WorkingAxes , 'PlotBoxAspectRatio',[1 1 1]);
    end % if strcmp on
                   
  
%%%%%%%%%%%%%%%%%%%%%%%%
%%% Auto Axis Limits %%%
%%%%%%%%%%%%%%%%%%%%%%%%
case '#AutoExpandAxis',
    AutoAxisHandle = sUD.h.menu.ViewAutoScale;
    if strcmp( 'off',get( AutoAxisHandle, 'Checked' ) ),
      set( AutoAxisHandle, 'Checked', 'on' );
    else,
      set( AutoAxisHandle, 'Checked', 'off' );
    end % if strcmp off
    
%%%%%%%%%%%%%%%%%%%%%%%
%%% Set Axis Limits %%%
%%%%%%%%%%%%%%%%%%%%%%%
case '#SetAxisLimits',
    set( WorkingFig, 'CurrentAxes', WorkingAxes );
    AxCall=['axlimdlg(''ApplyCallback'');'                  , ...
            'CurFig=get(0,''CurrentFigure'');'              , ...
            'Data=get(CurFig,''UserData'');'                , ...
            'AxHandle=get(Data(1,1),''UserData'');'         , ...
            'FigHandle=get(AxHandle,''Parent'');'           , ...
            'set(0,''CurrentFigure'',FigHandle);'           , ...
            'anfigure(''#Reset'',FigHandle);'               , ...
            'set(0,''CurrentFigure'',CurFig);'                ...
           ];
           % KGK--hey, make sure that 'ansimltn(''#Reset'',FigHandle);'  is correct
    String=['Axes Limits: ' get_param( sUD.m.hAnimationBlock, 'Name' )];
    
    axlimdlg( String                                            , ...
              [0 0]                                             , ...
              ['X-Axis Range'; 'Y-Axis Range']                   , ...
              [WorkingAxes, NaN, WorkingAxes]                    , ...
              ['x'; 'y']                                         , ...
              [get( WorkingAxes, 'XLim' ); get( WorkingAxes, 'YLim' )] , ...
              AxCall                                              ...
             );

%%%%%%%%%%%%%%%%%%%%%
%%% Change Labels %%%
%%%%%%%%%%%%%%%%%%%%%
case '#ChangeLabels',

    % This is tricky. We are modifying three different objects
    hTarget     = [ get( WorkingAxes, 'Title'  ), ...
                    get( WorkingAxes, 'XLabel' ), ...
                    get( WorkingAxes, 'YLabel' )  ...
                  ];              
    % Proerties of the objects that we are trying to change (also field names)
    cProperty   = { 'String','String','String' };
    
    % Prompts for editable text boxes              
    cLabels     = {'Title:','X-axis Label:','Y-axis Label:'};
    % Initial values for editable text boxes              
    cValues     = get( hTarget, {'String'} );  
    
    % Function to call when done, and the action to take when callin it
    MyMethod = 'anoption';
    MyAction = '#UpdateLabels';
     
    % Title for the property dialog figure
    FigTitle  = 'Axis Label Settings';
    
    % Help text
    FigHelp   = 'This dialog allows you to set the labels on the current axes.';
      
    anprpdlg( '#Initialize' , hTarget       , WorkingFig , ...
              cLabels       , cProperty     , cValues    , cProperty , ... 
              MyMethod      , MyAction      , FigTitle   ,  FigHelp    ...                        ...
            );
  
%%%%%%%%%%%%%%%%%%%%%
%%% Update Labels %%%
%%%%%%%%%%%%%%%%%%%%%
case '#UpdateLabels',

    % No action taken. Its all done.
  
%%%%%%%%%%%%%%%%%%%%
%%% Find Objects %%%
%%%%%%%%%%%%%%%%%%%%
case '#FindObjects', 
    % Autoscale axes long enough to bring everything into view
    set( WorkingAxes, 'XLimMode', 'auto', 'YLimMode', 'auto' );
    drawnow
    set( WorkingAxes, 'XLimMode', 'manual', 'YLimMode', 'manual' );
          
%%%%%%%%%%%%%%%%%%%%%%%
%%% Hide Status Bar %%%
%%%%%%%%%%%%%%%%%%%%%%%
case '#ShowStatus', % Toggle the status bar on or off
    %----------------------------------------------------------------------------------------
    % Gather useful information about the state of the figure
    %----------------------------------------------------------------------------------------    
    AxisPos = get( sUD.h.menu.ViewSeeStatus, 'UserData' ); % Alternate dimentions for the axes
    NewPos  = get( WorkingAxes          , 'Position' ); % Current Axes position
  
    %----------------------------------------------------------------------------------------
    % Determine new menu/control state and new axes position
    %----------------------------------------------------------------------------------------
    if strcmp( get( sUD.h.menu.ViewSeeStatus, 'Checked' ), 'on' ), 
        %------------------------------------------------------------------------------------
        % Visibility Used to be On, so now turn it off
        %------------------------------------------------------------------------------------
        % Set control state to off (will turn visibility off and uncheck the See Status menu)
        NewCtrlState = 'off'; % 
        % Add all controls to toggle list (ALL controls get turned off)
        cAllControls = struct2cell( sUD.h.ctrl ); % cell array
        hList = [ cAllControls{:} ];              % regualr matrix
        % Select alternate position for axes (i.e. on top of the invisible uicontrols)
        NewPos( [2 4] ) = AxisPos( 2, [2 4] ); 
        
    else,
        %------------------------------------------------------------------------------------
        % Visibility Used to be Off, so now turn it back on
        %------------------------------------------------------------------------------------
        % Set control state to on (will turn visibility on and check the See Status menu)
        NewCtrlState = 'on'; % 
        % Generate list of handles for Status Bar uicontrols that will be toggled
        hList = [
                   sUD.h.ctrl.pushStartStop
                   sUD.h.ctrl.pushCloseWindow
                   sUD.h.ctrl.frameStatusBar
                   sUD.h.ctrl.textStatusMessage 
                ];  % (these uicontrols are always visible)
        % Add simulation-dependant controls to visibility list as required
        if strcmp( get( sUD.h.ctrl.pushStartStop, 'String' ), 'Start' ), 
            % Simulation is not running, Check to see if reset button is needed  
            if strcmp( get( WorkingFig, 'KeyPressFcn' ), 'ansimltn #WarnPress' ),
                hList = [ hList; sUD.h.ctrl.pushReset ];
            end        
        else,
            % Simulation is running; append the 'trails controls to the list
            hList = [ hList; sUD.h.ctrl.checkShowTrails; sUD.h.ctrl.pushClearTrails ];
        end % if strcmp( get( sUD.h.ctrl.pushStartStop, 'String' ), 'Start' )
    
        % Select standard position for axes (i.e. away from the visible uicontrols)
        NewPos( [2 4] ) = AxisPos( 1, [2 4] );
    
    end %if strcmp on

    %----------------------------------------------------------------------------------------
    % Take action! Check/uncheck menus; show/hide controls, and move the axes
    %----------------------------------------------------------------------------------------
    set( sUD.h.menu.ViewSeeStatus , 'Checked' , NewCtrlState ); % toggle menu checkmark
    set( hList                    , 'Visible' , NewCtrlState ); % toggle uicontrols
    set( WorkingAxes              , 'Position', NewPos       ); % adjust axes position
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Hide Object Buttons %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
case '#ShowTools',
    %----------------------------------------------------------------------------------------
    % Gather useful information about the state of the figure
    %----------------------------------------------------------------------------------------
    hSeeMeMenu = sUD.h.menu.ViewSeeTools;  % handle to "Show Tools" menu
    hTools     = get( hSeeMeMenu, 'UserData' ); % handle of toolbar axes and children
                      
    AxisPos = get( sUD.h.menu.ViewSeeStatus, 'UserData' ); % holds alternative axes positions
    NewPos  = get( WorkingAxes          , 'Position' ); % current position (will be changed)   
    
    %----------------------------------------------------------------------------------------
    % Determine how we should adjust the toolbar, menu, and axes
    %----------------------------------------------------------------------------------------
    if strcmp( get( hSeeMeMenu, 'Checked' ), 'on' ),
        NewCtrlState = 'off';                  % Hide tools and uncheck the menu
        NewPos( [1 3] ) = AxisPos( 2, [1 3] ); % move axes  out some
    else,
        NewCtrlState = 'on';                   % Show tools and put a check on the menu
        NewPos( [1 3] ) = AxisPos( 1, [1 3] ); % move axes in some
    end %if strcmp on
    
    %----------------------------------------------------------------------------------------
    % Make the adjustments
    %----------------------------------------------------------------------------------------
    set( hTools(2:end)  , 'EraseMode'   , 'normal'      );  % *change all but the tool axes  
%    set( WorkingAxes    , 'Position'    , NewPos        );  % adjust axes position
    set( hSeeMeMenu     , 'Checked'     , NewCtrlState  );  % toggle menu checkmark
    set( hTools         , 'Visible'     , NewCtrlState  );  % toggle toolbar visibility
    set( hTools(2:end)  , 'EraseMode'   , 'none'        );  % *change all but the tool axes 
    % bug work around  CAN WE SKIP IT?
    %  set( gcbf, 'Color',[0 0 0]);  
    drawnow
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Find Simulink Diagram %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case '#FindModel',
 open_system( get_param( sUD.m.hAnimationBlock, 'Parent' ) );
 
%%%%%%%%%%%%%
%%% Error %%%
%%%%%%%%%%%%%
otherwise
    disp(['ANOPTION: Unknown action: ' Action ] )
    
end % if strcmp Action
