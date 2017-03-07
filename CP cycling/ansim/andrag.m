function andrag( Action, WorkingFig, hAxes, hObject )

%ANDRAG	Drag objects around.
%	ANDRAG(ACTION) allows the user to drag animation objects around.
%
%	ACTION may be one of three strings:
%	  '#Motion'  Callback for mouse motion.
%	    '#Down'  Callback for button down.
%	      '#Up'  Callback for button up.
%
%	See also ANEDIT.

%	Loren Dean March,1995.
%   3/18/97 KGK comment out extra ResetHandle=findobj...(erased 4/2)
%   3/18/97 KGK convert if(strcmp) to switch/case
%   4/02/97 KGK Add WorkingFig to parameter list (kill a findobj)
%   4/02/97 KGK Check input params
%   4/02/97 KGK Convert to use of WorkingFig's UserData structure
%   4/17/97 KGK Update #Up Action to use Object's own #UpdateIC Action
%   4/28/97 KGK Major update (plus comments!) to comply with Ansim2
%   $Author$  $State$
%	Copyright (c) 1990-97 by The MathWorks, Inc.
% 	$Revision$  $Date$

% Verify input arguments
if nargin==1,   WorkingFig = gcbf;                      end

sUserData = get( WorkingFig, 'UserData' );

if nargin < 3,  hAxes   = sUserData.h.axes.animation;   end
if nargin < 4,  hObject = gco(WorkingFig);              end

% Retrieve useful parameters
ResetHandle = sUserData.h.menu.SimReset;
XLim        = get( hAxes, 'XLim' );
YLim        = get( hAxes, 'YLim' );

switch Action,

%%%%%%%%%%%%%%
%%% Motion %%%
%%%%%%%%%%%%%%
case '#Motion',
    % Chack the current point of the pointer on the axes
    eval('Pos=get(hAxes,''CurrentPoint'');Flag=0;','Flag=1;');
    % If we can't get a result, we've probably gone off the edge of
    % the axes. (??? Loren?)  End it now.
    if Flag,    andrag( '#Up', WorkingFig );  return;   end
  
    % Get the original and last recorded coordinates for the object
    PosInit = get(ResetHandle,'UserData');
    % Replace them with the new position and (again) the original (x,y only)
    set(ResetHandle,'UserData',[ Pos(1,1:2); PosInit(2,:) ] );
   
    % Calculate DeltaX and DeltaY with respect to the last recorded
    % position. But, make the edges of the axes the limits of motion.
    dx = min( XLim(2), max( Pos(1,1)    , XLim(1) ) ) - ...
         min( XLim(2), max( PosInit(1,1), XLim(1) ) );
           
    dy = min( YLim(2), max( Pos(1,2)    , YLim(1) ) ) - ...
         min( YLim(2), max( PosInit(1,2), YLim(1) ) );

    % Adjust the object's position by the changes calculated above
    chObjType = get( hObject, 'Type' );
    if strcmp( chObjType, 'text' ),
        PosNew = get( hObject, 'Position' ) + [dx dy 0];
        set( hObject, 'Position', PosNew);
    
    elseif strcmp( chObjType, 'axes' ),
        % Don't Click So FAST. (This could be a bug)
        return
        
    else,
        XNew = get( hObject, 'XData' ) + dx;
        YNew = get( hObject, 'YData' ) + dy;
        set( hObject, 'XData', XNew, 'YData', YNew);
        
    end % if strcmp type
  
%%%%%%%%%%%%
%%% Down %%%
%%%%%%%%%%%%
case '#Down',
    SelType = get( WorkingFig, 'SelectionType' );
    % Check mouse-click before we do anything
    if strcmp( SelType, 'open' ),
        % Ooops! Modify the object, don't drag it!
        sObjUserData = get( hObject, 'UserData' );
        anaxes('#ModifyObj', hAxes, hObject )
        
    elseif strcmp( SelType, 'extend' )
        % Shift-click means to add to selection list
        anfigure( '#SelectObj', WorkingFig, hObject )
        
    else,
        % Start dragging!       

        % Set the object and the axes for quick-draw!
        set( hObject, 'EraseMode', 'xor'   );
        set( hAxes  , 'DrawMode' , 'fast'  );
        
        % Get the current position of the pointer on the axes
        Pos = get(hAxes,'CurrentPoint');
        % Store two copies of these coordinates (x,y only) in a safe place
        % We will use one as a reference to the original location, and the
        % other will be updated as we move along (see #Motion)
        set( ResetHandle, 'UserData', Pos([1 1],1:2) ); 
        
        % Set up the figure to update us at key events (not keyboard keys!)
        set(WorkingFig            , ...
           'WindowButtonUpFcn'    ,'andrag #Up'    , ...
           'WindowButtonMotionFcn','andrag #Motion', ...
           'Pointer'              ,'fleur'           ...
           );
        
    end % if strcmp
 
%%%%%%%%%%
%%% Up %%%
%%%%%%%%%%
case '#Up',
    % Quick! Turn off the figure's WindowButton functionality!
    set( WorkingFig                      , ...
         'WindowButtonUp'       , ''      , ...
         'WindowButtonMotionFcn', ''      , ...
         'Pointer'              , 'arrow'   ...
        );
         
    % Slow down the axes and the object
    set( hAxes, 'DrawMode', 'normal' )
    if hObject == hAxes,   return;  end; % Don't click so Fast (could be a bug)
    set( hObject, 'EraseMode', 'normal' );
    
     
    PosInit = get( ResetHandle, 'UserData'      );
    Pos     = get( hAxes      , 'CurrentPoint'  );
    
    % Calculate DeltaX and DeltaY with respect to the original position.
    % (the edges of the axes are still the limits of motion)     
    dxTotal = min( XLim(2), max( Pos(1,1)    , XLim(1) ) ) - ...
              min( XLim(2), max( PosInit(2,1), XLim(1) ) );
              
    dyTotal = min( YLim(2), max( Pos(1,2)    , YLim(1) ) ) - ...
              min( YLim(2), max( PosInit(2,2), YLim(1) ) );

    % check for movement
    if dxTotal | dyTotal,  % any(Move),
        % Motion! Update the object as to it's new position in life!
        sObjUserData = get( hObject, 'UserData' );
        feval( sObjUserData.Method, '#UpdateIC', hObject )
        filetracker( 'NewChange', WorkingFig )
    else,
        % No motion! Just select the object
        
    end % if dxTotal | dyTotal

    % BTW: Deselect all others
    anfigure( '#DeselectObj', WorkingFig )
    % Add to selection list
    anfigure( '#SelectObj', WorkingFig, hObject )
  
end % switch Action
