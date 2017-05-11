function ansimini( Action, FullBlockName )

%ANSIMINI Initialize figure for SIMULINK animations.
%	ANSIMINI(ACTION) is the initialization function for SIMULINK
%	animations.  
%
%	ACTION may be one string:
%	   '#Initialize'  Initialize the figure window.
%
%	The following uicontrols contaain information in their UserData field:
%
%	Location                       Data                      Size
%	                                               (E = After Evaluation)
%	---------------------------------------------------------------------
%	SimulinkAnimationMaskParameter hFig               1
%
%	SimulinkAnimationMaskHelp      FileName                 Variable Size
%
%	WorkingAxes                    [Handle1 FunctionCall1   1,8
%	                                Handlen FunctionCalln]  1,8
%
%       StartButton                    Static Info              Variable
%
%       ResetButton                    Static Color Info        Variable
%
%	ANLINEObject                   XText                    100
%	                               YText                    100
%	                               Color                    100
%
%	ANDOTObject                    XPosition                E 1
%	                               YPosition                E 1
%	                               MarkerSize               E 1
%	                               Color                    E 3
%
%	ANRECTObject                   XPosition                E 1
%	                               YPosition                E 1
%	                               Width                    E 1
%	                               Height                   E 1
%	                               Rotation                 E 1
%	                               Color                    E 3
%
%	ANTEXTObject                   Position                 E 3
%	                               Extent                   E 4
%	                               FontSize                 E 1
%	                               Rotation                 E 1
%	                               Color                    E 3
%	                               HorizontalAlignment      8
%	                               VerticalAlignment        8
%	                               String                   75
%	
%	hFigCloseHandle          InitOnce Flag            1
%
%	PropertiesDialog               hFigure            1
%	                               CurrentPoint             1
%
%	PropertiesDialogCancel         CurrentObjectUserData    (3,5, or 100)
%
%	PropertiesDialogHelp           HelpText                 Variable Size
%
%	MenuFile                       Close Figure Flag        1
%
%	MenuEditNew                    NewFunctionCalls         (NumObjType,8)
%
%	MenuEditModify                 Handle DeselectColor     NumObjx([1,3])
%
%	MenuEditSetIC                  IC Vector                (1,100)
%
%	MenuOptionGrid                 WorkingAxesPosition      4
%
%	MenuOptionAutoAxis             100 Time Steps           100x4
%
%	MenuOptionHideStatus           StatusButtonHandles      5
%
%	MenuOptionReset                Reset Figure Flag        1
%
%	MenuOptionHideButtons          ObjectButtonHandles      NumObjTypes
%
%	MenuSimulationStart            MatchedObjectTypePairs   2*NumObjTypes
%
%	MenuSimulationReset            ButtonDownPosition       2x3
%
%	hFigure                              OLD
%                                  SimulinkTopBlockHandle   1
%	                               WorkingAxesHandle        1
%	                               AutoAxisHandle           1
%	                               MenuSim...StartHandle    1
%                                        NEW
%      UserData structure     UD 
%         * h = handles       |--.h  
%                             |   |--.fig  .Animation
%                             |   |        .Properties
%                             |   |--.menu .File
%                             |   |        .FileLoad
%                             |   |        .FileSave
%                             |   |        .FileClose
%                             |   |        .Edit
%                             |   |        .EditNew
%                             |   |        .EditDelete
%                             |   |        .EditDeleteAll
%                             |   |        .EditModify
%                             |   |        .View
%                             |   |        .ViewAxisOn
%                             |   |        .ViewGridOn
%                             |   |        .ViewBoxOn
%                             |   |        .ViewSquareAxis
%                             |   |        .ViewAutoScale
%                             |   |        .ViewTickLabelsOn
%                             |   |        .EditAxisLimits
%                             |   |        .ViewChangeLabels
%                             |   |        .ViewSeeStatus
%                             |   |        .ViewSeeTools
%                             |   |        .ViewFindAll
%                             |   |        .ViewFindModel
%                             |   |        .Simulation
%                             |   |        .SimStart
%                             |   |        .SimRestart
%                             |   |        .SimReset
%                             |   |        .SimSetIC
%                             |   |--.ctrl .pushStartStop
%                             |   |        .pushReset
%                             |   |        .pushCloseWindow
%                             |   |        .frameStatusBar
%                             |   |        .textStatusMessage
%                             |   |        .checkShowTrails
%                             |   |        .pushClearTrails
%                             |   |        .textStatusMessage
%                             |   |
%                             |   |--.axes .animation
%                             |            .toolbar
%                             |
%           * m = model       |--.m  .Name
%                             |      .hAnimationBlock
%                             |      .hAnsimBlock
%                             |
%           * d = data        |--.d
%
%
%	See also ANCOMLOC, ANCUROBJ, ANDOT   , ANDRAG  , ANDRAW  , ANEDIT  , 
%	         ANFIG   , ANFILE  , ANGETCLR, ANGETPOS, ANLINE  , ANOBJ   ,  
%	         ANOPTION, ANPATCH , ANPRPDLG, ANRECT  , ANRESET , ANSETOBJ,
%	         ANSIM   , ANSIMLTN, ANTEXT  .

