function ansim_sfcn_writer( hFig )

% Open a file to write to
[FID, FileName] = local_GetOutputFile;
if (FID == -1), return, end

fprintf('Saving...')
% Write the basic sfcn
local_WriteBaseFcn(FID, FileName)

% Add function to create each object
local_WriteAddObjectsFcn(FID, hFig);

% Close the file
fclose(FID);

fprintf('Done.\n')
%###############################################################################
%       %
%  END  %  main
%       %
%###############################################################################

%###############################################################################
%       %
% BEGIN %  local_WriteAddObjectsFcn
%       %
%###############################################################################
function local_WriteAddObjectsFcn(FID, hFig);


fprintf( FID, '%s\n', ' ');
fprintf( FID, '%s\n', '%  Add all objects to current axes and returns their handles in vector h');
fprintf( FID, '%s\n', ' ');

% Get handles to all Ansim objects in the animation axes
sFigUserData = get( hFig, 'UserData' ); % Figure user data
sAxesUserData = get( sFigUserData.h.axes.animation, 'UserData' ); % Axes user data
hObjects = sAxesUserData.hAllObjects;  % Array of handles to objects

% Get UserData for all objects (UserData contains Animation flag and DrawString)
cObjUserData = get( hObjects, {'UserData'} );

% Initialize the big DrawString
BigDrawString = [];

