function xOut = antext( Action, hTarget, u )
%ANTEXT	Text creation and display function.
%	ANTEXT(ACTION,TARGET,U) is the creation and display 
%	function for the text object in the simulation animation block.
%
%	ACTION may be one of the following strings:
%	    '#Draw'  Draw text object.
% '#MouseClick'  Respond to a mouse click on the object
%	     '#New'  Create new object.
%	  '#Modify'  Modify object parameters (only sets up a dialog box).
% '#ChangeLook'  Change the visual appearance of the object based on dialog box.
%	'#UpdateIC'  Update internal data based on current position or given data.
%     '#Select'  Select the object (change color, add handles, whatever)
%   '#Deselect'  Deselect the object
%
%	TARGET is an HG handle. Usually it is the handle to the object, but it may
%   also be the axes or figure handle, depending on the requirements of ACTION
%
%	U is additional data that may be required by a given ACTION. For instance, U
%   is the vector of inputs to the animation block when #Draw is used.
%
%	See also ANLINE, ANPATCH, antext, ANRECT.

% "User-adjustable" properties in the data structure:
%   XPos        X Coordinate of object
%   YPos        Y Coordinate of object
%   Size        Font Size
%   Color       Color ([R G B])
%   Rotation    Rotation: (Degrees)
%   HAlign      Horizontal Alignment: (left,center,right)
%   VAlign      Vert. Align.: (top,cap,middle,baseline,bottom)
%   String      Text String
%
% Self or Non-adjusting properties of data structure:
%   Method      'antext'
%   Animated    flag to indicate that there is a DrawString
%   DrawString  EVALable text string that redraws the object based on u


%	Loren Dean March, 1995.
%   4/2/97  KGK converted to switch/case from if(strcmp)
%   4/2/97  KGK converted to use new UserData Structure
%   4/2/97  KGK check inputs up front
%   4/2/97  KGK hard code a str2mat call
%   4/7/97  KGK convert Tags, TextStrings, & Values to cell arrays for prpdlg
%   4/7/97  KGK make one prpdlg callback for all fields
%   5/9/97  KGK rewrites for Ansim2
%   $Author$  $State$
%	Copyright (c) 1984-97 by The MathWorks, Inc.
% 	$Revision$  $Date$
%
%###############################################################################
%       %
% BEGIN %  main
%       %
%###############################################################################
%-------------------------------------------------------------------------------
% Check input data -- we must know the target object!
%-------------------------------------------------------------------------------
if nargin == 1,  hTarget = gcbo;     end;
if nargin < 3 ,        u =   [];      end;

%-------------------------------------------------------------------------------
% Retrieve UserData structure (keeper of all knowledge--and handles!)
% Note: hTarget may be either the animation Figure or the animation Object.
% They both have userdata structures, though, and usage will depend on ACTION.
%-------------------------------------------------------------------------------
sTargetUserData = get( hTarget, 'UserData' ); 

%-------------------------------------------------------------------------------
% Perform the task specified by Action
%-------------------------------------------------------------------------------
switch Action,

