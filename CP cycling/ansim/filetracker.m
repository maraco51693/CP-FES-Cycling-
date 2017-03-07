function AnswerFlag = filetracker( CommentText, hFig )

%FILETRACKER - Keeps track of whether savable changes have been made
% AnswerFalg = FILETRACKER( Comment, Figure ) performs record-keeping
% or data retrieval based on the Comment text and the Figure handle
% (which should be for an Ansim figure window)
%
% Comments:
%   'SomethingToSave' - Indicates that a savable animation exists
%                       Action: The SaveAs menus will be enabled
%                       Output: 1 (if you ask for it)
%   'NewChange'       - Indicates that a configuration change has been made
%                       Action: All Save menus will be enabled
%                       Output: 1 (if you ask for it)
%   'NothingToSave'   - Indicates that there are no objetcs to save.
%                       Action: All Save menus will be disabled
%                       Output: 1 (if you ask for it)
%   'AnythingToSave?' - Indicates that you have no clue, but would like
%                       to find out before, say, closing the figure window.
%                       Action: none
%                       Output: 1 for 'yes', 0 for 'no, no savable changes'
%
% See also: ANFIGURE

%   Original: Kevin G Kohrt, 5/13/97
%   Current:  $Author$  $State$
%	Copyright (c) 1990-97 by The MathWorks, Inc.
% 	$Revision$  $Date$
%
%------------------------------------------------------------------------------


%------------------------------------------------------------------------------
% Check input
%------------------------------------------------------------------------------
if nargin == 0,
    if nargout, AnswerFlag = 0; end
elseif nargin == 1,
    hFig = gcbf;
end % if nargin

%------------------------------------------------------------------------------
% Get figure's userdata
%------------------------------------------------------------------------------
sFigUserData = get( hFig, 'UserData' );

%------------------------------------------------------------------------------
% Switch on CommentText
%------------------------------------------------------------------------------

switch CommentText

case 'SomethingToSave',
    % A savable animation exists, so enable the Save As menu 
    set( sFigUserData.h.menu.FileSaveAs, 'Enable', 'on' );
    if nargout, AnswerFlag = 1; end
    
case 'NewChange',
    % Can save configuration, too, so enable all Save menus
    set( [ sFigUserData.h.menu.FileSave     , ...
           sFigUserData.h.menu.FileSaveAs ] , 'Enable', 'on' );
    if nargout, AnswerFlag = 1; end
    
case 'NothingToSave',
    % No objects / no animation to save. Disable the save menu
    set( [ sFigUserData.h.menu.FileSave     , ...
           sFigUserData.h.menu.FileSaveAs ] , 'Enable', 'off' );
    if nargout, AnswerFlag = 1; end

case 'TempDisable',
    % Animation is running, so the menus need to be turned off temporarily
    % Get current enable State //* Note: handle order is critical *//
    cellCurentState = get( [ sFigUserData.h.menu.FileSave     , ...
                             sFigUserData.h.menu.FileSaveAs ] , {'Enable'} );
    % store state in the SaveAs Menu userdata                         
    set( sFigUserData.h.menu.FileSaveAs, 'UserData', cellCurentState );
    
    % Turn them all off
    filetracker( 'NothingToSave', hFig );

case 'Revert',
    % Animation is done running, so the menus need to be turned on again
    % Get previous enable State
    cOldState = get( sFigUserData.h.menu.FileSaveAs, 'UserData');
    
    % Revert the menus //* Note: handle order is critical *//
    set( sFigUserData.h.menu.FileSave  , 'Enable', cOldState{1} );
    set( sFigUserData.h.menu.FileSaveAs, 'Enable', cOldState{2} );
    
case 'AnythingToSave?',
    % Question, is there anything to save?
 %   if nargout,
        % Calling program really expects an answer!
        Enabled = get( sFigUserData.h.menu.FileSave, 'Enable' );
        AnswerFlag =  strcmp( Enabled, 'on' );
  %  end % if nargout

otherwise
    % Typo, probably. Issue warning
    disp( ['Argument: "' CommentText '" not valid for FILETRACKER.'])
    
end % switch CommentText
