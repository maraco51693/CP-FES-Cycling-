function [out1,out2]=anscale(hAxes, hObjects, CmdFlag )  %WorkingFig,ObjHandle,arg3,arg4,arg5,arg6)

%ANSCALE	Rescale.
%	[XPOS,YPOS]=ANSCALE(WORKINGFIG,OBJHANDLE,CURXPOS,CURYPOS,XLIM,YLIM)
%	This function will reset animation object positions based on the 
%	scaling option selected for the axes.  If auto scaling is set, object
%	positions are not changed but the axis limits are.
%
%	Other Calling Syntaxes:
%	  ANSCALE(WORKINGFIG,OBJHANDLE,XLIM,YLIM)
%	  ANSCALE(WORKINGFIG,OBJHANDLE,CURPOSITION,XLIM,YLIM)
%	  ANSCALE(WORKINGFIG,OBJHANDLE,CURXPOS,CURYPOS,XLIM,YLIM)
%	  [POSITION] =ANSCALE(WORKINGFIG,OBJHANDLE,CURPOSITION,XLIM,YLIM)
%	  [XPOS,YPOS]=ANSCALE(WORKINGFIG,OBJHANDLE,CURXPOS,CURYPOS,XLIM,YLIM)
%
%	POSITION,CURPOSITION are nx7 element matrices containing the x,y,z 
%	  position and 4 element extent of text objects.
%
%	XPOS,YPOS,CURXPOS,CURYPOS are nx1 vectors containg the position of 
%	  the objects.
%
%	WORKINGFIG is the handle for the figure the objects are placed on.
%
%	OBJHANDLE is a vector of object handles.  If ObjHandle is a NumPts by
%	2 matrix, the second column contains the number of data points 
%	associated with each handle.
%
%	XLIM,YLIM are the x and y limits of the axes.
%
%	See also ANDOT, ANRECT, ANTEXT.

%	Loren Dean  March, 1995.
%   4/02/97 KGK Convert to use of WorkingFig's UserData structure
%   5/05/97 KGK Trash old code--except for inward scaling
%   $Author$  $State$
%	Copyright (c) 1990-97 by The MathWorks, Inc.
% 	$Revision$  $Date$

% Flag to indicate when I've been forced to look up the figure's userdata
FigDataUnknown = 1;
%-------------------------------------------------------------------------------
% Check Command Flag
%-------------------------------------------------------------------------------
if nargin < 3,
    % No command given. Must look at AutoScale setting on menu
    % Get the figure's userdata
    sFigUserData = get( get( hAxes, 'Parent' ), 'UserData' );
    FigDataUnknown = 0;
    % Get the CmdFlag
    CmdFlag = strcmp( get( sFigUserData.h.menu.ViewAutoScale,'Checked' ),'on' );
end % if nargin < 3

if ~CmdFlag, return; end  % Rescaling not allowed
    
%-------------------------------------------------------------------------------
% Verify the existance of Object handles
%-------------------------------------------------------------------------------
if nargin < 2, % | isempty(hObjects),
    sAxesUserData = get( hAxes, 'UserData' );
    hObjects = sAxesUserData.hAllObjects;
end
if isempty( hObjects ), return; end  % Nothing to rescale to!
    
%-------------------------------------------------------------------------------
% Get position data for all objects
%-------------------------------------------------------------------------------
AllXData = [];
AllYData = [];

% Text Objects
hText = findobj( hObjects, 'flat', 'type', 'text' );

if ~isempty( hText ),
    % Get lower-left coords, plus width and height of all text objects
    % NOTE: They should be at the default Units setting of {Data}
    TextSizes = get( hText, 'Extent' );
    % Replace empty AllXData and AllYData matrices with actual data!
    % Calculate upper-right coords by adding width and height to X and Y.
    % Note: Needs to be column vector to work with hObjects, below
    AllXData = [ TextSizes(:,1); TextSizes(:,1) + TextSizes(:,3) ];
    AllYData = [ TextSizes(:,2); TextSizes(:,2) + TextSizes(:,4) ];
    
    % Eliminate text objects from the rest of the object list
    for idx = 1:length(hText), % this loop is way faster than SETDIFF
        hObjects( hObjects==hText(idx) ) = [];    % Zap text objects from list
    end

end

% Non-text objects
if ~isempty( hObjects ),
    % Get X and Y coords of all objects
    cObjCoords = get( hObjects, {'XData','YData'} );
    cX = cObjCoords(:,1);
    cY = cObjCoords(:,2);
    % Append to AllXData and AllYData matrices
    for idx = 1 : length(cX)
        AllXData = [ AllXData; cX{idx}(:) ];
        AllYData = [ AllYData; cY{idx}(:) ];
    end
end    

