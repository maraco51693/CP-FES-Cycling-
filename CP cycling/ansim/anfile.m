function SuccessFlag = anfile(Action,hFig,FileName)
%ANFILE	Animation file menu function.
%	ANFILE(ACTION) is the callback function for the File menu on 
%	the animation figure window.
%
%	ACTION may be one of 3 strings:
%          '#Load'  Load animation data.
%	   '#Save'  Save animation data.
%	  '#Close'  Close animation window.
%
%	See also ANSIMINI.

%	Loren Dean  March, 1995.
%   4/03/97 KGK Convert from if(strcmp) to switch/case
%   4/03/97 KGK Adapt to use new UserData structure of hFig 
%   4/03/97 KGK Add local_OnOff to toggle 'on'/'off'. Eliminated many lines of code
%   5/27/97 KGK convert to local functions and streamline close functionality;
%	Copyright (c) 1995 by The MathWorks, Inc.

% Check inputs
if nargin == 1,   hFig = gcbf;    end  

% Extract important data
sFigUserData  = get( hFig, 'UserData' );

switch Action,
%%%%%%%%%%%%
%%% Load %%%
%%%%%%%%%%%%
case '#Load',
    if nargin < 3, FileName = []; end
    local_LoadAnsimData(hFig, sFigUserData, FileName);
    filetracker( 'NothingToSave', hFig );
  
%%%%%%%%%%%%
%%% Save %%%
%%%%%%%%%%%%
case '#Save',
    SavedOK = local_SaveAnsimData(hFig, sFigUserData);
    if nargout, SuccessFlag = SavedOK; end
    if SavedOK, filetracker( 'NothingToSave', hFig ); end;
    
%%%%%%%%%%%%%
%%% Close %%%
%%%%%%%%%%%%%
case '#Close',

    SavedOK = logical(1);
    
    % Check change flag. 
    if filetracker( 'AnythingToSave?', hFig ),  
        % Changes made. Ask the user if they want to save the 
        % figure before closing
        Answer = questdlg(...
            'Do you want to save the animation figure before closing it?', ...
            'Warning','Don''t Save','Cancel','Save','Save');
     
        % React based on user's response
        if strcmp(Answer,'Cancel'),     return;                 end; % Abort  
        if strcmp(Answer,'Save'),       
            SavedOK = anfile('#Save',hFig);   
        end  % Save
    end
    
    % Close the figure if still here and still Successful
    if SavedOK,
        local_CloseAnsimFigure( hFig ); 
    end

end % switch Action

%###########################################################################
% local_CloseAnsimFigure
%
% Closes the Ansim figure and all related figures.
%###########################################################################
function local_CloseAnsimFigure( hFig )

% Close any Properties Dialog Figure that is still open
Figs = findobj( allchild(0) , 'flat'                    , ...
                'Type'      , 'figure'                  , ...
                'Tag'       , 'Property Dialog Figure'    ...
              );
close( Figs );   


% Now tell the ansim block that the figure is going to be closed
ansim( [], [], [], 'DeleteFigure', hFig );

% delete the figure
set( hFig, 'CloseRequestFcn', 'closereq' );
close( hFig );

%###########################################################################
% local_LoadAnsimData
%
% Loads an ansim data file and reconfigures an existing ansim GUI based
% on the data file.
%###########################################################################
function local_LoadAnsimData( hFig, sFigUserData, FileName)

% Extract important data
sMenu         = sFigUserData.h.menu;             % pull off menu structure
SimHandle     = sFigUserData.m.hAnimationBlock;
hAxes         = sFigUserData.h.axes.animation;
sAxesUserData = get( hAxes, 'UserData' );

% Get file name and path from which to load data
if isempty(FileName),
    % Have the user pick one using a file selection dialog box
    [ FileName, PathName ] = uigetfile('*.mat','Load Animation Data');
else,
    % File name was passed in. Use it with no additional path arguments
    PathName = [];
end

% If no file picked. Quit.
if FileName==0,  return; end;   % Done. Fini. Go home.

% Load file
load([PathName FileName]);

% Check for valid data file by looking for a v5-specific variable   
if ~exist('cObjDataStructures'), 
    errordlg('Sorry. Not a valid Ansim2 data file!','Wrong Data File');
    return; % That's it. Bail.
end; % if ~exist