%	Loren Dean  March, 1995.
%   $Author$  $State$
%	Copyright (c) 1990-97 by The MathWorks, Inc.
% 	$Revision$  $Date$

% V 1.1  anoption and andraw modified for correct autoscaling so upper
%        and lower limits cannot get to be equal to each other.

%==============================================================================

%------------------------------------------------------------------------------
% Validate input argument
%------------------------------------------------------------------------------
% Bail.
if nargin == 0; disp('Ansimini must be given an Action (hint: #Initialize)'); return; end
% Adapt
if nargin == 1; FullBlockName = gcb; end;
% Validate
if ~strcmp(Action,'#Initialize'), error('Invalid Action for ANSIMINI.'); end

%------------------------------------------------------------------------------
% Bring up ANSIM GUI (find by Tag), or create new invisible, blank figure
%------------------------------------------------------------------------------
UserDataStruct.d.FigureStatus = 'Incomplete';
% % [ hFig, ExistingFig ] = initfig( 'Tag'       , FullBlockName  , ...
% %                                  'UserData'  , UserDataStruct , ...
% %                                  'Visible'   , 'off'            ...
% %                                ); % if new, make invisible
hFig = findobj( allchild(0), 'flat', 'Tag', FullBlockName );

%------------------------------------------------------------------------------
% (Re)Initialize the GUI if required
%------------------------------------------------------------------------------
if isempty( hFig ),
    % Good. A clean start.
    fprintf('\n Working...');

    % Make a new figure.
    UserDataStructure.d.FigureStatus = 'Incomplete';
    hFig = figure( 'UserData', UserDataStruct,  'Visible', 'off' );
    
    % Initialize
    local_InitializeDashboard( hFig, FullBlockName );  
     
    % Fini
    fprintf(' Done.\n')
    
else,
    % Hmmm. There is an Ansim figure out there for this model,
    % but is it a mutant (i.e. half built)?
    sFigUserData = get( hFig, 'UserData' ); 
    
    % Check for mutancy (be very careful--mutants don't always have
    % even the basic properties of a proper Ansim figure!)
    if isstruct( sFigUserData ) | ...
         isstr( sFigUserData.d.FigureStatus ) ...
         & strcmp( sFigUserData.d.FigureStatus, 'Incomplete' ),
            % Looks like a mutant figure! Close the figure and try again
            close( hFig ); fprintf('(Cleaning up)  Working...');
            ansimini( '#Initialize', FullBlockName );       
    end % if isstruct       

    % Bring it to the front
    figure( hFig )
    
end % if ~ExistingFig
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %                                                                   %
%   END   %  function ansimini                                                %
%         %                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %                                                                   %
%  BEGIN  %  function local_InitializeDashboard                               %
%         %                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function local_InitializeDashboard( hFig, FullBlockName );

% This is a local function which builds an ANSIM dashboard
%
%==============================================================================
% NEW FIGURE
%==============================================================================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Assign Figure Dimensions here  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FigUnits  = 'Points';
FigWidth  = 450; 
FigHeight = 360;

%------------------------------------------------------------------------------
% Determine the current screen size (in points)
%------------------------------------------------------------------------------
ScreenUnits = get( 0, 'Units' );        set( 0, 'Units', FigUnits );
ScreenSize = get( 0, 'ScreenSize' );    set( 0, 'Units', ScreenUnits );

%------------------------------------------------------------------------------
% Calculate Figure Position based on screen size, and adjust fig 
%------------------------------------------------------------------------------
FigPos = [ ( ScreenSize(3:4) - [ FigWidth FigHeight ] )/2, FigWidth, FigHeight];
set( hFig,  'Units'        , FigUnits               , ...        
            'Position'     , FigPos                 , ...
            'Color'        , [0 0 0]                  ...
    );
    
    
%==============================================================================
% ADD AXES
%==============================================================================
hWorkingAxes = anaxes( '#New', hFig );

%==============================================================================
% NEW CONTROLS
%==============================================================================

%------------------------------------------------------------------------------
% Add a Status Bar below the axes (gives status; provides start/stop buttons)
%------------------------------------------------------------------------------
structStatusBarHandles = local_AddStatusBar( hFig, hWorkingAxes );

%------------------------------------------------------------------------------
% Add basic menus 
%------------------------------------------------------------------------------
structMenuHandles = local_AddMenus( hFig ); 

%------------------------------------------------------------------------------
% Set Interruptible and BusyAction params for existing axes and uicontrols
%------------------------------------------------------------------------------
set( findobj(hFig), 'Interruptible', 'off', 'BusyAction', 'queue' );

%------------------------------------------------------------------------------
% Add a toolbar and additional menus (used for adding new Animation Objects)
%------------------------------------------------------------------------------
hToolBarAxes = local_AddToolbarEtc( hFig, structMenuHandles.EditNew );