%-------------------------------------------------------------------------------
% Record the min and max position of all objects 
%-------------------------------------------------------------------------------
Xmin = min( AllXData );
Xmax = max( AllXData );
Ymin = min( AllYData );
Ymax = max( AllYData );

%-------------------------------------------------------------------------------
% Get axis limit data
%-------------------------------------------------------------------------------
cXYLims = get( hAxes, {'XLim', 'YLim'} );
XLim = cXYLims{1};
YLim = cXYLims{2};

% Calculate the total span of each axes
XDist = XLim(2) - XLim(1);
YDist = YLim(2) - YLim(1);

%-------------------------------------------------------------------------------
% Resize the axes -- outward expansion only
%-------------------------------------------------------------------------------
% Find the axes limits that will fit all objects
XLim = [ min( Xmin, XLim(1) ),  max( Xmax, XLim(2) ) ];
YLim = [ min( Ymin, YLim(1) ),  max( Ymax, YLim(2) ) ];

% Check for changes on lower and upper limits of each axes
XChange = ( (XLim - cXYLims{1}) ~= 0 );
YChange = ( (YLim - cXYLims{2}) ~= 0 );

% Make changes to the axes limits if necessary
if any( [ XChange, YChange ] ),
    % Add a little space to the sides that changed (+10%)
    XLim = XLim + XChange.*[-1 1]*XDist*0.10;
    YLim = YLim + YChange.*[-1 1]*YDist*0.10; 
    
    % Reset the axes limits
    set( hAxes, 'XLim', XLim, 'YLim', YLim )
end % if any

% Retrieve useful parameters from the UserData of the WorkingFig
if FigDataUnknown, sFigUserData = get( get(hAxes,'Parent'), 'UserData' ); end

AutoAxisHandle  = sFigUserData.h.menu.ViewAutoScale; 
WorkingAxes     = hAxes;
SimRoot         = sFigUserData.m.Name;

%%%%%%%%%%%%%%%%%%%%
%%% Inward Scaling

% Do not scale in if the Simulation is stopped
if strcmp(get_param(SimRoot,'SimulationStatus'),'stopped'), return, end

% Append the current min and max object positions to the list stored in 
% the AutoScale UserData (and bump the oldest data off the list)
AData = get( AutoAxisHandle, 'UserData' );
set( AutoAxisHandle, 'UserData', [] );
NewAData =[ AData(2:100,:); Xmin Xmax Ymin Ymax ];
set( AutoAxisHandle, 'UserData', NewAData );

% Recalculate the total span of each axes
XDist = XLim(2) - XLim(1);
YDist = YLim(2) - YLim(1);

% Calculate tolerance and adjustment factors for moving axis limits
XTolerance  = 0.25 * XDist; % 25 percent of axes
XAdjustment = 0.04 * XDist; % 20 percent adjustment if not in tolerance
YTolerance  = 0.25 * YDist; % 25 percent of axes
YAdjustment = 0.04 * YDist; % 20 percent adjustment if not in tolerance

%-------------------------------------------------------------------------------
% Resize the axes -- inward expansion only
%-------------------------------------------------------------------------------
% Get min and max position data from the past 100 samples
Xmin = min( NewAData(:,1) ); % MinX
Xmax = max( NewAData(:,2) ); % MaxX 
Ymin = min( NewAData(:,3) ); % MinY
Ymax = max( NewAData(:,4) ); % MaxY

% Set minimum scaling values
MinDiff = 0.00001;

% Make a single adjustment to any axes limit that is not within tolerance
% (i.e. are too far away from the closest object over the past 100 samples)
% Further adjustments will me made next iteration, if necessary
if ( XLim(2) - XLim(1) ) > MinDiff,
    if Xmin > ( XLim(1) + YTolerance ),
        % Lower X-Lim needs to be raised
        XLim(1) = XLim(1) + YAdjustment;
        set( hAxes, 'XLim', XLim )
    end
    
    if Xmax < ( XLim(2) - YTolerance ),
        % Upper X-Lim needs to be lowered
        XLim(2) = XLim(2) - YAdjustment;
        set( hAxes, 'XLim', XLim )
    end
end % if XDist > MinDiff

if ( YLim(2) - YLim(1) ) > MinDiff,
    while ( Ymin > (YLim(1) + YTolerance) ) & ( YLim(2) - YLim(1) ) > MinDiff,
        % Lower YLim needs to be raised
        YLim(1) = YLim(1) + YAdjustment;
        set( hAxes, 'YLim', YLim )
    end
    
    while ( Ymax < (YLim(2) - YTolerance) ) & ( YLim(2) - YLim(1) ) > MinDiff,
        % Upper YLim needs to be lowered
        YLim(2) = YLim(2) - YAdjustment;
        set( hAxes, 'YLim', YLim )
    end
end % if ( YLim(2) - YLim(1) ) > MinDiff,
