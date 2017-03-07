function xOut = andot( Action, hTarget, u )
%ANDOT	Dot creation, modification, and display function.
%       ANDOT is specifically for the ANSIM Simulation Animation block.
%
%ANDOT( ACTION, TARGET, DATA ) apply ACTION to the TARGET using DATA.
%       
%	ACTION may be one of four strings:
%	    '#Draw'  Draw dot object (TARGET Dot handle and DATA vector, u, required)
%	     '#New'  Create new dot object (TARGET Figure and Dot DATA optional)
%	  '#Modify'  Modify dot object parameters. (TARGET Dot required)
%	  '#Update'  Update object paramater record stored in object's UserData.
%                (TARGET Dot required)
%
%   TARGET will be a single Figure handle, or one or more Dot Object handles,
%   depending on the ACTION specified.
%
%   DATA will be the Simulink input data vector, u; or a data structure 
%   containing the information for drawing the object. Required fields:
%       DATA.Xdata       - X-coordinate
%       DATA.Ydata       - Y-coordinate
%       DATA.Size        - MarkerSize
%       DATA.Color       - Color
%
%   Valid call combinations:
%    andot( #Draw  ,  hObj,        u ) redraw object hObj using data vector u
%    andot( #New                     ) add new generic obj to gcbf
%    andot( #New   ,  hAx            ) add new generic obj to hAx
%    andot( #New   ,  hAx , [X,Y]    ) add new generic obj to hAx at [X,Y]
%    andot( #New   ,  hAx , sObjData ) add new obj to hAx using sObjData
%    andot( #Modify,  hObj           ) modify the obj (hFig = grandparent of hObj)
%    andot( #Modify,  hObj,     hFig ) modify the obj (hFig for free)
%    andot( #UpdateIC,  hObj,          ) update UserData of hObj based on Position
%    andot( #UpdateIC,  hObj, sObjData ) update UserData of hObj based on sObjData
%    andot( #Select,    hObj           ) select hObj (change to select color)
%    andot( #Deselect,  hObj           ) deselect hObj (change to regular color)
%
%	See also ANLINE, ANPATCH, ANRECT, ANTEXT, ANOBJ.

%   Complete Dot UserData structure:
%       sObjUserData.Animated    - flag to indicate that there is a DrawString
%       sObjUserData.DrawString  - text to redraw the object based on u
%       sObjUserData.Method      - 'andot'
%       sObjUserData.Xdata       - X-coordinate
%       sObjUserData.Ydata       - Y-coordinate
%       sObjUserData.Size        - MarkerSize
%       sObjUserData.Color       - Color
%       sObjUserData.SelectColor - Color used when selected/hilited

%	Writen By: Loren Dean 
%   Writen On: March, 1995.
%   4/02/97 KGK converted to switch/case from if(strcmp)
%   4/02/97 KGK converted to use the Figure's new UserData Structure
%   4/02/97 KGK check inputs up front
%   4/02/97 KGK hard code a str2mat call
%   4/07/97 KGK convert TextStrings and Values to cell arrays for prpdlg
%   4/07/97 KGK make one prpdlg callback for all fields
%   4/09/97 KGK Total revamp of #New, #Update, and #Modify using new Data Structure
%   4/10/97 KGK Redo #Draw
%   4/11/97 KGK Redo function call systax and help text
%   4/11/97 KGK Finialize v5 optimization and begin debugging!
%   4/14/97 KGK Add #Select and #Deselect to Action list
%   4/14/97 KGK Change #Update to #UpdateIC
%   4/15/97 KGK Tax time! Ooops, properties must be stored as string expressions!
%   4/15/97 KGK Whoopie! Add AnimationFlag and DrawString to UserData structure!
%   4/17/97 KGK Update #UpdateIC to handle calls from andrag (i.e. no data)
%   4/25/97 KGK Update #Modify, #UpdateIC, and #Draw for Ansim2
%   5/02/97 KGK Clean up
%   $Author$  $State$
%	Copyright (c) 1990-97 by The MathWorks, Inc.
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
    %    andot( #Draw, hObj, u ) redraw object hObj using data vector u    
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
    %    andot #MouseClick   (hTarget assumed to be gcbo)
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
    %                     OR [X,Y] coordinates,
    %                     OR data structure describing new object properties
    %
    % Valid call combinations (ACTION-specific variable names):
    %  andot( #New , hAxes           ) add new generic obj to the axes
    %  andot( #New , hAxes, [X,Y]    ) add new generic obj at [X,Y] in the axes
    %  andot( #New , hAxes, sObjData ) add new obj using data in structre
    %---------------------------------------------------------------------------
    if nargin==1, error('Axes handle not provided. New object was not added.'); end
    
    % Create the new object
    hDot = local_MakeNewObject( hTarget, u );
    
    % Return output, if requested
    if nargout, xOut = hDot; end    
    
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
    %  andot( #Modify,  hObj       ) modify the obj (hFig = grandparent of hObj)
    %  andot( #Modify,  hObj, hFig ) modify the obj (hFig for free)
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
    %   andot( #UpdateIC, hObj, hUI ) update hObj based on uicontrol hUI
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
    %   andot( #UpdateIC, hObj,          ) update hObj based on Position
    %   andot( #UpdateIC, hObj, sObjData ) update hObj based on sObjData
    %---------------------------------------------------------------------------
    local_UpdateObject( hTarget, sTargetUserData, u )
    
%%%%%%%%%%%%%%
%%% Select %%%
%%%%%%%%%%%%%%
case '#Select',
    %---------------------------------------------------------------------------
    % The object has been selected! Woopie! Change to select color
    %---------------------------------------------------------------------------
    % Translation of input variables and their derivitives:
    %   hTarget         = Object
    %   sTargetUserData = Object UserData
    %
    % Valid call combinations (ACTION-specific variable names):
    %   andot( #Select, hObj ) select hObj (change to select color)
    %---------------------------------------------------------------------------
    %---------------------------------------------------------------------------    
    % Get the proper color from the object's UserData
    %---------------------------------------------------------------------------

    % SelectColor does not have to be evaluated, because it is automatically
    % Changed when the object is updated, so the exact value was known and 
    % (hopefully:-) stored in the data structure
    set( hTarget, 'Color', sTargetUserData.SelectColor )

%%%%%%%%%%%%%%%%
%%% Deselect %%%
%%%%%%%%%%%%%%%%
case '#Deselect',
    %---------------------------------------------------------------------------
    % The object(s) have been deselected! Change back to regular color
    %---------------------------------------------------------------------------
    % Translation of input variables and their derivitives:
    %   hTarget         = Object
    %   sTargetUserData = Object UserData
    %
    % Valid call combinations (ACTION-specific variable names):
    %    andot( #Deselect,  hObj ) deselect hObj (change to regular color)
    %---------------------------------------------------------------------------
    
    %---------------------------------------------------------------------------    
    % Get the initial conditions from figure, if not already available
    % (Figure is parent of axes is parent of object)
    %---------------------------------------------------------------------------
    if nargin ~= 3 | isempty(u),
        u = angetic( get( get( hTarget, 'Parent' ), 'Parent' ) );
    end
    
    %---------------------------------------------------------------------------    
    % Evaluate the object's UserData to get the proper color
    %---------------------------------------------------------------------------
    eval( ['set( hTarget, ''Color'',' sTargetUserData.Color ');'] );
    
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
function hDot = local_MakeNewObject( WorkingAxes, sObjectData )

% LOCAL_MAKENEWOBJECT creates a new object on the WorkingAxes
% Assume that someone else will modify the new object
% 
% local_MakeNewObject( AXES, DATA ) adds a new DOT using DATA
% If DATA is a vector, the elements must be:
%       [x,y]
% If DATA is a structure, the fields must be:
%       DATA.Xdata      x-coordinate of dot
%       DATA.Ydata      x-coordinate of dot
%       DATA.Size       MarkerSize of dot
%       DATA.Color      RGB Color of dot
%
% Writen By: Kevin G Kohrt
% Writen On: April 1997
% 5/6/97 KGK change ButtonDown function to call anaxes directly so this
%             could become a Private function
% 5/7/97 KGK change inputs to accept Axes rather than figure
%             (thereby reducing assumptions about figure's data structure)

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
    eval( [     'XPos =' sObjectData.Xdata ';'  , ...
                'YPos =' sObjectData.Ydata ';'  , ...
             'MySize =' sObjectData.Size  ';'  , ...
            'MyColor =' sObjectData.Color ';'  , ...
            'Hiliting = angetclr(''#Hilite'',' sObjectData.Color ');' ...
          ], ...
          'disp( lasterr ); return;' ...
        ); 
        
    % Make sure special fields are set properly
    sObjectData.Method      = 'andot';
    sObjectData.SelectColor = angetclr( '#Hilite', MyColor );
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
        XPos = sObjectData(1);
        YPos = sObjectData(2);
    end

    % Round the position off to 1/10 of an axes gradation,
    % or, if ticks are turned off, use 1/20th of the axes limits)
    XPos = round2num( XPos, min( [ diff(cXYLim{3}), diff(cXYLim{1})/2 ] )/10 );
    YPos = round2num( YPos, min( [ diff(cXYLim{4}), diff(cXYLim{2})/2 ] )/10 );

    % arbitrarily define remaining properties
    MySize      =  30;                                   % MarkerSize, in points
    MyColor     = [1 1 1] - get( WorkingAxes, 'Color' ); % High contrast    
    HiliteColor = angetclr( '#Hilite', MyColor );       % select color

    % Initialize a new UserData structure -- remember, store as strings!
    % (With the exception of SelectColor )
    sObjectData = struct( 'Animated'   , logical(0)                         , ...
                       'DrawString' , ''                                 , ...
                       'Method'     , 'andot'                            , ...
                       'Xdata'      , num2str( XPos )                    , ...
                       'Ydata'      , num2str( YPos )                    , ...
                       'Size'       , num2str( MySize )                  , ...
                       'Color'      , ['[ ' num2str( MyColor )    ' ]']  , ...
                       'SelectColor', angetclr( '#Hilite', MyColor )      ...
                     );        
                     
end; % if isstruct( sObjectData )

%-------------------------------------------------------------------------------
% Create the object
%-------------------------------------------------------------------------------                     
hDot = line( ...
             'Parent'        , WorkingAxes                  , ...   
             'LineStyle'     ,'none'                        , ...                 
             'Marker'        , '.'                          , ...
             'MarkerSize'    , MySize                       , ...
             'XData'         , XPos                         , ...
             'YData'         , YPos                         , ...
             'Color'         , MyColor                       , ...
             'ButtonDownFcn' , ...
                'anaxes(''#ButtonPress'',get(gcbo,''Parent''),gcbo)', ...
             'EraseMode'     , 'normal'                     , ...             
             'BusyAction'    , 'queue'                      , ...                
             'Interruptible' , 'off'                        , ...
             'UserData'      , sObjectData                     , ...
             'Tag'           , 'AnimDot'                      ...
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
cObjectProperties = { 'XData'
                      'YData'
                      'MarkerSize'
                      'Color'
                    };

%-------------------------------------------------------------------------------
% Retrieve current property expressions (strings) to put in Property Dialog Box
%-------------------------------------------------------------------------------
cPropertyValues = { sObjUserData.Xdata
                    sObjUserData.Ydata
                    sObjUserData.Size 
                    sObjUserData.Color
                  };
                  
%-------------------------------------------------------------------------------
% Record the field names so we get a proper structure back with #UpdateIC
%-------------------------------------------------------------------------------
cFieldNames = { 'Xdata'
                'Ydata'
                'Size' 
                'Color'
              };

%-------------------------------------------------------------------------------
% Define prompts for ETBoxes in which user will enter new data 
% Note: order must match Object Properties, above
%-------------------------------------------------------------------------------
cTextStrings = { 'X Coordinate:'
			     'Y Coordinate:'
			     'Marker Size:'
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
FigTitle  = [ 'Dot Object Properties: ', ...
            get_param( sFigUserData.m.hAnimationBlock, 'Name') ];
                    
%-------------------------------------------------------------------------------
% Create the Property Dialog box    
%-------------------------------------------------------------------------------
anprpdlg( '#Initialize'     , hObject           , WorkingFig , ...
          cTextStrings      , cObjectProperties , ...
          cPropertyValues   , cFieldNames       , ...
          'andot'           , '#UpdateIC'       , ...
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
    OldXString = sObjectUserData.Xdata;
    OldYString = sObjectUserData.Ydata;
    
    % Get the new position
    NewPos = get( hObject, {'XData', 'YData'} );
    
    % Get initial condtions (must be u vector)
    u = angetic( get( get( hObject, 'Parent' ), 'Parent' ) );

    % Calculate change in position
    DiffX = NewPos{1} - eval( OldXString );
    DiffY = NewPos{2} - eval( OldYString );
   
    % Create our own u structure based on the old info
    s = struct( 'Xdata'         , OldXString            , ...
                'Ydata'         , OldYString            , ...
                'Color'         , sObjectUserData.Color , ...
                'Size'          , sObjectUserData.Size    ...
              );              

    % Only change data if this object has actually moved
    if DiffX | DiffY,
        s.Xdata = [ OldXString ' + ' num2str( DiffX ) ];
        s.Ydata = [ OldYString ' + ' num2str( DiffY ) ];
    end % if DiffX | DiffY
    
end % if isempty

%-------------------------------------------------------------------------------
% Put together a drawing string to speed up the drawing process!
%-------------------------------------------------------------------------------
DrawStr = '';
% Check to see if each property is simulation-dependent by looking for 
% a "u()" in the property value expression. Add simulation-dependent
% property-value pair to the draw string.
if findstr('u(', s.Xdata), DrawStr = [ DrawStr ',''XData'','      s.Xdata ]; end
if findstr('u(', s.Ydata), DrawStr = [ DrawStr ',''YData'','      s.Ydata ]; end
if findstr('u(', s.Color), DrawStr = [ DrawStr ',''Color'','      s.Color ]; end
if findstr('u(', s.Size ), DrawStr = [ DrawStr ',''MarkerSize'',' s.Size  ]; end

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
sObjectUserData.Xdata       = s.Xdata;
sObjectUserData.Ydata       = s.Ydata;
sObjectUserData.Size        = s.Size;
sObjectUserData.Color       = s.Color;
sObjectUserData.SelectColor = angetclr( '#Hilite', get( hObject, 'Color' ) );

%-------------------------------------------------------------------------------
% Put the UserData back in the object
%-------------------------------------------------------------------------------
set( hObject, 'UserData', sObjectUserData )

%-------------------------------------------------------------------------------
% Force Rescale of the axes
%-------------------------------------------------------------------------------
anscale( get(hObject,'Parent'), hObject, 'Force' )

%-------------------------------------------------------------------------------
% Tell the figure to deselect this dot (it's color has probably changed anyway)
%-------------------------------------------------------------------------------
anfigure( '#DeselectObj', get( get( hObject, 'Parent' ), 'Parent' ), hObject );

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
function ItWorked = local_CosmeticChange( hObj, sObjUserData, hETBox )

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
%   andot( #UpdateIC, hObj, hUI ) update hObj based on uicontrol hUI
%---------------------------------------------------------------------------

% Get the initial conditions for the object's figure
u = angetic( get( get( hObj, 'Parent' ), 'Parent' ) );

% Find the Property and Value to be changed, as well as the change record
% Note: we have cleverly stored the exact object property in the UI's tag
% So that all we have to do is get it and eval it!
cPropValHist   = get( hETBox, {'Tag','String'} );
ObjProperty    = cPropValHist{1};
PropertyValue  = cPropValHist{2};

% Adjust the color string if necessary
if strcmp( ObjProperty, 'Color' )
    PropertyValue = colorfixer( PropertyValue );
    set( hETBox, 'String', PropertyValue );
end

% Assume all goes well (makes for cleaner EVAL statements below)         
ItWorked = 1; 

% Try to set the property to the value    
% (Should be a numeric property value)
eval( [ 'set( hObj, ObjProperty,' PropertyValue ');' ], ...
            'ItWorked = 0;' ...
    );