%------------------------------------------------------------------------------
% Initialize the Menus (tack on add'l info to make them functional)
%------------------------------------------------------------------------------
local_InitializeMenus( structMenuHandles, hToolBarAxes, hWorkingAxes );
                    

%==============================================================================
% Make connections to the SL model
%==============================================================================

%------------------------------------------------------------------------------
% Get the SL Model data (note: used for the Figure's UserData, too)
%------------------------------------------------------------------------------
BlockHandle         = get_param( FullBlockName,'Handle' );
BlockHandleNested   = get_param( [FullBlockName,'/ansim'], 'Handle');
SimName             = get_param( bdroot( BlockHandle ), 'Name' );

%------------------------------------------------------------------------------
% Initialize properties of the Nested Block 
%------------------------------------------------------------------------------
ansim( [], [], BlockHandleNested,'SetFigure', hFig );
                    
%==============================================================================
% Assign UserData and other finishing properties to the figure 
%==============================================================================

%------------------------------------------------------------------------------
% Assemble the HG Handles structure for hFig's UserData 
%------------------------------------------------------------------------------
structAxes    = struct( 'animation' , hWorkingAxes , ...
                        'toolbar'   , hToolBarAxes   ...
                      );
                      
structHandles = struct( 'fig' , struct( 'Animation' , hFig, ...
                                        'Properties', [] ), ...
                        'menu', structMenuHandles      , ...
                        'ctrl', structStatusBarHandles , ...
                        'axes', structAxes               ...
                      );
                    
%------------------------------------------------------------------------------         
% Assemble the SL Model structure for hFig's UserData 
%------------------------------------------------------------------------------
structModel = struct( 'Name'            , SimName               , ...
                      'AnsimSubSysName' , FullBlockName         , ...
                      'hAnimationBlock' , BlockHandle           , ...
                      'hAnsimBlock'     , BlockHandleNested       ...
                    );
                    
%------------------------------------------------------------------------------         
% Assemble the Data structure for hFig's UserData 
%------------------------------------------------------------------------------
structData = struct( 'FigureStatus' , 'Incomplete'   , ...       
                     'SimData'      , 0              ...
                   );
%------------------------------------------------------------------------------         
% Assemble the SL Model structure for hFig's UserData 
%------------------------------------------------------------------------------
sUserData = struct( 'h'  , structHandles    , ...
                    'm'  , structModel      , ...
                    'd'  , structData       ...
                  ); 
%------------------------------------------------------------------------------
% Concatinate an appropriate Figure Name based on the Animation Block's name
%------------------------------------------------------------------------------
FigName = ['Animation: ' get_param(BlockHandle,'Name') ...
           '   ' ...
           'File: (none)'
          ];

%------------------------------------------------------------------------------
% Reset properties of the Working Figure
%------------------------------------------------------------------------------
set( hFig, ...
        'Tag'          , FullBlockName              , ...
        'Name'         , FigName                    , ...
        'NumberTitle'  , 'off'                      , ...
        'Visible'      , 'off'                      , ...
        'BackingStore' , 'off'                      , ...
        'MenuBar'      , 'none'                     , ...
        'IntegerHandle', 'on'                       , ...
        'BusyAction'   ,'queue'                     , ...
        'Interruptible', 'off'                      , ...
        'Pointer'      , 'watch'                    , ...
        'KeyPressFcn'  , 'anfigure #KeyPress'       , ...
        'CloseRequest' , 'anfile #Close'            , ...
        'UserData'     , sUserData                    ...
   );
% Old UserData: [ BlockHandle, hWorkingAxes, AutoAxisMenu, StartMenu ] 

drawnow


%==============================================================================
% If simulation is currently running (!), disable certain features
%==============================================================================
%------------------------------------------------------------------------------
% Check for an up-to-data ansim block (version with built-in functionality) 
%------------------------------------------------------------------------------
OldBlockFlag = isempty( get_param(BlockHandle,'NameChangeFcn') ) ...
                | isempty( get_param(BlockHandleNested,'StartFcn') );

if strcmp(get_param(SimName,'SimulationStatus'),'running')      | ...
   strcmp(get_param(SimName,'SimulationStatus'),'initializing') | ...
   strcmp(get_param(SimName,'SimulationStatus'),'paused')       | ...
   strcmp(get_param(SimName,'SimulationStatus'),'terminating'),
   % This is big trouble if an old ansim block is being used.
   if OldBlockFlag, close hFig; return; end;
   % Otherwise, just put the figure in a paused state
   anfigure( '#Start/Stop', hFig );
else
    % Update the block right now if it is an old one
    if OldBlockFlag,  ansim([],[],[],'UpdateBlock',hFig); end
end


%------------------------------------------------------------------------------
% Make the status bar and toolbar match the menus
%------------------------------------------------------------------------------
anoption( '#ShowStatus', hFig );
anoption( '#ShowTools', hFig );

%==============================================================================
% Auto-load data file for this Animation Block (if it exists)
%==============================================================================
local_CheckAutoLoad( hFig, BlockHandle );


%==============================================================================
% Turn on the Figure!!!!
%==============================================================================
% Make sure it is marked as an active figure
%------------------------------------------------------------------------------
newUD = get( hFig, 'UserData' ); % get Userdata to see if anything has changed
if isstruct( newUD ) & strcmp( newUD.d.FigureStatus, 'Incomplete' ),
   newUD.d.FigureStatus = 'Active';
   set( hFig, 'UserData', newUD )
end
%------------------------------------------------------------------------------
% Make it visible
%------------------------------------------------------------------------------
set( hFig, ...
    'Pointer'          ,'arrow'                 , ...
    'Visible'          ,'on'                    , ...
    'HandleVisibility' ,'callback'              , ...
    'ButtonDownFcn'    ,'anfigure #ButtonDown'  ...
    );
   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %                                                                   %
%   END   %   function local_InitializeDashboard                              %
%         %                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %                                                                   %
%  BEGIN  %   function local_AddMenus                                         %
%         %                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function structMenuHandles = local_AddMenus( hFig )

% This is a local function which adds most of the menus to the ANSIM dashboard
% Additional menus for each Animation Object that can be created will be added
% later. Initial conditions for each menu will also be added later, once more
% components of the Dashboard have been put in place
%
% Returns a structure with a field for each menu, 
%  and the menu's handle in each field
%
%==============================================================================
% Menu Labels:  File  Edit  Options  Simulation
%------------------------------------------------------------------------------
MenuInfoLabels = {                              
                    '&File'
                    '>&Load Setup^o'
                    '>&Save Setup^s'
                    '>Save &As'
                    '>>&S-function^f'
                    '>>&Movie^m'
                    '>&Close^w'
                    ...
                    '&Edit'
                    '>&New Object^n'
                    '>&Delete Object^x'
                    '>&Modify Object...^e'
                    ...
                    '&View'
                    '>&Axis On^1'
                    '>&Grid On^2'
                    '>&Border On^3'
                    '>S&quare Axis^4'
                    '>A&uto Scale On^5'
                    '>Tic&k Marks/Labels On^6'
                    '>&Change Axis Limits...^l'
                     ...
                    '>Show &Status Bar^7'
                    '>Show &Tool Bar^8'
                     ...
                    '>Find All &Objects^a'
                    '>Find Simulink &Model'
                    ...
                    '&Simulation'
                    '>&Start Simulation^t'
                    '>&Reset^z'
                    '>Set &Initial Inputs...^i'
                    '>Set Sample &Period...^9'
                };
%                     '>&Open'
%                     '>>&Setup File^o'
%                     '>>&Data File^d'

%------------------------------------------------------------------------------
% Menu Callbacks
%------------------------------------------------------------------------------
MenuInfoCalls = { 
                   ''
                   'anfile #Load'
                   'anfile #Save'
                   ''
                   'ansim_sfcn_writer(gcbf)'
                   'anmagic #Movie'
                   'anfile #Close'
                   ...
                   ''
                   ''
                   'anfigure #DeleteObj'
                   'anfigure #ModifyObj'
                   ...
                   ''
                   'anoption #AxisOn'
                   'anoption #Grid'
                   'anoption #Box'
                   'anoption #SquareAxis'
                   'anoption #AutoExpandAxis'
                   'anoption #TickMark'
                   'anoption #SetAxisLimits'
                   ...
                   'anoption #ShowStatus'
                   'anoption #ShowTools'
                   ...
                   'anoption #FindObjects'
                   'anoption #FindModel'
                   ...
                   ''
                   'anfigure #SimCmd'
                   'anfigure #Reset'
                   'anfigure #SetIC'
                   'anfigure #SetTs'
               };
%                    ''
%                    'anfile #Load'
%                    'anfile #DataIn'
%                    'anfigure #SimRecord'
%                    'anfigure #PlayBack'

%------------------------------------------------------------------------------
% Menu Tags
%------------------------------------------------------------------------------
%------------------------------------------------------------------------------
% These are field names for a structure containing the handles for each menu.
% This will also be used to create the Tag strings of the menus, which will 
%%% No Longer be generated by prepending 'Menu' to the field names to match 
%%% v4 code still out there. They will just be the tags themselves.
%------------------------------------------------------------------------------
cFieldList = {  'File'
                'FileLoad'
                'FileSave'
                'FileSaveAs'
                'FileSaveAsSfcn'
                'FileSaveAsMovie'
                'FileClose'
                ...
                'Edit'
                'EditNew'
                'EditDelete'
                'EditModify'
                ...
                'View'
                'ViewAxisOn'
                'ViewGridOn'
                'ViewBoxOn'
                'ViewSquareAxis'
                'ViewAutoScale'
                'ViewTickLabelsOn'
                'EditAxisLimits'
                'ViewSeeStatus'
                'ViewSeeTools'
                'ViewFindAll'
                'ViewFindModel'
                ...
                'Simulation'
                'SimStart'
                'SimReset'
                'SimSetIC'
                'SimSetTs'
              };

%                 'FileLoad'
%                 'FileLoadSetup'
%                 'FileLoadData'
%                 'SimRecord'
%                 'SimPlay'
                
%------------------------------------------------------------------------------
% Create Menus!
%------------------------------------------------------------------------------
MenuHandles = makemenu( hFig    , ...
                        MenuInfoLabels, ...
                        MenuInfoCalls , ...
                        cFieldList    ...
                      );
					  
% Hide SaveAs menus
set( MenuHandles(4), 'visible', 'off')

%------------------------------------------------------------------------------
% Create structure of Menu handles!
%------------------------------------------------------------------------------               
% combine field names with associated MenuHandles
cFieldList = cat(2, cFieldList, num2cell( MenuHandles ) )';

% create a structure to hold all the menu handles
structMenuHandles = struct( cFieldList{:} );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %                                                                   %
%   END   %  function local_AddMenus                                          %
%         %                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %                                                                   %
%  BEGIN  %  function local_AddToolbarEtc                                     %
%         %                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function hToolBarAxes = local_AddToolbarEtc( hFig, MenuHandle )

%local_AddToolbarEtc	Initialize object icons for animations.
%
%	local_AddToolbarEtc(WORKINGFIG,MENUHANDLE) initializes object 
%   icons on the animation figure window.  
%
%	WORKINGFIG is the handle for the figure that the icons are
%	to be displayed on.
%
%	MenuHandle is the handle for the Edit -> New Objects menu.
%
%	------------------------------------------------------------------
%	Add additional Animated Objects by creating an animation function
%   in a seperate M-file and listing it in the set-up section of this 
%   file (requires modification of this file). 
%   The animation function in the separate M-file must use the format:
%
%	  function OBJTYPE( ACTION, OBJHANDLE, WORKINGFIGURE, U )
%	  
%	This function must contain subroutines for ACTION types:
%       '#Draw','#New', and '#Modify'.
%   The object's handle, OBJHANDLE, the handle of the parent figure, 
%   WORKINGFIGURE, and the Simulink input vector, U, will be provided 
%   at each function call.
%	UserData for the object is used to store information.
%   See existing Animation functions for typical behavior.
%
%	See also ANDOT, ANRECT, ANTEXT, ANLINE, ANPATCH

%	Loren Dean  March, 1995. Modified by KGK-2/97
%	Copyright (c) 1995 by The MathWorks, Inc.


            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Additional objects are added here %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% For each new Object you wish to add to the Animated Objects palet, %
%% add one additional descriptive line to each of the following five  %
%% parameter matrices. Then be sure the animation function for the    %
%% Object (as listed in its callback) is on the MATLAB path.          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------
% PARAMETER 1 - Function used to draw icon on object-tool button
% (See btnicon function for help).
%--------------------------------------------------------------------
BtnObjIconFunctions = [
                      'btnicon(''select'')    '
                      'btnicon(''text'')      ' 
                      'animicon(''lineobj'')  ' 
                      'btnicon(''rect'')      ' 
                      'btnicon(''fillcircle'')' 
                      'animicon(''patchobj'') ' 
                      ];
                      
%--------------------------------------------------------------------
% PARAMETER 2 - Tag for the object-tool button
%--------------------------------------------------------------------
BtnObjButtonIDs = [  
                   'BtnSelectArrow'
                   'BtnObjectText '
                   'BtnObjectLine '
                   'BtnObjectRect '
                   'BtnObjectDot  '
                   'BtnObjectPatch'
                  ];  
%--------------------------------------------------------------------
% PARAMETER 3 - Button Callbacks.   Note shorter blank string in 
% first row accounts for double quotes in remaining rows
%--------------------------------------------------------------------
BtnObjCallBack = [  'anfigure(''#NormalMode'', gcf        )'
                    'anfigure(''#NewObj'', gcbf, ''antext'' )'
                    'anfigure(''#NewObj'', gcbf, ''anline'' )'
                    'anfigure(''#NewObj'', gcbf, ''anrect'' )'
                    'anfigure(''#NewObj'', gcbf, ''andot''  )'
                    'anfigure(''#NewObj'', gcbf, ''anpatch'')'
                 ];                 
                   
%-------------------------------------------------------------------------------
% Bring the hFigure to the front                   
%-------------------------------------------------------------------------------
set( 0, 'CurrentFigure', hFig );

%-------------------------------------------------------------------------------
% Count the number of Object icons in the list                   
%-------------------------------------------------------------------------------
Len = length( BtnObjIconFunctions(:,1) );

%-------------------------------------------------------------------------------
% Assign basic properties for all buttons
%-------------------------------------------------------------------------------
BtnObjGroupID         = 'ObjectButtons'; % Key string used to look up btn status
BtnObjPressTypes      = 'toggle';     % Btns stay down when pressed
BtnObjInitialState    = zeros(Len,1); % All btns deselected
BtnObjInitialState(1) = 1;            % Ooops, start with #1 selected
BtnObjExclusive       = 'yes';        % Make these act like radio buttons
BtnObjGroupSize       = [ Len 1 ];    % Len rows and one column
BtnObjPosition        = [ 0.03 (0.82 - 0.06*Len), 0.06, (0.06*Len) ];
BtnObjOrientation     = 'vertical';   % An up and down row of buttons

%-------------------------------------------------------------------------------
% Create the buttons
%-------------------------------------------------------------------------------
hToolBarAxes = btngroup(                                     ...
                         'IconFunctions',BtnObjIconFunctions, ...
                         'GroupID'      ,BtnObjGroupID      , ...
                         'ButtonID'     ,BtnObjButtonIDs    , ...
                         'PressType'    ,BtnObjPressTypes   , ...
                         'InitialState' ,BtnObjInitialState , ...
                         'Exclusive'    ,BtnObjExclusive    , ...
                         'Callbacks'    ,BtnObjCallBack     , ...
                         'GroupSize'    ,BtnObjGroupSize    , ...
                         'Units'        ,'normalized'       , ...
                         'Position'     ,BtnObjPosition     , ...
                         'Orientation'  ,BtnObjOrientation    ...
                        );
%-------------------------------------------------------------------------------
% Label the button group (...?)
%-------------------------------------------------------------------------------
BtnObjText = text( 'Parent'            , hToolBarAxes       , ...
                   'Position'          , [0.5 1]            , ...                                          ...
                   'String'            , 'Objects'          , ...
                  'Tag'                , 'ObjectButtonsText', ...
                  'Color'              , [1 1 1]            , ...
                  'HorizontalAlignment', 'center'           , ...
                  'VerticalAlignment'  , 'bottom'             ...
      );
drawnow 

%%% MENUS

%--------------------------------------------------------------------
% PARAMETER 1 - Menu label for Edit -> New Object -> submenu
% (See the makemenu function for help).
%--------------------------------------------------------------------
cMenuInfoLabels = {             
                   '&Text'
                   '&Line'
                   '&Rectangle'
                   '&Dot'
                   '&Patch'
                  };

%--------------------------------------------------------------------
% PARAMETER 2 - Callbacks for each menu item 
%               (referenced by Object-tool button)
%--------------------------------------------------------------------
cMenuCallbacks = {
                   'anfigure( ''#NewObj'', gcbf, ''antext'' )'
                   'anfigure( ''#NewObj'', gcbf, ''anline'' )'
                   'anfigure( ''#NewObj'', gcbf, ''anrect'' )'
                   'anfigure( ''#NewObj'', gcbf, ''andot'' )'
                   'anfigure( ''#NewObj'', gcbf, ''anpatch'' )'
                  }; 
                 
%--------------------------------------------------------------------
% PARAMETER 3 - Tag for the New Object menu listings
% (The standard tag format of EditNewOBJECT is recommended).
%--------------------------------------------------------------------
cMenuInfoTags = {                      
                 'EditNewText'
                 'EditNewLine'
                 'EditNewRectangle'
                 'EditNewDot'
                 'EditNewPatch'
                };
                
%-------------------------------------------------------------------------------
% Add a submenu listing to Edit -> New Object for each Object
%-------------------------------------------------------------------------------
MenuHandles = makemenu( MenuHandle     , ...
                        cMenuInfoLabels , ...
                        cMenuCallbacks  , ...
                        cMenuInfoTags    ...
                       );
                     
%-------------------------------------------------------------------------------
% Set parameters for the new menus
%-------------------------------------------------------------------------------
set( MenuHandles, 'Interruptible', 'off', 'BusyAction', 'queue' );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %                                                                   %
%   END   %  function AddToolbarEtc                                           %
%         %                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                             %
%  BEGIN : function local_AddStatusBar                                        %
%                                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function stCtrl = local_AddStatusBar( hFig, hAxes );

% This is a local function which adds a status bar to the ANSIM dashboard
% Returns a structure containing handles to each uicontrol in the Status Bar
% stored in appropriately named fields
% 
%%% NOTE: Order of handles in  structure has been made to match 
%         old StatusBarHandles vector. This is important for backwards
%         compatibility (at least until I've finished the upgrade to v5)
%
% Old StatusHandles=[BtnStart BtnReset BtnClose StatusFrm1 BtnStatus ...
%                    BtnShowTrails BtnClearTrails]
%
%==============================================================================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Assign Status Bar Dimensions here  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FrmUnits     = 'Points';          
tempUnits = get( hAxes, 'Units'    ); set( hAxes, 'Units', FrmUnits )
AxesPos   = get( hAxes, 'Position' ); set( hAxes, 'Units', tempUnits )
Frm1X        = AxesPos(1);             % align with left side of axes, 
Frm1Y        = 10;
Frm1W        = AxesPos(3);         % match axes width
Frm1H        = 55.8323;  % +98; what's that about?

%------------------------------------------------------------------------------
% Calculate a base position vector and basic property cell array
%------------------------------------------------------------------------------
BaseP = [ Frm1X Frm1Y 0 0 ];
cStandardProperties = { 'Parent'              , hFig     , ... 
                        'Units'               , FrmUnits , ...
                        'HorizontalAlignment' , 'center' , ...
                        'Visible'             , 'on'     };
                        
%------------------------------------------------------------------------------
% Initialize the data structure for the uicontrols' handles
%------------------------------------------------------------------------------
stCtrl  = struct( 'pushStartStop'     , [] , ...
                  'pushReset'         , [] , ...
                  'pushCloseWindow'   , [] , ...
                  'frameStatusBar'    , [] , ...
                  'textStatusMessage' , [] , ...
                  'checkShowTrails'   , [] , ...
                  'pushClearTrails'   , [] );
                  
%------------------------------------------------------------------------------
% Create a background frame
%------------------------------------------------------------------------------
stCtrl.frameStatusBar   = uicontrol( cStandardProperties{:}         , ...       
                            'Style'     , 'frame'                   , ...
                            'Position'  , BaseP + [0 0 Frm1W Frm1H] , ...            
                            'Units'     , 'Normal'                  , ...                
                            'Tag'       , 'StatusFrame1'              ...
                            );

%------------------------------------------------------------------------------
% Create a START Button
%------------------------------------------------------------------------------
stCtrl.pushStartStop   = uicontrol( cStandardProperties{:}             , ...  
                           'String'   ,'Start'                         , ...     
                           'Style'    ,'pushbutton'                    , ...
                           'Position' , BaseP + [ 5 30 50 20 ]         , ...            
                           'Units'    , 'Normal'                       , ...       
                           'Tag'      ,'StartButton'                   , ...
                           'CallBack' ,'anfigure #SimCmd'            ...
                           );

%------------------------------------------------------------------------------
% Create a RESET Button
%------------------------------------------------------------------------------
stCtrl.pushReset = uicontrol( cStandardProperties{:}                   , ... 
                     'String'    ,'Reset'                              , ...
                     'Style'     ,'pushbutton'                         , ...
                     'Position'  , BaseP + [ (Frm1W/2 - 10) 30 50 20 ] , ...        
                     'Units'     , 'Normal'                            , ...         
                     'Tag'       ,'ResetButton'                        , ...
                     'Visible'   ,'off'                                , ...
                     'CallBack'  ,'anfigure #Reset'            ...
                    );
                    
%------------------------------------------------------------------------------
% Create a CLOSE Button
%------------------------------------------------------------------------------
stCtrl.pushCloseWindow = uicontrol( cStandardProperties{:}            , ...   
                           'String'   , 'Close'                       , ...     
                           'Style'    , 'pushbutton'                  , ...
                           'Position' , BaseP + [Frm1W - 55 30 50 20] , ...   
                           'Units'    , 'Normal'                      , ...                       
                           'Tag'      , 'CloseButton'                 , ...
                           'CallBack' , 'anfile #Close'                 ...
                           );
                          
%------------------------------------------------------------------------------
% Create a SHOW TRAILS checkbox
%------------------------------------------------------------------------------
stCtrl.checkShowTrails = uicontrol( cStandardProperties{:}              , ...  
                           'String'   , 'Show Trails'                    , ...     
                           'Style'    , 'checkbox'                       , ...
                           'Position' , ...
                              BaseP + [ (Frm1W/2 - 10 - 100) 30 100 20 ] , ...    
                           'Units'    , 'Normal'                         , ...                    
                           'Tag'      , 'ShowTrails'                     , ...
                           'Visible'  , 'off'                            , ...
                           'CallBack' , 'anfigure #ToggleTrails'   ...
                            );

%------------------------------------------------------------------------------
% Create a CLEAR TRAILS Button
%------------------------------------------------------------------------------
stCtrl.pushClearTrails = uicontrol( cStandardProperties{:}               , ...
                           'String'  ,'Clear Trails'                     , ... 
                           'Style'   ,'pushbutton'                       , ...
                           'Position', BaseP + [(Frm1W/2 + 10) 30 100 20], ...
                           'Units'   , 'Normal'                          , ...  
                           'Tag'     ,'ClearTrails'                      , ...
                           'Visible' ,'off'                              , ...
                           'CallBack','anfigure #ClearTrails'    ...
                           );


%------------------------------------------------------------------------------
% Create the STATUS BAR
%------------------------------------------------------------------------------
stCtrl.textStatusMessage = uicontrol( cStandardProperties{:}                   , ... 
                         'String'         , ...
                            'Use Object toolbar to add animation objects'  , ...
                         'Style'          ,'text'                          , ...
                         'Position'       , BaseP + [ 5 5 (Frm1W - 10) 20 ], ... 
                         'Units'          , 'Normal'                       , ...                   
                         'BackgroundColor',[0.7 0.7 0.7]                   , ...
                         'Tag'            ,'StatusBar'                       ...
                          );
                         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %                                                                   %
%   END   %  function local_AddStatusBar                                      %
%         %                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                             %
%  BEGIN : function local_InitializeMenus                                     %
%                                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function local_InitializeMenus( sMenus, hToolBarAxes, hWorkingAxes );

% This is a local function which initializes menus in the ANSIM dashboard
% 4/2/97 KGK convert to handle structures in input arguments
% 4/2/97 KGK Eliminate all calls to findobj by using MenuHandle structure
% 5/2/97 KGK Clean-up update (get rid of obsolete menus)
%==============================================================================

%------------------------------------------------------------------------------
% FILE Menu : Initilize UserData 
%------------------------------------------------------------------------------
set( sMenus.File     , 'UserData', 0       );
set( sMenus.FileSave , 'UserData', '*.mat' );
set( sMenus.FileClose, 'UserData', 0       );

%------------------------------------------------------------------------------
% EDIT Menu : Initilize UserData; Disable edit menus (no objects to edit yet!)
%------------------------------------------------------------------------------
DisableList = [ sMenus.EditModify 
                sMenus.EditDelete 
                sMenus.FileSaveAsMovie
              ];
%                sMenus.SimPlay
set( DisableList, 'Enable' , 'off');

%------------------------------------------------------------------------------
% OPTIONS Menu : Initilize UserData; Check default menu items; Add separators
%------------------------------------------------------------------------------
% Define alternate axes positions for when the toolbar and status bar are gone
AxisPos = [ get( hWorkingAxes, 'Position' ); 0.1, 0.1, 0.85, 0.8 ];

set( sMenus.ViewAutoScale, 'UserData', ones(100,4)*50   ); % autoscale info
set( sMenus.ViewSeeStatus, 'UserData', AxisPos          ); 
set( sMenus.ViewSeeTools , 'UserData', [hToolBarAxes; get(hToolBarAxes,'Chil')] ); % *** V4--change to v5!!! ***

set( [ sMenus.ViewAxisOn       , ... 
       sMenus.ViewBoxOn        , ... 
       sMenus.ViewTickLabelsOn   ... 
      ], ...
     'Checked', 'on');

set( [ sMenus.ViewSeeStatus    , ...
       sMenus.ViewFindAll      , ...
       sMenus.EditAxisLimits   ...
     ], ...    
     'Separator', 'on' );

%------------------------------------------------------------------------------
% SIMULATION Menu :  Disable some menus; Initilize UserData
%------------------------------------------------------------------------------
set( sMenus.SimReset   , 'Enable', 'off', 'UserData', 0             );
set( sMenus.SimSetIC                    , 'UserData', mat2str([0])  );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %                                                                   %
%   END   %  function local_InitializeMenus                                   %
%         %                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                             %
%  BEGIN : function local_CheckAutoLoad                                       %
%                                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function local_CheckAutoLoad( hFig, BlockHandle );

% This is a local function which automatically loads the default data file
% for the current ANSIM model (if it exists)
%
%==============================================================================
% Get name of data file (cleverly stored in Animation Block's 'MaskHelp' param)
%------------------------------------------------------------------------------
LoadFileName = get_param( BlockHandle, 'MaskHelp' );

%------------------------------------------------------------------------------
% If no data file name can be found, leave now
%------------------------------------------------------------------------------
if isempty( LoadFileName ),
    return % nothing to do
end % if isempty

%------------------------------------------------------------------------------
% Attempt to load the named data file
%------------------------------------------------------------------------------
eval([ 'LoadFlag = 1; load ' LoadFileName ], 'LoadFlag = 0;');
 
% If loading was successful, ask user if they want to use the data
if LoadFlag == 1,
  fprintf( 'Waiting for menu selection... ' );
  LoadFile = menu( 'ANSIM Configuration Data'            , ...
                   'New Animation'                       , ...
                   ['Open existing Animation file: ' LoadFileName]   ...
                  );
  fprintf( 'Working... ');
  % New Animation: reset the load-file string
  if LoadFile == 1,
    set_param( BlockHandle, 'MaskHelp', '' );
    
  % Open existing Animation file: go ahead and load it up
  elseif LoadFile==2,
    anfile( '#Load', hFig , LoadFileName);
    
  end % if LoadFile

% Loading was not successful, give user warning that data file is bad/gone
else,
  Answer = questdlg( str2mat( [ LoadFileName ,' is an invalid Configuration file.' ], ...
                              'Attempt to Reload in the future?'...
                            ), ...
                    'Yes','No' ...
                    );
   % If  user wants to give up on the data file,  reset the load-file string
  if strcmp( Answer, 'No' ),
    set_param (BlockHandle, 'MaskHelp', '' );
  end % if strcmp

end  % if LoadFlag

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   END  : function local_CheckAutoLoad                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
