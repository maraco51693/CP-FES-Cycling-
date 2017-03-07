function [SelectColor,DeselectColor]=angetclr(Action,hObject,Color)

%ANGETCLR Return select and deselect colors for animations.
%	[SELECTCOLOR,DESELECTCOLOR]=ANGETCLR(ACTION,CURRENTPT,COLOR) returns 
%	the object select and deselect colors in [R G B] format.
%
%	SELECTCOLOR is the mx3 element color matrix for selected objects.
%
%	DESELECTCOLOR is the mx3 element color matrix for deselected objects.
%
%	SELECTCOLOR and DESELECTCOLOR are only used for '#New' and '#Modify'.
%
%	ACTION is one of 4 text strings:
%	     '#New'  Stores the objects color in the MenuEditModify UserData.
%	'#GetColor'  Gets the colors from the MenuEditModify UserData.
%	  '#Modify'  Modifies the colors in the MenuEditModify UserData.
%	  '#Delete'  Deletes colors from the MenuEditModify UserData.
%
%	CURRENTPT is the vector of handles for the objects on the figure.
%
%	COLOR is the current color of the object to be added.  It is only used
%	    with the '#New' and '#Modify' actions.

%	Loren Dean  March, 1995.
%   4/07/97 KGK Convert to switch/case
%   4/07/97 KGK Modify to make use of WorkingFig's UserData structre
%   4/10/97 KGK Change CurrentPt to hObject, and NumPts to NumObjects
%   4/14/97 KGK Took steps to ferret out last v4 calls to this fcn!!!

%   $Author$  $State$
%	Copyright (c) 1990-97 by The MathWorks, Inc.
% 	$Revision$  $Date$

% Check input args
% Determine initial parameters
if nargin == 2,
    % Special case
    if ( size(hObject,2) ~= 3 ) ishandle( hObject ) 
        % Given handle, but not color. Get color from object
        Color = get( hObject, 'Color' ); 
    else
        % Given color(s), not handle. Reassign variables
        Color = hObject;
    end % ishandle( hObject ) 
    
elseif nargin == 1,
    % Bad call
    disp('Bad call to angetclr')
    return
    
else,
    % Normal case
    NumObjects  = length( hObject );
    WorkingAxes = get( hObject(1), 'Parent'   );
    WorkingFig  = get( WorkingAxes , 'Parent'   );
    sUserData   = get( WorkingFig  , 'UserData' ); % Structure of object handles 
    hModifyMenu = sUserData.h.menu.EditModify;
    ColorData   = get( hModifyMenu, 'UserData' );
    
end % if nargin < 3
        


% Perform action based on input parameter Action
switch Action,
%%%%%%%%%%%%%%
%%% Hilite %%%
%%%%%%%%%%%%%%  
case '#Hilite',
    
    % Force Select Color to be a kind of bright-purple,
    % except when starting color is a similar shade
    if all( (round( Color*10 ) - 1) == [.7 0 .7] ),
        SelectColor = [ 0.00  0.69  0.69 ];
    else,
        SelectColor = [ 0.69  0.00  0.69 ];
    end

  
end % switch Action





