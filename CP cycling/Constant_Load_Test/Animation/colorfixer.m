function NewColor = colorfixer( ColorString )
 
% Convert basic text strings into RGB triplet strings
switch lower( ColorString(1) ),
case ' ', NewColor = colorfixer( fliplr( deblank( fliplr( ColorString ))));
case 'w', NewColor = '[1 1 1]'; % white
case 'r', NewColor = '[1 0 0]'; % red
case 'g', NewColor = '[0 1 0]'; % green
case 'y', NewColor = '[1 1 0]'; % Yellow
case 'm', NewColor = '[1 0 1]'; % magenta
case 'c', NewColor = '[0 1 1]'; % cyan
case 'k', NewColor = '[0 0 0]'; % black
case 'd', NewColor = '[0.5 0 0]'; % dark red
case 'a', NewColor = '[0.49 0 0.38]'; % aquamarine
case 'b', 
    if strcmp( lower( ColorString), 'black' ),
          NewColor = '[0 0 0]'; % black
    else,
          NewColor = '[0 0 1]'; % blue
    end;  
     
otherwise,
    % Assume a proper RGB triplet has been entered
    NewColor = ColorString;
    if isempty( findstr( '[', NewColor ) ), NewColor = [ '[' NewColor ]; end
    if isempty( findstr( ']', NewColor ) ), NewColor = [ NewColor, ']' ]; end

end % Switch