% Loop through each object to record it's key info
for idx = 1 : length( cObjUserData ),
    
    % Get the animation drawing string (if any)
    if cObjUserData{idx}.Animated,
        % Get the draw string and make sure it has a ";" on the end!
        NewString = deblank( cObjUserData{idx}.DrawString );
        if NewString(end) ~= ';', NewString = [ NewString ';']; end
        % Locate the commas (pinpoints the string-i-fied object handle)
        commaLoc = findstr(NewString,',');
        % Strip everything up to the first comma (i.e. 'set(handle' ) and replace with set(h(i)     
        if (~isempty(commaLoc))
            
            BigDrawString = [ BigDrawString, 'set(h(' num2str(idx) ')', NewString( commaLoc(1)  : end ) ];
        end
    end % if cObjUserData{idx}.Animated

    % Write the object to the file
    fprintf( FID, 'h(%d) = ', idx );
    switch get( hObjects(idx), 'Type' ),
        case 'line',
            local_WriteLineObject( FID, hObjects(idx)  )
        case 'patch',
    		local_WritePatchObject( FID, hObjects(idx) )
        case 'text',
    		local_WriteTextObject( FID, hObjects(idx) )
         
        case otherwise,
    
    end        

end % for idx = 1 : length( cObjUserData )

local_WriteDrawString( FID, BigDrawString )

%###############################################################################
%       %
%  END  %  local_WriteAddObjectsFcn
%       %
%###############################################################################
%###############################################################################
%       %
% BEGIN %  local_GetOutputFile
%       %
%###############################################################################

function [fileID, FileName] = local_GetOutputFile

% Get a file name
[FileName,PathName] = uiputfile('Animation.m','Save as Sfcn');

% Check name
if FileName == 0,
    % No name. Create error condition.
    fileID = -1; 
else
    % Attempt to open file for writing
    fileID = fopen( [PathName, FileName], 'w' );
end

%###############################################################################
%       %
%  END  %  local_GetOutputFile
%       %
%###############################################################################

%###############################################################################
%       %
% BEGIN %  local_WriteLineObject
%       %
%###############################################################################

function local_WriteLineObject( FID, hObj )

% Write the line creation script
fprintf( FID,  'line( ...\n' );
fprintf( FID,  '        ''LineStyle''     ,''%s'', ...\n', get(hObj,'LineStyle') );
fprintf( FID,  '        ''LineWidth''     , %d, ...\n', get(hObj,'LineWidth') );
fprintf( FID,  '        ''MarkerSize''    , %d, ...\n', get(hObj,'MarkerSize') );
fprintf( FID,  '        ''Marker''        , ''%s'', ...\n', get(hObj,'Marker') );
fprintf( FID,  '        ''Color''         , [%d %d %d], ...\n', get(hObj,'Color') );
fprintf( FID, ['        ''XData''         , [' num2str(get(hObj,'XData')) '], ...  \n' ] );
fprintf( FID, ['        ''YData''         , [' num2str(get(hObj,'YData')) '], ...  \n' ] );
fprintf( FID,  '        ''BusyAction''    , ''queue'', ...\n' );
fprintf( FID,  '        ''Interruptible'' , ''off'', ...\n' );
fprintf( FID,  '        ''Tag''           , ''AnimLine'' ...\n' );
fprintf( FID,  '     );\n\n' );

%###############################################################################
%       %
%  END  %  local_WriteLineObject
%       %
%###############################################################################

%###############################################################################
%       %
% BEGIN %  local_WritePatchObject
%       %
%###############################################################################

function local_WritePatchObject( FID, hObj )

% Write the patch creation script
fprintf( FID,  'patch( ...\n' );
fprintf( FID, ['        ''XData''         , [' num2str(get(hObj,'XData')') '], ...  \n' ] );
fprintf( FID, ['        ''YData''         , [' num2str(get(hObj,'YData')') '], ...  \n' ] );
fprintf( FID,  '        ''FaceColor''     , [%d %d %d], ...\n', get(hObj,'FaceColor') );
fprintf( FID,  '        ''BusyAction''    , ''queue'', ...\n' );
fprintf( FID,  '        ''Interruptible'' , ''off'', ...\n' );
fprintf( FID,  '        ''Tag''           , ''AnimPatch'' ...\n' );
fprintf( FID,  '     );\n\n' );

%###############################################################################
%       %
%  END  %  local_WritePatchObject
%       %
%###############################################################################

%###############################################################################
%       %
% BEGIN %  local_WriteTextObject
%       %
%###############################################################################

function local_WriteTextObject( FID, hObj )

% Write the text creation script
fprintf( FID, 'text( ...\n' );
fprintf( FID, '        ''String''         , ''%s'', ...\n', get(hObj,'String') );
fprintf( FID, '        ''Position''       , [%d %d %d], ...\n', get(hObj,'Position') );
fprintf( FID, '        ''Color''          , [%d %d %d], ...\n', get(hObj,'Color') );
fprintf( FID, '        ''FontSize''       , %d, ...\n', get(hObj,'FontSize') );
fprintf( FID, '        ''Rotation''       , %d, ...\n', get(hObj,'Rotation') );
fprintf( FID, '        ''HorizontalAlign'', ''%s'', ...\n', get(hObj,'HorizontalAlign') );
fprintf( FID, '        ''VerticalAlign''  , ''%s'', ...\n', get(hObj,'VerticalAlign') );
fprintf( FID, '        ''BusyAction''     , ''queue'', ...\n' );
fprintf( FID, '        ''Interruptible''  , ''off'', ...\n' );
fprintf( FID, '        ''Tag''            , ''AnimText'' ...\n' );
fprintf( FID, '     );\n\n' );

%###############################################################################
%       %
%  END  %  local_WriteTextObject
%       %
%###############################################################################

%###############################################################################
%       %
% BEGIN %  local_WriteBaseFcn
%       %
%###############################################################################

function local_WriteBaseFcn( FID, FileName )

% Read in old ansim file
AFID = fopen('ansim.m');
words = fread(AFID);
fclose( AFID );

% mark writing point
currentPoint = 1;

% Rip ".m" off FileName if present
if length(FileName) > 2,
    if strcmp(FileName(end-1:end), '.m'),
        FileName = FileName(1:end-2);
    end
end

% Change the function name to match the file name
idx = kfindstr( words, ' ansim' );
fwrite( FID, words( currentPoint:idx(1) ) );
fprintf( FID, FileName);
currentPoint = idx(1) + 6;

% Eliminate an unhelpful assignment
idx = kfindstr( words, 'ScaleCmd =' );
fwrite( FID, words( currentPoint:idx(1)+9 ) );
fprintf( FID, ' 0; %%');
currentPoint = idx(1) + 10;

% Clip end (boring revision history)
idx = kfindstr( words, '% Add draw code here' );
fwrite( FID, words(currentPoint:idx-1) );



%###############################################################################
%       %
%  END  %  local_WriteBaseFcn
%       %
%###############################################################################

%###############################################################################
%       %
% BEGIN %  local_WriteDrawString
%       %
%###############################################################################
function local_WriteDrawString( FID, BigDrawString )

%Start assignment
fprintf( FID, 'DrawString = ''' );

% Locate quote marks
quoteMarks = findstr( BigDrawString, '''');

% Loop to add second  quote mark to each quote mark
currentPoint = 1;
for idx = quoteMarks
    % Print up to next quote, then add a second quot mark
    fprintf( FID, [ BigDrawString(currentPoint:idx) '''']);
    % increase the index by one
    currentPoint = idx + 1;
end

% end assignment
fprintf( FID, [ BigDrawString(currentPoint:end) ''';' ] );