%%%%%%%%%%%%
%%% Draw %%%
%%%%%%%%%%%%
case '#Draw',
    %---------------------------------------------------------------------------
    % This is it! Simulation time! Assume all data is correct and Move Fast!
    %---------------------------------------------------------------------------
    % Translation of input variables and their derivitives:
    %   hTarget         = Object
    %   sTargetUserData = Object UserData
    %
    % Valid call combinations (ACTION-specific variable names):
    %    antext( #Draw, hObj, u ) redraw object hObj using data vector u    
    %---------------------------------------------------------------------------
    
    % Check to see if this object is animated
    if sTargetUserData.Animated,
        % u-specific properties exist. Evaluate the draw string.
        % Display error message if there is a problem, but keep on going!
        % NOTE: DrawString assumes parameter variable is named: u
        % NOTE: DrawString assumes object handle is named: hTarget
        eval( ['set(hTarget' sTargetUserData.DrawString ')'], 'disp(lasterr);'); 
    end % if sTargetUserData.Animated

%%%%%%%%%%%%%%%%%%%
%%% Mouse Click %%%
%%%%%%%%%%%%%%%%%%%
case '#MouseClick',
    %---------------------------------------------------------------------------
    % Mouse click on object. Limited input expected, so we have to derive stuff
    %---------------------------------------------------------------------------
    % Valid call combinations (ACTION-specific variable names):
    %    antext #MouseClick   (hTarget assumed to be gcbo)
    %---------------------------------------------------------------------------

    % Pass off info to the Axes to deal with.
    anaxes( '#ButtonPress', get( hTarget, 'Parent' ), hTarget )
    
    
%%%%%%%%%%%
%%% New %%%
%%%%%%%%%%%
case '#New',
    %---------------------------------------------------------------------------
    % Make a new Object
    %---------------------------------------------------------------------------
    % Translation of input variables and their derivitives:
    %   hTarget         = Axes
    %   u               = [],
    %                     OR a [X,Y] position vector,
    %                     OR data structure describing new object properties
    %
    % Valid call combinations (ACTION-specific variable names):
    %  andot( #New , hAxes           ) add new generic obj to the axes
    %  andot( #New , hAxes, [X,Y]    ) add new generic obj at [X,Y] in the axes
    %  andot( #New , hAxes, sObjData ) add new obj using data in structre
    %---------------------------------------------------------------------------
    if nargin==1, error('Axes handle not provided. New object was not added.'); end
    
    % Create the new object
    hRect = local_MakeNewObject( hTarget, u );
    
    % Return output, if requested
    if nargout, xOut = hRect; end    

%%%%%%%%%%%%%%
%%% Modify %%%
%%%%%%%%%%%%%%
case '#Modify',
    %---------------------------------------------------------------------------
    % User wants to modify object properties. Build a property dialog box.
    %---------------------------------------------------------------------------
    % Translation of input variables and their derivitives:
    %   hTarget         = Object
    %   sTargetUserData = Object UserData
    %   u               = [], OR handle to animation figure
    %
    % Valid call combinations (ACTION-specific variable names):
    %  antext( #Modify,  hObj       ) modify the obj (hFig = grandparent of hObj)
    %  antext( #Modify,  hObj, hFig ) modify the obj (hFig for free)
    %---------------------------------------------------------------------------
    local_ModifyObject( hTarget, sTargetUserData, u );
    
%%%%%%%%%%%%%%%%%%
%%% ChangeLook %%%
%%%%%%%%%%%%%%%%%%
case '#ChangeLook',
    %---------------------------------------------------------------------------
    % The object is being modified, and we just want to see what the changes 
    % look like (purely cosmetic).
    %---------------------------------------------------------------------------
    % Translation of input variables and their derivitives:
    %   hTarget         = Object
    %   sTargetUserData = Object UserData
    %   u               = handle to uicontrol which has made change
    %
    % Valid call combinations (ACTION-specific variable names):
    %   antext( #UpdateIC, hObj, hUI ) update hObj based on uicontrol hUI
    %---------------------------------------------------------------------------
    ItWorked = local_CosmeticChange( hTarget, sTargetUserData, u );
    if nargout, xOut = ItWorked; end
    
%%%%%%%%%%%%%%
%%% Update %%%
%%%%%%%%%%%%%%
case '#UpdateIC',
    %---------------------------------------------------------------------------
    % The object has been modified, now we need to update it's internal
    % records and adjust the axes position, etc.
    %---------------------------------------------------------------------------
    % Translation of input variables and their derivitives:
    %   hTarget         = Object
    %   sTargetUserData = Object UserData
    %   u               = property/value structure w/fields named by property
    %                     OR []
    % Valid call combinations (ACTION-specific variable names):
    %   antext( #UpdateIC, hObj,          ) update hObj based on Position
    %   antext( #UpdateIC, hObj, sObjData ) update hObj based on sObjData
    %---------------------------------------------------------------------------
    local_UpdateObject( hTarget, sTargetUserData, u )
    
%%%%%%%%%%%%%%
%%% Select %%%
%%%%%%%%%%%%%%
case '#Select',
    % Use built-in
    set( hTarget, 'selected', 'on' )

%%%%%%%%%%%%%%%%
%%% Deselect %%%
%%%%%%%%%%%%%%%%
case '#Deselect',
    % Use built-in
    set( hTarget, 'selected', 'off' )

%%%%%%%%%%%
%%% END %%%
%%%%%%%%%%%

end % if strcmp action

%###############################################################################
%       %
%  END  %  main
%       %
%###############################################################################

%###############################################################################
%       %
% BEGIN %  local_MakeNewObject
%       %
%###############################################################################
function hObj = local_MakeNewObject( WorkingAxes, sObjectData )

% LOCAL_MAKENEWOBJECT creates a new object on the WorkingAxes of the
% WorkingFigure. Assume that someone else will modify the new object
% 
% local_MakeNewObject( FIGURE, FIGDATA, DATA ) adds new TEXT using DATA
% If DATA is a position vector, the elements must be:
%       [x,y]
% If DATA is a structure, the fields must be:
%       DATA.XPos        X Coordinate of object
%       DATA.YPos        Y Coordinate of object
%       DATA.Size        Font Size
%       DATA.Color       Color ([R G B])
%       DATA.Rotation    Rotation: (Degrees)
%       DATA.HAlign      Horizontal Alignment: (left,center,right)
%       DATA.VAlign      Vert. Align.: (top,cap,middle,baseline,bottom)
%       DATA.String      Text String
%
%
% Writen By: Kevin G Kohrt
% Writen On: April 1997

%-------------------------------------------------------------------------------
% Evaluate/Define the object's properties
%-------------------------------------------------------------------------------
if isstruct( sObjectData ),
    %--------------------------------------------------------------------
    % We've been given all of the object information in a data structure
    % (i.e. new object came from data file or property dialog box)
    %--------------------------------------------------------------------
    % Get the initial conditions for this figure
    u = angetic( get( WorkingAxes, 'Parent' ) );
    % evaluate all parameters based in IC
    eval( [     'XPos =' sObjectData.XPos ';'       , ...
                'YPos =' sObjectData.YPos ';'       , ...
              'MySize =' sObjectData.Size  ';'      , ...
             'MyColor =' sObjectData.Color ';'      , ...
            'Rotation =' sObjectData.Rotation ';'   , ...
              'HAlign =  sObjectData.HAlign ;'     , ...
              'VAlign =  sObjectData.VAlign ;'     , ...
              'String =  sObjectData.String ;'     ...
          ], ...
          'disp( lasterr ); return;' ...
        ); 
    % Force other required fields to be set    
    sObjectData.Method      = 'antext';
    sObjectData.Animated    = logical(0);
    sObjectData.DrawString  = '';
        
else,
    %--------------------------------------------------------------------
    % We must define our own default values
    % (i.e. new object from menus or toolbar)
    %--------------------------------------------------------------------
    
    % Get reasonable x & y positions based on how the user called for a new obj
    % Note: if from menu, sObjectData should be empty, else use last mouse click
    cXYLim = get( WorkingAxes, {'Xlim','Ylim','XTick','YTick'} );
    if isempty(sObjectData)
        % Put object in middle of axes
        XPos   = mean( cXYLim{1} );
        YPos   = mean( cXYLim{2} );
    else,
        % Button-click provided
        XPos = sObjectData(1);
        YPos = sObjectData(2);
    end

    % Round the position off to 1/10 of an axes gradation,
    % or, if ticks are turned off, use 1/20th of the axes limits)
    XPos = round2num( XPos, min( [ diff(cXYLim{3}), diff(cXYLim{1})/2 ] )/10 );
    YPos = round2num( YPos, min( [ diff(cXYLim{4}), diff(cXYLim{2})/2 ] )/10 );
    
    % arbitrarily define remaining properties
    MyColor  = [1 1 1] - get( WorkingAxes, 'Color' ); % High contrast    
    MySize   = 14;          % Default 14 point font
    Rotation = 0;           % 0 degrees of rotation (i.e. horizontal)
    HAlign   = 'left';      % options: [ {left} | center | right ]
    VAlign   = 'baseline';  % options: [ top | cap | {middle} | baseline | bottom ]
    String   = 'Text';      % It is just text, after all
    
    % Initialize a new UserData structure -- remember, store as strings!
    % (With the exception of SelectColor )
    sObjectData = struct( 'Animated'   , logical(0)                          , ...
                          'DrawString' , ''                                  , ...
                          'Method'     , 'antext'                            , ...
                          'XPos'       , num2str( XPos )                     , ...
                          'YPos'       , num2str( YPos )                     , ...
                          'Size'       , num2str( MySize )                     , ...
                          'Color'      , ['[ ' num2str( MyColor )    ' ]'] , ...
                          'Rotation'   , num2str( Rotation )                 , ...
                          'HAlign'     , HAlign                              , ...
                          'VAlign'     , VAlign                              , ...
                          'String'     , String                             ...
                     );        
                     
end; % if isstruct( sObjectData )

%-------------------------------------------------------------------------------
% Create the object
%-------------------------------------------------------------------------------                     
hObj = text( ...
             'Parent'               , WorkingAxes                           , ... 
             'HandleVisibility'     , 'on'                                  , ...
             'EraseMode'            , 'normal'                              , ...             
             'BusyAction'           , 'queue'                               , ...                
             'Interruptible'        , 'off'                                 , ...
             'UserData'             , sObjectData                           , ...
             'ButtonDownFcn'        , ...
                    'anaxes(''#ButtonPress'',get(gcbo,''Parent''),gcbo)'    , ...
             'Tag'                  , 'AnimText'                            , ...
             'Position'             , [ XPos YPos ]                         , ...
             'Color'                , MyColor                               , ...
             'Editing'              , 'off'                                 , ...
             'Interpreter'          , 'none'                                , ...
             'Rotation'             , Rotation                              , ...
             'HorizontalAlignment'  , HAlign                                , ...
             'VerticalAlignment'    , VAlign                                , ...
             'String'               , String                                ...
            );


%###############################################################################
%       %
%  END  %  local_MakeNewObject
%       %
%###############################################################################

%###############################################################################
%       %
% BEGIN %  local_ModifyObject
%       %
%###############################################################################
function local_ModifyObject( hObject, sObjUserData, WorkingFig )

% local_ModifyObject gathers a property list & calls up a property dialog box
%
% Writen By: Kevin G Kohrt
% Writen On: April 1997

%-------------------------------------------------------------------------------
% Define the HG Object Properties that are to be (re)defined on the object
%-------------------------------------------------------------------------------
cObjectProperties = { 'String'
                      'Size' 
                      'XPos'
                      'YPos'
                      'Rotation'
                      'HAlign' 
                      'VAlign' 
                      'Color'
                    };

%-------------------------------------------------------------------------------
% Retrieve current property expressions (strings) to put in Property Dialog Box
%-------------------------------------------------------------------------------
cPropertyValues = { sObjUserData.String
                    sObjUserData.Size
                    sObjUserData.XPos
                    sObjUserData.YPos
                    sObjUserData.Rotation
                    sObjUserData.HAlign
                    sObjUserData.VAlign
                    sObjUserData.Color
                  };
                  
%-------------------------------------------------------------------------------
% Record the field names so we get a proper structure back with #UpdateIC
%-------------------------------------------------------------------------------
cFieldNames = cObjectProperties; 

%-------------------------------------------------------------------------------
% Define prompts for ETBoxes in which user will enter new data 
% Note: order must match Object Properties, above
%-------------------------------------------------------------------------------
cTextStrings = { 'Text String'
                 'Font Size (points):'
                 'X Coordinate of text:'
			     'Y Coordinate of text:'
                 'Rotation (Degrees):'
                 'Horizontal Alignment (left,center,right)'
                 'Vertical Align. (top,cap,middle,baseline,bottom)'
			     'Color ([R,G,B]):'
              };
         
%-------------------------------------------------------------------------------
% Get the WorkingFigure, if not already provided, and its UserData 
%-------------------------------------------------------------------------------
if isempty( WorkingFig ) | ~ishandle( WorkingFig )
    % Figure is parent of axes is parent of object
    WorkingFig = get( get( hObject, 'Parent' ), 'Parent' );
end % if
sFigUserData = get( WorkingFig, 'UserData' );

%-------------------------------------------------------------------------------
% Assign an appropriate Tag and Title for the Property Dialog box  
%-------------------------------------------------------------------------------
FigTitle  = [ 'Text Object Properties: ', ...
            get_param( sFigUserData.m.hAnimationBlock, 'Name') ];
                    
%-------------------------------------------------------------------------------
% Create the Property Dialog box    
%-------------------------------------------------------------------------------
anprpdlg( '#Initialize'     , hObject           , WorkingFig , ...
          cTextStrings      , cObjectProperties , ...
          cPropertyValues   , cFieldNames       , ...
          'antext'          , '#UpdateIC'       , ...
          FigTitle                                ...
        );

%###############################################################################
%       %
%  END  %  local_ModifyObject
%       %
%###############################################################################

%###############################################################################
%       %
% BEGIN %  local_UpdateObject
%       %
%###############################################################################

function local_UpdateObject( hObject, sObjectUserData, s )

%-------------------------------------------------------------------------------
% The object has been modified, now we need to update it's internal records
%-------------------------------------------------------------------------------

%-------------------------------------------------------------------------------
% Check to make sure we have s
%-------------------------------------------------------------------------------
if isempty( s ),
    % Only the Object's position has been changed
    % Make our own u vector based on those facts
    
    % Get the old position
    OldXString = sObjectUserData.XPos;
    OldYString = sObjectUserData.YPos;
    
    % Get the new position 
    NewPos = get( hObject, 'Position' ); % // Object specific //
    NewX = NewPos(1);
    NewY = NewPos(2);
    
    % Get initial condtions (must be u vector)
    u = angetic( get( get( hObject, 'Parent' ), 'Parent' ) );

    % Calculate change in position of object
    DiffX = NewX - eval( OldXString );
    DiffY = NewY - eval( OldYString );
   
    % Create our own structure based on the old info // Object specific //
    s = struct( 'XPos'      , OldXString                , ...
                'YPos'      , OldYString                , ...
                'Size'      , sObjectUserData.Size      , ...
                'Color'     , sObjectUserData.Color     , ...
                'Rotation'  , sObjectUserData.Rotation  , ...
                'HAlign'    , sObjectUserData.HAlign    , ...
                'VAlign'    , sObjectUserData.VAlign    , ...
                'String'    , sObjectUserData.String    ...
              );              

    % Only change data if this object has actually moved
    if DiffX | DiffY,
        s.XPos = [ OldXString ' + ' num2str( DiffX ) ];
        s.YPos = [ OldYString ' + ' num2str( DiffY ) ];
    end % if DiffX | DiffY
    
end % if isempty

%-------------------------------------------------------------------------------
% Put together a drawing string to speed up the drawing process!
%-------------------------------------------------------------------------------
DrawStr = '';
% Check to see if each property is simulation-dependent by looking for 
% a "u()" in the property value expression. Add simulation-dependent
% property-value pair to the draw string.
if findstr('u(', [ s.XPos s.YPos ]), 
    DrawStr = [ DrawStr ',''Position'',[' s.XPos ' ' s.YPos ']' ]; 
end
if findstr('u(', s.Size),    DrawStr = [ DrawStr ',''FontSize'',' s.Size     ]; end
if findstr('u(', s.Color),   DrawStr = [ DrawStr ',''Color'','    s.Color    ]; end
if findstr('u(', s.Rotation),DrawStr = [ DrawStr ',''Rotation'',' s.Rotation ]; end

%-------------------------------------------------------------------------------
% Determine if the object is animated
%-------------------------------------------------------------------------------
sObjectUserData.Animated    = ~isempty( DrawStr ); % If empty, it's not animated

%-------------------------------------------------------------------------------
% Complete the DrawString if it is animated
%-------------------------------------------------------------------------------
if sObjectUserData.Animated,
    % Convert the object handle into an accurate string
    % (accurate to 999 plus 14 decimal places)
    chObjectHandle = num2str( hObject, 17 );
    % Assemble fully functional DrawString
    DrawStr = [ 'set(' chObjectHandle DrawStr ');' ];

end % if sObjectUserData.Animated

%-------------------------------------------------------------------------------
% Fill the Object's UserData structure with data passed in
% (except the hilite color, which is a fixed value based on current color)
%-------------------------------------------------------------------------------
sObjectUserData.DrawString  = DrawStr;
sObjectUserData.XPos        = s.XPos;
sObjectUserData.YPos        = s.YPos;
sObjectUserData.Size        = s.Size;
sObjectUserData.Rotation    = s.Rotation;
sObjectUserData.Color       = s.Color;
sObjectUserData.HAlign      = s.HAlign;
sObjectUserData.VAlign      = s.VAlign;
sObjectUserData.String      = s.String;

%-------------------------------------------------------------------------------
% Put the UserData back in the object
%-------------------------------------------------------------------------------
set( hObject, 'UserData', sObjectUserData )

%-------------------------------------------------------------------------------
% Force Rescale of the axes
%-------------------------------------------------------------------------------
anscale( get(hObject,'Parent'), hObject, 'Force' )

% %-------------------------------------------------------------------------------
% % Tell the figure to deselect this object (it's color has probably changed anyway)
% %-------------------------------------------------------------------------------
% anfigure( '#DeselectObj', get( get( hObject, 'Parent' ), 'Parent' ), hObject );


%###############################################################################
%       %
%  END  %  local_UpdateObject
%       %
%###############################################################################

%###############################################################################
%       %
% BEGIN %  local_CosmeticChange
%       %
%###############################################################################
function ItWorked = local_CosmeticChange( hObj, s, hETBox )
%---------------------------------------------------------------------------
% The object is being modified, and we just want to see what the changes 
% look like (purely cosmetic).
%---------------------------------------------------------------------------
% Translation of input variables and their derivitives:
%   hTarget         = Object
%   sTargetUserData = Object UserData
%   u               = handle to uicontrol which has made change
%
% Valid call combinations (ACTION-specific variable names):
%   antext( #UpdateIC, hObj, hUI ) update hObj based on uicontrol hUI
%---------------------------------------------------------------------------
% REMEMBER:
% cObjectProperties = { 'XPos'
%                       'YPos'
%                       'Rotation'
%                       'Color'
%                       'HAlign' 
%                       'VAlign' 
%                       'Size'
%                       'String'
%                     };
                    
% Get the initial conditions for the object's figure
u = angetic( get( get( hObj, 'Parent' ), 'Parent' ) );

% Find the Property and Value to be changed, as well as the change record
% Note: we have cleverly stored the exact object property in the UI's tag
% So that all we have to do is get it and eval it!
cPropValHist   = get( hETBox, {'Tag','String'} );
ObjProperty    = cPropValHist{1};
NewValue       = cPropValHist{2};

% We need some current data on the HG primitive (in case a cosmetic change has
% already been made to a two-part property)
Position = get( hObj, 'Position' );
XData    = Position(1);
YData    = Position(2);

% Assume all goes well (makes for cleaner EVAL statements below)         
ItWorked = 1; 

% Assign property and value strings
switch ObjProperty

case 'XPos',
    % New base X Coordinate Value (subtract old X-coord from XData and add new)
    EvalStr = [ 'set( hObj,''Position'', [' NewValue ' YData] );' ];

case 'YPos',
    % New base Y Coordinate Value (subtract old Y-coord from YData and add new)
    EvalStr = [ 'set( hObj,''Position'', [ XData ' NewValue ' ] );' ];
                 
case 'Rotation',
    EvalStr = [ 'set( hObj, ''Rotation'', ' NewValue  ');' ]; 

case 'Color',
    NewValue = colorfixer( NewValue );
    set( hETBox, 'String', NewValue );
    EvalStr = [ 'set( hObj, ''Color'', ' NewValue ' );' ];
    
case 'Size',
    EvalStr = [ 'set( hObj, ''FontSize'', [ ' NewValue ' ] );' ];

case 'HAlign',
    % Note: A string property must be eval'd as a variable, not as it's value
    EvalStr = 'set( hObj, ''HorizontalAlignment'', NewValue );'; 

case 'VAlign',
    % Note: A string property must be eval'd as a variable, not as it's value
    EvalStr = 'set( hObj, ''VerticalAlignment'', NewValue );'; 
   
case 'String',
    % Note: A string property must be eval'd as a variable, not as it's value
    EvalStr = 'set( hObj, ''String'', NewValue );'; 
   
otherwise
    ItWorked = 0;
    return
end

% Try to set the property to the value    
% (Should be a numeric property value)
eval( EvalStr, 'ItWorked = 0;' );


    