% Delete all objects on the axes
if ~isempty( sAxesUserData.hAllObjects )
    % See if there are more than one object left
    if length( sAxesUserData.hAllObjects ) > 1,
        % delete all but the first object
        delete( sAxesUserData.hAllObjects(2:end) );
        sAxesUserData.hAllObjects       = sAxesUserData.hAllObjects(1);
        sAxesUserData.hSelectedObjects  = [];
    end
    % Select the last object
    anfigure( '#SelectObj', hFig, sAxesUserData.hAllObjects(1) );
    % And officially delete it (to reset the menus)
    anfigure( '#DeleteObj', hFig, sAxesUserData.hAllObjects(1) );
    % Be sure the axes data is empty!
    sAxesUserData.hAllObjects = [];
    hSelectedObjects = [];
end % if

%     % Check for proper format 
%     if ~exist( 'XLabelText' ),
%         % Ah! Formatted for v4 most likely! Convert to v4/v5 
%         anconvertmat( [PathName FileName] ); 
%         % reload
%         load([PathName FileName]);
%     end % if ~exist

% Rename figure to reflect new data file
FigTitle = get( hFig, 'Name' );
TitleLoc = findstr( FigTitle, 'File: ' );
FigTitle = [ FigTitle(1:TitleLoc+5) FileName ];
set( hFig, 'Name',FigTitle );

set_param( sFigUserData.m.hAnimationBlock, 'MaskHelp', FileName);

% Make the animation axes the figure's current axes (why?)
set( hFig, 'CurrentAxes', hAxes, 'Tag', '' );

% Set UserData    
set( sMenu.SimSetIC, 'UserData', ICString );

% Set all the menus. 
% Here's the trick for checked menu items:
% 1) set it to what it is not (i.e. checked --> not checked)
% 2) invoke it's callback
% This works because callbacks base their action on the oposite of
% what the check indicates, then they reverse the check to match
% the new state. I call this "reverse psychology".

set( sMenu.ViewGridOn       , 'Checked' , local_OnOff( OnGrid ) );
anoption('#Grid',hFig)              % Use reverse psychology!!
  
set( sMenu.ViewAxisOn       , 'Checked', local_OnOff( AxisOn ) );
anoption('#AxisOn',hFig)           % Use reverse psychology!!

set( sMenu.ViewBoxOn        , 'Checked', local_OnOff( AxisBox ) );
anoption('#Box',hFig)              % Use reverse psychology!!

set( sMenu.ViewTickLabelsOn , 'Checked', local_OnOff( TickMark ) );
anoption('#TickMark',hFig)         % Use reverse psychology!!    

set( sMenu.ViewAutoScale    , 'Checked', local_OnOff( AutoScale ) );
anoption('#AutoExpandAxis',hFig)   % Use reverse psychology!!

set(sMenu.ViewSeeTools      , 'Checked', local_OnOff( HideButton ) );
anoption('#ShowTools',hFig)        % Use reverse psychology!!

set(sMenu.ViewSeeStatus     , 'Checked', local_OnOff( HideStatus ) );
anoption('#ShowStatus',hFig)       % Use reverse psychology!!

set(sMenu.ViewSquareAxis    ,'Checked', local_OnOff( SquareAxis ) );
anoption('#SquareAxis',hFig)      % Use reverse psychology!!

% Set axes label and title
XYTHandles = get( hAxes, {'XLabel', 'YLabel', 'Title'} );
set( XYTHandles{1}, 'String', XLabelText );
set( XYTHandles{2}, 'String', YLabelText );
set( XYTHandles{3}, 'String', TitleText  );

set(hAxes,'XLim',AxisLimit(1:2),'YLim',AxisLimit(3:4));

% Add all the objects, update them, and deselect them!
hAllObjects = [];
for idx = 1:length( cObjDataStructures ),
    hAllObjects(idx) = feval( cObjDataStructures{idx}.Method, ...
                             '#New', hAxes, cObjDataStructures{idx} );
    feval( cObjDataStructures{idx}.Method, '#UpdateIC',...
             hAllObjects(idx), cObjDataStructures{idx} );
    feval( cObjDataStructures{idx}.Method, '#Deselct', hAllObjects(idx) );
end % for lp

