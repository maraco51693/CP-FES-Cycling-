function IC = angetic( WorkingFig, sFigUserData )

%ANGETIC Get input vector initial conditions.
%	IC = SETIC(WORKINGFIG) get the input vector initial conditions.
%	IC = SETIC(WORKINGFIG,WORKINGFIG_USERDATA) get initial conditions faster.
%
%	IC is the vector of initial conditions.
%
%	WORKINGFIG is the handle for the figure that the objects are 
%	drawn on.

%	Loren Dean March, 1995.
%   4/2/97  KGK converted to use figure's new UserData Structure
%   4/23/97 KGK add sFigUserData as an optional second argument
%   4/23/97 KGK ASKS: Why are we evalling the SimSetIC menu's UserData?
%   $Author$  $State$
%	Copyright (c) 1990-97 by The MathWorks, Inc.
% 	$Revision$  $Date$
%

% Get the UserData from the figure, if not already given
if nargin == 1,
    sFigUserData = get( WorkingFig, 'UserData' ); 
end

% Initialize IC to a vector at least 100 elements long
IC = zeros(1,100);

% Retrieve the IC vector string stored in the Set IC Menu's UserData
% and convert it to an actual value
ICTemp = eval( get( sFigUserData.h.menu.SimSetIC, 'UserData' ), 'zeros(1,100)' );


% fill in the first n elements with values
IC( 1:length(ICTemp) ) = ICTemp; 
