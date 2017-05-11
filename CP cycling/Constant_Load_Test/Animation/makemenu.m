function handles = makemenu(fig, labels, calls, tags)
%MAKEMENU Create a set of menus.
%  MAKEMENU(FIG, LABELS, CALLS) creates a menu structure in
%  figure FIG according to the order in the string cell array
%  LABELS.  Cascaded menus are indicated by initial '>'
%  characters in the LABEL string.  CALLS is a string
%  cell array containing callbacks.  It should have the same
%  number of cells as LABELS.  A cell of LABELS that contains
%  any number of '-' characters after the '>' indicators
%  causes a separator line to be placed in the appropriate
%  place--but must still be matched by an empty CALLS cell.
%
%  MAKEMENU(FIG, LABELS, CALLS, TAGS) uses the TAGS string
%  cell array to assign the corresponding 'Tag' property of each
%  uimenu item.
%
%  LABELS, CALLS, and TAGS must have the same number of cells.
%  LABELS, CALLS, and TAGS may also be string matrices with the 
%  same number of rows (v4 style), but this will cause a speed hit
%  as the spaces are removed from the end of each row ('deblanked')
%
%  H = MAKEMENU( ... ) returns a vector containing the
%  handles of all uimenu objects created.
%
%  Example:
%  labels = {
%               '&File'
%               '>&New^n'
%               '>&Open'
%               '>>Open &document^d'
%               '>>Open &graph^g'
%               '>-------'
%               '>&Save^s'
%               '&Edit'
%               '&View'
%               '>&Axis^a'
%               '>&Selection region^r'
%           };
%  calls = {
%               ''
%               'disp(''New'')'
%               ''
%               'disp(''Open doc'')'
%               'disp(''Open graph'')'
%               ''
%               'disp(''Save'')'
%               ''
%               ''
%               'disp(''View axis'')'
%               'disp(''View selection region'')'
%          };
%  handles = makemenu(gcf, labels, calls);

%  Steven L. Eddins, 27 May 1994
%  KGK 4/14/97 - add cell arrays & more comments
%  Copyright (c) 1984-96 by The MathWorks, Inc.
%  $Revision: 1.11 $  $Date: 1996/10/27 15:23:22 $

%-------------------------------------------------------------------------------
% Check inputs, and convert them if they are not cell arrays
%-------------------------------------------------------------------------------
if nargin < 3, 
    error( 'FIG, LABELS and CALLS must all be provided. Use "help tag".' )
end % nargin < 3, 

if ~iscell( labels ),   labels = local_num2cell( labels );  end
if ~iscell( calls ),    calls  = local_num2cell( calls );   end

if nargin == 4,
    % Tags provided. Convert if necessary
    if ~iscell( tags ),     tags = local_num2cell( tags );    end
else,
    % No tags. Invent some with empty strings
    tags = cell( size(labels) );
    tags(:) = {''};    
end % if nargin == 4,

%-------------------------------------------------------------------------------
% Determine muber of menu items, and check for same number of calls and tags
%-------------------------------------------------------------------------------
num_objects = length( labels );

if num_objects ~= length( calls ),
    error('LABELS and CALLS must have the same number of rows.');
elseif num_objects ~= length( tags ),
    error('LABELS and TAGS must have the same number of rows.');
end % if num_objects

%-------------------------------------------------------------------------------
% Initialize starting parameters
%-------------------------------------------------------------------------------
current_level    = 0;   % Start with menus at level 0
remember_handles = fig; % Level 0 parent = figure
handles          = [];  % No menus yet means no handles
separatorFlag    = 0;   % Start with the seperator off

%-------------------------------------------------------------------------------
% Loop to process each menu item
%-------------------------------------------------------------------------------
for k = 1:num_objects
    
    %-----------------------------------------------------------------------------
    % Start with the label
    %-----------------------------------------------------------------------------
    labelStr = labels{k};
    
    % Determine which object to attach to by checking the level.
    loc = find( labelStr ~= '>' );
    if isempty(loc),
        error('Label strings must have at least one character that''s not a ">"');
    end
    % Record menu level (indexing from level 0)
    new_level = loc(1) - 1;
    % strip ">" characters from beginning of label
    labelStr = labelStr(loc(1):end);
    % Update list of parents to which we are adding on menus
    if (new_level > current_level)
        % We are about to add a submenu, add the handle to the previous menu to
        % the end of the remembered handles list
        remember_handles = [remember_handles handles(length(handles))];
    elseif (new_level < current_level)
        % We are done with a submenu set--drop the appropriate number of handles
        % from the remembered handles list
        N = length(remember_handles);
        remember_handles(N-(current_level-new_level)+1:N) = [];
    end
    current_level = new_level;
    
    if (labelStr(1) == '-')
        % Don't make a menu item-just mark the menu flag for the next menu item
        separatorFlag = 1;
    else
        % Determine whether to have a separator above this menu item based on
        % the state of the separator flag
        if (separatorFlag)
            % Flag set last time, so turn on seperator, and unset flag for next time
            separator = 'on';
            separatorFlag = 0;
        else
            % Flag is off. No seperator. Leave flag off.
            separator = 'off';
        end
        
        % Preprocess the label to extract accelerators and convert "\&" to "&&".
        [labelStr, acc] = menulabel(labelStr);
        if (isempty(labelStr))
            error('Empty label field.');
        end
        
        % Note:  much of the overhead in this function is spent in calls
        % to deblank.  So we're going to trade off speed for figure memory
        % overhead and not deblank the callback string.
        h = uimenu( remember_handles(end), ...
                    'Label'              , labelStr  , ...
                    'Accelerator'        , acc       , ...
                    'Callback'           , calls{k}  , ...
                    'Separator'          , separator ,...
                    'Tag'                , tags{k}    );
        
        % Add the new menu to the end of the handles list
        handles = [handles ; h];
    end

end

%################################################################################
function cStrings = local_num2cell( StringMtx )

% Get parameters
NumCells = size(StringMtx,1);

% Initialize a single-column cell array to have the same number of cells as
% there are rows in the string matrix
cStrings = cell( NumCells, 1 );

% Loop to fill in each cell with a deblanked version of the corresponding row
% in the string matrix
for idx = 1 : NumCells,
    % Assign string in this row of the string matrix to temporary memory location
    labelStr = StringMtx( idx, : );
    % The next two lines are a fast replacement for calling deblank.
    loc = find( labelStr ~= ' ' & labelStr~=0);
    labelStr(max(loc)+1:length(labelStr)) = [];
    % Assign the deblanked string to the cell
    cStrings{idx} = labelStr;
end % for