% Store the handles in the axes userdata
sAxesUserData.hAllObjects = hAllObjects;
set( hAxes, 'UserData', sAxesUserData )

% Reset the figure
anfigure('#Reset',hFig)

% Set the figure tag and size
TagString = [ get_param( sFigUserData.m.hAnimationBlock, 'Parent' ), ...
              '/', get_param( sFigUserData.m.hAnimationBlock, 'Name' ) ];
if ~exist( 'FigSize' ), FigSize = get( hFig, 'Position' ); end % 2.0 beta compatable
set( hFig, 'Tag', TagString, 'Position', FigSize )
    
% End local_LoadAnsimData

%###########################################################################
% local_SaveAnsimData
%
% Saves an ansim figure as an ansim data file.
%###########################################################################

function Success = local_SaveAnsimData(hFig, sFigUserData);

Success = logical(1);
% Extract important data
sMenu         = sFigUserData.h.menu;             % pull off menu structure
SimHandle     = sFigUserData.m.hAnimationBlock;
hAxes         = sFigUserData.h.axes.animation;
sAxesUserData = get( hAxes, 'UserData' );

FileName = get_param(SimHandle,'MaskHelp');
%% The following if statement accounts for a MAC specific
%% problem.  When get_param is used with a handle rather
%% than a name, a system call is made and a different 
%% answer is returned.
if ~isempty(FileName),
    Loc = findstr(FileName,'(Mask)');
    if ~isempty(Loc), FileName(1:Loc+6) = []; end
    if ~isempty(FileName),
      Loc = findstr(FileName,'No help available.');
      if ~isempty(Loc), FileName(1:Loc+18) = []; end
    end % if ~isempty
end % if ~isempty

if isempty(FileName),FileName = '*.mat';end
[FileName,PathName] = uiputfile(FileName,'Save Animation Data');

if FileName == 0,
    % Fini. Nothing left to do.
    Success = logical(0);
    return          
end

FigTitle = get( hFig, 'Name' );
TitleLoc = findstr( FigTitle, 'File: ' );
FigTitle = [FigTitle(1:TitleLoc+5) FileName];
set(hFig,'Name',FigTitle);
    
MenuGridHandle = sMenu.ViewGridOn;
OnGrid         = get( sMenu.ViewGridOn      ,'Checked' );
AxisOn         = get( sMenu.ViewAxisOn      ,'Checked' );
AxisBox        = get( sMenu.ViewBoxOn       ,'Checked' );
TickMark       = get( sMenu.ViewTickLabelsOn,'Checked' );
AutoScale      = get( sMenu.ViewAutoScale   ,'Checked' );   
HideButton     = get( sMenu.ViewSeeTools    ,'Checked' );
HideStatus     = get( sMenu.ViewSeeStatus   ,'Checked' ); 
ICString       = get( sMenu.SimSetIC        ,'UserData');
SquareAxis     = get( sMenu.ViewSquareAxis  ,'Checked' );

cAxesData      = get( hAxes, { 'XLim'
                                     'YLim'
                                     'XLabel'
                                     'YLabel'
                                     'Title'
                                   } ...
                    );
                                     
AxisLimit      = [ cAxesData{1:2} ];
XLabelText     = get( cAxesData{3}, 'String' );
YLabelText     = get( cAxesData{4}, 'String' );
TitleText      = get( cAxesData{5}, 'String' );

FigSize        = get( hFig, 'Position' );
% Store objects
cObjDataStructures = get( sAxesUserData.hAllObjects, {'UserData'} );

% Name storage variables
VarNames = ['''cObjDataStructures'',''OnGrid'',''AxisBox'',''TickMark'','  ...
          '''AutoScale'',''AxisLimit'',' ...
          '''HideButton'',''HideStatus'',''AxisOn'',''ICString'',' ...
          '''XLabelText'',''YLabelText'',''TitleText'',''SquareAxis'',',...
          '''FigSize'''];

% Save
eval(['save(''' PathName FileName ''',' VarNames ')'],'Success = 0;');
set_param(SimHandle,'MaskHelp',FileName);
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function outText = local_OnOff( inText )
% Simple function to change the text string 'on' to 'off' or
% change 'off' to 'on'. This happens very often in this file.

if inText(2) == 'n', % must be 'on'
    outText = 'off';
else,
    outText = 'on'; % must be 'off'
end


