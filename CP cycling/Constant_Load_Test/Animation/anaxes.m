function xOut = anaxes( Action, hTarget, xData )

% ACTIONS: 
%   #Draw           - Redraws all animated objects on axes
%   #ButtonPress    - Performs actions based on Mode
%   #ChangeMode     - sets mode of axes
%   #SelectObj      - Select a given object
%   #DelectObj      - Deselect selected objects
%   #DeleteObj      - Delete selected objects
%   #PlaceObj       - Put a new object in the axes
%   #ModifyObj      - Modify selected objects via dialog box
%   #Reset          - Resets all objects in axes to Initial Conditions

% Ã       anaxes( #ChangeMode, hAx  , {'AddObjPrep', Method} )
% Ã      anaxes( #ChangeMode, hAx  , 'RunFast'    )
% Ã      anaxes( #ChangeMode, hAx  , 'Run'        )
% Ã      anaxes( #ChangeMode, hAx  , 'Stop'       )
% Ã      anaxes( #ChangeMode, hAx  , 'Normal'     )  * Internal
% Ã      anaxes( #ChangeMode, hAx  , 'Modify'     )  * Internal
% Ã      anaxes( #PlaceObj  , hAx  , Method       )   
% Ã      anaxes( #ModifyObj , hAx  , hObj         )   
% Ã  n = anaxes( #SelectObj , hObj )
% Ã  n = anaxes( #Delect    , hAx  )
% Ã  n = anaxes( #Delete    , hAx  )
% Ã      anaxes( #Draw      , hAx  , u            )
% Ã      anaxes( #Reset     , hAx  )
% Ã      anaxes( #New       , hFig )
%		 anaxes( #UpdateDrawString, hAx )

%   Written By: Kevin Kohrt
%   Written On: April 1997
%   4/28/97 KGK Eliminate local_SetObjectProperties and local_SetMode
%   5/16/97 KGK add BigDrawString
%   $Author$  $State$
%	Copyright (c) 1990-97 by The MathWorks, Inc.
% 	$Revision$  $Date$
%
%###############################################################################

switch Action,

case '#Draw',
    %---------------------------------------------------------------------------
    % Redraw all objects ( hTarget = Handle to Axes; xData = u vector )
    %---------------------------------------------------------------------------
    % Get Axes UserData
    sAxesUserData = get( hTarget, 'UserData' );

    % Check to see if the axes has anything to animate (Only act if necessary)
    if sAxesUserData.IsAnimated,
    
		% DrawStrings assume input variable = u, not xData
		u = xData;
		
		% Evaluate the axes' DrawString (should contain all objects' DrawStrings)     
		eval( sAxesUserData.DrawString, 'disp(lasterr)' );
	
	    % rescale the axes
	   	anscale( hTarget, sAxesUserData.hAllObjects );
	    
% 		sAxesUserData.MovieIndex  = sAxesUserData.MovieIndex + 1;
% 		sAxesUserData.MovieFrames(:,sAxesUserData.MovieIndex) = getframe(hTarget);
% 		
% 		set( hTarget, 'UserData', sAxesUserData );
% 		if mod(sAxesUserData.MovieIndex,10) == 0, sAxesUserData.MovieIndex, end
	end
 
case '#ChangeMode',
    %---------------------------------------------------------------------------
    % Alter the axes mode
    %---------------------------------------------------------------------------
    local_ChangeMode( hTarget, xData );
    
    
case '#ButtonPress',
    %---------------------------------------------------------------------------
    % Find out what the mouse is doing and what we should do about it (no input)
    %---------------------------------------------------------------------------
    % Get the handle to the figure and axes, 
    if nargin == 1;
        % Mouse click in axes. hTarget = axes; no xData;
        [ hAxes, hFig ] = gcbo;
    else,
        % More detailed case of Mouse click in axes; or object sending us a msg!
        hAxes = hTarget;
        hFig  = get( hAxes, 'parent' );
    end
    
    % Supply object handle if none passed in (default empty matrix)
    if nargin ==3; 
		hObj = xData; 
	else, 
		hObj = []; 
	end
    
    % analyze the button press
    local_AxesButtonDown( hFig, hAxes, hObj )

case '#UpdateDrawString',
    %---------------------------------------------------------------------------
    % Rebuild the DrawString
    %---------------------------------------------------------------------------
    local_ResetDrawString( hTarget );        
 
case '#New',
    %---------------------------------------------------------------------------
    % Add an Animation Axes ( hTarget = Working Figure )
    %---------------------------------------------------------------------------
    hWorkingAxes = local_NewAxes( hTarget );
 
    % Return handle to the axes if requested
    if nargout,     xOut = hWorkingAxes;   end   
    
    
case '#Reset',
    %---------------------------------------------------------------------------
    % Move all objects back to their initial conditions
    %---------------------------------------------------------------------------
    % Translation of input variables and their derivitives:
    %   hTarget = handle to axes being reset
    %   xData   = [] OR data structure
    %
    % Valid call combinations (ACTION-specific variable names):
    %    anaxes #Reset                           -- not yet implemented 
    %    anaxes('#Reset', hAxes                ) -- reset hAxes
    %    anaxes('#Reset', hAxes, sAxesUserData ) -- reset hAxes (little faster) 
    %---------------------------------------------------------------------------
    
    % Assume we have the Axes handle (nargin >= 2 )
    %---------------------------------------------------------------------------
    % Get the axes' UserData if it was not passed in
    %---------------------------------------------------------------------------
    if nargin ~= 3,     xData = get( hTarget, 'UserData' );       end
    
    %---------------------------------------------------------------------------
    % Get the IC vector from the figure
    % Redraw all objects based on this IC vector
    %---------------------------------------------------------------------------
    anaxes( '#Draw', hTarget, angetic( get( hTarget, 'Parent') ) );

    %---------------------------------------------------------------------------
    % Change the axes mode back to normal
    %---------------------------------------------------------------------------
    anaxes( '#ChangeMode', hTarget, 'Normal' );

    
case '#PlaceObj',
    %---------------------------------------------------------------------------
    % A new object has been added to the axes
    %   hTarget = Handle to Axes
    %   xData   = handle to object 
    %---------------------------------------------------------------------------
    % Get Axes UserData ( Object Handle list is stored in UserData )
    sAxesUserData = get( hTarget, 'UserData' );
    hAllObjects   = sAxesUserData.hAllObjects;
    
    % Check out new object before adding to list
    if ~ishandle( xData ),  
        % Somebody passed in bad data
        disp('Warning: Attempt to add non-HG object handle failed in anaxes()')
        return
    elseif ~isempty( hAllObjects ) & any( hAllObjects == xData ),
        % Valid handle has been passed in, but Object was already in list!
        disp('Warning: Attempt to add duplicate object handle in anaxes()')
        return
    end % if

    % Add new object to list of all objects.
    sAxesUserData.hAllObjects = [ hAllObjects, xData ];
    set( hTarget, 'UserData', sAxesUserData );
    
%     % Select Object
%     anfigure( '#SelectObj', get( hTarget, 'Parent' ), xData )
%     
%     % Modify Object (Mode will change here)
%     anaxes( '#ModifyObj', hTarget, xData )

    % change mode back to normal
    anaxes( '#ChangeMode', hTarget, 'Normal' )
    
    % Enable the Save Menus
    filetracker( 'NewChange', get( hTarget, 'Parent' ) )

case '#ModifyObj',
    %---------------------------------------------------------------------------
    % Modifiy selected objects
    %   hTarget = Handle to Axes
    %   xData   = handle to object 
    %---------------------------------------------------------------------------
    % See if we have been give an object handle, or if we must divine it
    if nargin < 3 | ~ishandle( xData ),
        % Get the Axes' UserData
        sAxesUserData = get( hTarget, 'UserData' );
        % Let xData be the selected object(s)
        xData = sAxesUserData.hSelectedObjects;
        % return if too few or too many
        if length( xData ) ~= 1, return; end
    end % if

    % Change axes mode
    anaxes( '#ChangeMode', hTarget, 'Modify' )
    
    % Tell object to modify itself
    sObjUserData = get( xData, 'UserData' );
    feval( sObjUserData.Method, '#Modify', xData )
    
    % Enable the Save Menus
    filetracker( 'NewChange', get( hTarget, 'Parent' ) )
    
case '#SelectObj'
    %---------------------------------------------------------------------------
    % An object has been selected. 
    % Add it to the selected list and inform the figure
    %   hTarget = Handle to Axes; 
    %   xData   = Handle to Object
    %---------------------------------------------------------------------------
    sAxesUserData = get( hTarget, 'UserData' ); % List stored in UserData
    
    % Check out new object before adding to list 
    % /*** This should be trivial. It should never happen! ***/
    if ~ishandle( xData ),  
        % Somebody passed in bad data
        disp('Warning: Attempt to add non-HG object handle failed in anaxes()')
        xData = [];
    elseif ~isempty( sAxesUserData.hSelectedObjects ) ...
           & any( sAxesUserData.hSelectedObjects == xData ),
        % Valid handle has been passed in, but Object was already in list!
        % (Can happen if double-clicking on a selected onject
        xData = [];
    end % if

    % Tell the object (if there still is one) to select itself
    if ~isempty( xData ),
        sObjUserData = get( xData, 'UserData' );
        feval( sObjUserData.Method, '#Select', xData, sObjUserData )
    end % if
    
    % Add object to Selected Object list.
    sAxesUserData.hSelectedObjects = [ sAxesUserData.hSelectedObjects, xData ];
    set( hTarget, 'UserData', sAxesUserData );
    
    % Count Objects, and send results to the Figure
    if nargout,        xOut = length( sAxesUserData.hSelectedObjects );     end

    
case '#DeselectObj'
    %---------------------------------------------------------------------------
    % All objects are to be deselected. 
    % Remove it from the selected list and inform the figure
    %   hTarget = Handle to Axes; 
    %   xData   = [] OR Handle to Object(s)
    %---------------------------------------------------------------------------
    sAxesUserData = get( hTarget, 'UserData' ); % Handles stored in UserData

    % Get handles to objects to deselect (return if none)
    %---------------------------------------------------------------------------
    if nargin < 3 | isempty( xData )
        % No handles passed in. Get list from axes userdata.
        hSelectedObjects = sAxesUserData.hSelectedObjects;  
    else
        % Use object handles passed in
        hSelectedObjects = xData;
    end
    if isempty( hSelectedObjects ), 
        % May be generic check before starting simulation
        if nargout, xOut = length( sAxesUserData.hSelectedObjects );    end
        return;
    end
    
    %---------------------------------------------------------------------------
    % Get UserData from all objects (contains Object Method)
    %---------------------------------------------------------------------------
    cObjUserData = get( hSelectedObjects, {'UserData'} );
    
    %---------------------------------------------------------------------------
    % Loop to remove all object from Selected Object list.
    % Note: as each object is deselected, it will report back here
    % (This seems inefficient. If the axes is the only one deselecting
    %  objects, then we should handle the selection list right here in batch
    %  mode, rather than have each object call this function when deselecting)
    %  [Ah! but a newly created object calls #Deselect on itself after updating
    %   (after the property dialog figure closes)]
    %---------------------------------------------------------------------------
    for idx = 1 : length( cObjUserData ),
        % Evaluate the object's method
        feval( cObjUserData{idx}.Method, '#Deselect', hSelectedObjects(idx) )
    end % for
           
    %---------------------------------------------------------------------------
    % Remove all objects from Selected Object list.
    %---------------------------------------------------------------------------
    sAxesUserData.hSelectedObjects = [];
    set( hTarget, 'UserData', sAxesUserData );
    
    %---------------------------------------------------------------------------
    % Change axes mode back to normal (if not already there)
    %---------------------------------------------------------------------------
    anaxes( '#ChangeMode', hTarget, 'Normal' )
    
    %---------------------------------------------------------------------------
    % Count Objects, and send results to the Figure
    %---------------------------------------------------------------------------
    if nargout,        xOut = length( sAxesUserData.hSelectedObjects );     end

case '#DeleteObj'
    %---------------------------------------------------------------------------
    % All objects are to be deselected. 
    % Remove it from the selected list and inform the figure
    %   hTarget = Handle to Axes; 
    %   xData   = Handle to Object
    %---------------------------------------------------------------------------
    % Get handles to all selected objects (return if none)
    %---------------------------------------------------------------------------
    sAxesUserData    = get( hTarget, 'UserData' ); % Handles stored in UserData
    hSelectedObjects = sAxesUserData.hSelectedObjects;  
    hAllObjects      = sAxesUserData.hAllObjects;
    if isempty( hSelectedObjects ), 
      if strncmp(computer,'MA',2), 
         speak('You must select objects before you can delete them','zarvox');
      end
      if nargout,   xOut = 0;  end
      return; 
    else
        if strncmp(computer,'MA',2), 
          speak('Deleting selected objects','zarvox');
        end
    end
     
    % Delete the objects
    delete( hSelectedObjects );
    
    % locate all selected objects in the full object list
    TotalObj = length( hSelectedObjects );
    % Initialize the index matrix 
    % (we know that every selected object must appear in AllObj somewhere)
    AllObjIndex = zeros( 1, TotalObj );
    % Loop to find the index in allObj for each selected obj
    for idx = 1 : TotalObj,
        AllObjIndex(idx) = find( hSelectedObjects(idx) == hAllObjects );
    end

    % Remove deleted objects from Object lists and store lists back in axes.
    sAxesUserData.hSelectedObjects            = [];
    sAxesUserData.hAllObjects( AllObjIndex  ) = [];
    set( hTarget, 'UserData', sAxesUserData );

    % Count Objects, and send results to the Figure
    if nargout,   xOut = length( sAxesUserData.hAllObjects );  end
    
end % switch Action

%###############################################################################
%       %
%  END  %  main
%       %
%###############################################################################

%###############################################################################
%       %
% BEGIN %  local_ChangeMode
%       %
%###############################################################################


function local_ChangeMode( hAx, Mode )
%       anaxes( #ChangeMode, hAx  , {'AddObjPrep', Method} )
%       anaxes( #ChangeMode, hAx  , 'Playback'     )
%       anaxes( #ChangeMode, hAx  , 'Run'        )
%       anaxes( #ChangeMode, hAx  , 'RunFast'    )
%       anaxes( #ChangeMode, hAx  , 'Stop'       )
%       anaxes( #ChangeMode, hAx  , 'Normal'     )  * Internal
%       anaxes( #ChangeMode, hAx  , 'Modify'     )  * Internal

% Special case where hAx was not available to calling function
% if isempty( hAx ),
%     % Get the axes handle from the figure, which we assume had something to 
%     % do with the callback
%     sFigUserData = get( gcf, 'UserData' );
%     if isfield( sFigUserData, 'AnimationFig' ),
%         % oops. Got the property-dialog fig
%         sFigUserData = get( sFigUserData.AnimationFig, 'UserData' );
%     end
%     hAx = sFigUserData.h.axes.animation;
% end

% Get useful Parameters
sAxesUserData = get( hAx, 'UserData' );
hFig          = get( hAx, 'Parent'   );

% Assign a default pointer
NewPointer = 'arrow';
    
% Split the Mode data for add obj case
if iscell( Mode ),
    Method = Mode{2};
    Mode   = Mode{1};
end % if

% Switch off of the Mode
switch Mode,

case 'Playback',
    
case 'Run',
    %---------------------------------------------------------------------------
    % Perform required Run actions
    %---------------------------------------------------------------------------    
    % Get handles to all objects
    hObjects = sAxesUserData.hAllObjects;  

    % (Re)set objects to xor erasemode
    set( hObjects, 'EraseMode' , 'xor'   )
    
    % Check to see if we are already in Run or Runfast mode
    % If we are, we're done here. Return now.
    if strncmp( sAxesUserData.Mode, 'Run', 3 ),  return; end
        
    %---------------------------------------------------------------------------
    % Prepare figure window appearance for animation (first time only)
    %---------------------------------------------------------------------------    
    % Deselect all objects (if there are any to deselect)
    % Note: must tell the figure to do it so menus are updated correctly
    if ~isempty( sAxesUserData.hSelectedObjects ),
        anfigure( '#DeselectObj', hFig );
    end

    % Speed up draw mode of the axes
    set( hAx, 'drawmode', 'Fast' )

    % See if the toolbar needs to be hidden
    sFigUserData = get( hFig, 'UserData' );
    if strcmp( get( sFigUserData.h.menu.ViewSeeTools, 'checked' ), 'on' )
        % Toolbar is currently visible, so hide it
        anoption( '#ShowTools', hFig )
    else,
        % Toolbar is hidden already, so we must play tricks to keep it hidden.
        % Change the ViewSeeTools Checked property so that we can
        % just use '#ShowTools' when the simulation stops and
        % it will do the right thing (i.e. keep it hidden).
        set( sFigUserData.h.menu.ViewSeeTools, 'checked', 'on' )
    end

%   % Set up for recording a movie
%   sAxesUserData.MovieFrames = moviein(100,hAx);
%   sAxesUserData.MovieIndex  = 0;

%     % If we are in playback mode, just perpetuate the myth
%     if strcmp( sAxesUserData.Mode, 'Playback' )
%         Mode = 'Playback';
%     end
    
    %---------------------------------------------------------------------------
    % Prepare axes UserData for animation
    %---------------------------------------------------------------------------
	local_ResetDrawString( hAx, sAxesUserData );
%     % Assume no animated objects
%     BigDrawString = ''; 
% 
%     % Get UserData from all objects (contains Animation flag and DrawString)
%     cObjUserData = get( hObjects, {'UserData'} );
%     
%     % Asemble a huge draw string for all animated objects in the axes
%     % By looping through each to collect drawstrings from all animated objects
%     for idx = 1 : length( cObjUserData ),
%         % Add only objects that are animated
%         if cObjUserData{idx}.Animated,
%             % Get the draw string and make sure it has a ";" on the end!
%             NewString = deblank( cObjUserData{idx}.DrawString );
%             if NewString(end) ~= ';', NewString = [ NewString ';']; end
%             % Add NewString to the BigDrawString
%             BigDrawString = [ BigDrawString, NewString ];
%         end % if cObjUserData{idx}.Animated,
%     end % for idx = 1 : length( cObjUserData )
% 
%     % Set the axes' IsAnimated flag
%     sAxesUserData.IsAnimated = ~isempty( BigDrawString );
%     sAxesUserData.DrawString = BigDrawString;
%     set( hAx, 'UserData', sAxesUserData )
  
case 'RunFast',
    %---------------------------------------------------------------------------
    % Draw objects with traces 
    %---------------------------------------------------------------------------
    set( sAxesUserData.hAllObjects, 'EraseMode', 'none' )
    
%     % If we are in playback mode, just perpetuate the myth
%     if strcmp( sAxesUserData.Mode, 'Playback' )
%         Mode = 'Playback';
%     end

case 'Stop',
    %---------------------------------------------------------------------------
    % End animation;  Set objects to normal erasemode
    %---------------------------------------------------------------------------
%    set( sAxesUserData.hAllObjects, 'EraseMode', 'normal' )
    
    % Show/rehide the toolbar (see #Run mode for tricks that have been played)
    anoption( '#ShowTools', hFig )
    
case 'Normal',
    %---------------------------------------------------------------------------
    % Everything back to the way it was 
    %---------------------------------------------------------------------------
    % Set objects to normal erasemode, Delete the modemethod of the axes
    set( sAxesUserData.hAllObjects, 'EraseMode', 'normal' )
    sAxesUserData.ModeMethod = '';       
    set( hAx, 'drawmode', 'Normal' )
    
case 'AddObjPrep',
    %---------------------------------------------------------------------------
    % Get ready to add a new object
    %---------------------------------------------------------------------------
    % Check to see if we are allowed to add stuff yet
    if strcmp( sAxesUserData.Mode, 'Stop' ),
        % We need to reset before adding objects
        anfigure( '#Reset', hFig );
    elseif ~strcmp( sAxesUserData.Mode, 'Normal' ),
%         % No changes allowed 
%         % Simulate a button press on the first button, the selection arrow
%         btnpress( hFig, 'ObjectButtons', 1 );
%         
%         % See if we are waiting for the reset button to be pressed
%         if strcmp( sAxesUserData.Mode, 'Stop' )
%             % Yup. Pretend like this was an axes button press in order to 
%             % give the user a fair shot at resetting things
%             anaxes( '#ButtonPress', hAx )
%         end
        
        % Can't continue. Try again.
        return 
   
    end % if

    % Made it through! Store object method in userData and Change the pointer
    sAxesUserData.ModeMethod = Method;   
    NewPointer               = 'fullcross';
        
case 'Modify',
    % Change the pointer
    NewPointer = 'watch';
    
end % Switch

%-------------------------------------------------------------------------------
% Assign the new mode to the data structure
%-------------------------------------------------------------------------------
sAxesUserData.Mode = Mode;

%-------------------------------------------------------------------------------
% Reset the axes' UserData
%-------------------------------------------------------------------------------
set( hAx, 'UserData', sAxesUserData);

%-------------------------------------------------------------------------------
% Reset the Figure pointer
%-------------------------------------------------------------------------------
set( hFig, 'Pointer', NewPointer )
    

%###############################################################################
%       %
%  END  %  local_ChangeMode
%       %
%###############################################################################

%###############################################################################
%       %
% BEGIN %  local_NewAxes
%       %
%###############################################################################
function hAxes = local_NewAxes( hFig )

%------------------------------------------------------------------------------
% Define Units of measure      *********
%------------------------------------------------------------------------------
AxisUnits = 'Points';

%------------------------------------------------------------------------------
% Get dimentions of the working figure
%------------------------------------------------------------------------------
TempUnits = get( hFig, 'Units' );       set( hFig, 'Units', AxisUnits );
FigPos    = get( hFig, 'Position' );    set( hFig, 'Units', TempUnits );

%------------------------------------------------------------------------------
% Assign Axes Dimensions here  *********
%------------------------------------------------------------------------------
AxisX     = 90;
AxisY     = 110;
AxisW     = FigPos(3) - AxisX - 20;
AxisH     = FigPos(4) - AxisY - 25;

%------------------------------------------------------------------------------
% Define the UserData Structure
%------------------------------------------------------------------------------
sAxesUserData = struct( 'hAllObjects'       , []            , ...
                        'hSelectedObjects'  , []            , ...
                        'Mode'              , 'Normal'      , ...
                        'ModeMethod'        , ''            , ...
                        'IsAnimated'        , logical(0)    , ...
                        'DrawString'        , ''            ...
                      );

    % likely modes
    %   normal  (deselect all)
    %   addobj  (add new object at mouse-click)
    %   running (no changes allowed)
    %   stopped (needs to be reset)
    %
    % ModeMethod - A passed in argument to be applied when in addobj mode
    %              examples: 'andot', 'anline', 'antext', ...
    
%------------------------------------------------------------------------------
% Add axes object
%------------------------------------------------------------------------------
hAxes = axes(                                              ...
              'Parent'       , hFig                      , ...
              'Tag'          , 'hWorkingAxes'            , ...
              'BusyAction'   , 'queue'                   , ...                
              'Interruptible', 'off'                     , ...
              'ButtonDownFcn', 'anaxes #ButtonPress'     , ...
              'Units'        , AxisUnits                 , ...
              'Position'     , [AxisX AxisY AxisW AxisH] , ...
              'Units'        , 'normalized'              , ...          
              'DrawMode'     , 'normal'                  , ...
              'Visible'      , 'on'                      , ...
              'Layer'        , 'top'                     , ...
              'Box'          , 'on'                      , ...
              'GridLineStyle', ':'                       , ...
              'XLim'         , [0 100]                   , ...
              'YLim'         , [0 100]                   , ...
              'XGrid'        , 'off'                     , ...
              'YGrid'        , 'off'                     , ...
              'Color'        , [0 0 0]                   , ...
              'XColor'       , [1 1 1]                   , ...
              'YColor'       , [1 1 1]                   , ...
              'UserData'     , sAxesUserData               ...
              );
% Record current position, plus alt pos for when tool & status bars are hidden
% NOTE: units are Normalized now
%AxisPos = [ get( hAxes, 'Position' ); 0.1, 0.1, 0.85, 0.8 ];

%###############################################################################
%       %
%  END  %  local_NewAxes
%       %
%###############################################################################

%###############################################################################
%       %
% BEGIN %  local_AxesButtonDown
%       %
%###############################################################################
function local_AxesButtonDown( hFig, hAxes, hObject )

% hObject will be empty unless called from an object's buttondownfcn
ObjectClick = ~isempty( hObject );

% Check for double-click
if strcmp( get( hFig, 'SelectionType' ), 'open' ),
    if ObjectClick,
        % Double-click on object ==> modify object 
        anaxes( '#ModifyObj', hAxes, hObject )
    end
    % Return after launching object selection OR if any double-click on the axes
    return;
end

% Get the UserData for the axes
sAxesUserData = get( hAxes, 'UserData' );

% Check axes mode
switch sAxesUserData.Mode,
    
case 'Normal',
    % Simulation is not an issue
    if ObjectClick,    
        % May be dragging object! Move fast!
        andrag( '#Down',  hFig, hAxes, hObject )
    else,
        % A stray mouse-click in the axes will deselect all
        anfigure( '#DeselectObj', hFig );
    end
    
case 'AddObjPrep',
    % We were previously instructed to wait for an object to be added. 
    % This is it! Clicks on axes or on objects are the same.
    
    % Check for existing M-file to handle the addition of an object
    if exist( sAxesUserData.ModeMethod ) ~= 2,
        % Should give a warning message and reset the toolbar,
        % but we will error out for now
        error('sAxesUserData.ModeMethod is not set correctly.')
    end
    % Add the object !!! This is tricky! ModeMethod must be set correctly !!!!
    %   High bug probability at this point
    MousePos = get( hAxes, 'CurrentPoint' );
    
    hObj = feval( sAxesUserData.ModeMethod, '#New', hAxes, MousePos(1,1:2) );
          
    % Log the new object
%     anfigure( '#PlaceObj', hFig, hObj );
      anaxes( '#PlaceObj', hAxes, hObj );

case {'Run','RunFast'},
    % if the simulation is running, nothing can be done
    % Clicks on axes or on objects are the same.
    anfigure('#Message', hFig, ...
     'You must stop the Simulation before altering axes abjects.' )
    
case 'Stop',
%     % Axes need to be reset before changes can be made
%     % Ask user if they want to reset the axes
%     Answer = questdlg(['The object(s) must be reset to their initial '
%                        'positions before any modifications to the    '
%                        'animation figure window can take place.      '
%                        '                                             '
%                        'Do you wish to reset the object(s) now?      '], ...
%                        'Yes','No');
%                        
%     % If user wants to reset the axes--Go for it. 
%     % Mode will be changed to 'normal' in the #Reset call      
%     % If an object click, they will have to click again!
%     if strcmp( Answer, 'Yes' ), anfigure( '#Reset', hFig ); end

    % Just go ahead and reset the axes
     anfigure( '#Reset', hFig );

end % Switch

%###############################################################################
%       %
%  END  %  local_AxesButtonDown
%       %
%###############################################################################
%###############################################################################
%       %
% BEGIN %  local_ResetDrawString
%       %
%###############################################################################

function local_ResetDrawString( hAx, sAxesUserData )

% hAx required
% sAxesUserData is optional (provide for speed)

% check inputs
if nargin == 1,
	% pull user data from the axes
	sAxesUserData = get( hAx, 'UserData' ); 
end

%---------------------------------------------------------------------------
% Prepare axes UserData for animation
%---------------------------------------------------------------------------
% Assume no animated objects
BigDrawString = ''; 

% Get UserData from all objects (contains Animation flag and DrawString)
cObjUserData = get( sAxesUserData.hAllObjects, {'UserData'} );

% Asemble a huge draw string for all animated objects in the axes
% By looping through each to collect drawstrings from all animated objects
for idx = 1 : length( cObjUserData ),
    % Add only objects that are animated
    if cObjUserData{idx}.Animated,
        % Get the draw string and make sure it has a ";" on the end!
        NewString = deblank( cObjUserData{idx}.DrawString );
        if NewString(end) ~= ';', NewString = [ NewString ';']; end
        % Add NewString to the BigDrawString
        BigDrawString = [ BigDrawString, NewString ];
    end % if cObjUserData{idx}.Animated,
end % for idx = 1 : length( cObjUserData )

% Set the axes' properties
sAxesUserData.IsAnimated = ~isempty( BigDrawString );
sAxesUserData.DrawString = BigDrawString;
set( hAx, 'UserData', sAxesUserData )
