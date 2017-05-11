function pos = kfindstr(string1,string2)

% FileName: kfindstr.m
% Rev.Date: 1/13/96
% FileType: function
%
% KFINDSTR returns the starting indices of any occurrences
%   of a shorter string within a longer string. It does it
%   faster than FINDSTR, too (especially if the short string
%   is not really that short!)
%
%   Examples
%       s = 'How much wood would a woodchuck chuck?';
%       findstr(s,'a')    returns  21
%       findstr(s,'wood') returns  [10 23]
%       findstr(s,'Wood') returns  []
%       findstr(s,' ')    returns  [4 9 14 20 22 32]
%
%   See also STRCMP, STRNCMP, STRMATCH. 

% Written by: Kevin G Kohrt
% Written on: 12/6/96 as ffindstr, from which the core pattern match
%              algorithm was extracted.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%---------------------------------------------------------------------------
% Validate input arguments
%---------------------------------------------------------------------------
	% Check for correct number of input arguments: made by runtime compiler
	
	% Get lengths of strings
	shortLen = length(string2);
	longLen = length(string1);

	% Make string2 the shorter.
	if longLen < shortLen
	   t = string1; string1 = string2; string2 = t; 
	   shortLen = longLen;
	end
	
	% Quick exit for empty string. 
	if shortLen == 0;
	   pos = [];
	   return
	end

%---------------------------------------------------------------------------
% Find pattern matches using convolution on ascii values
%---------------------------------------------------------------------------

	% convolve short string with itself (look in mirror)
	ideal_set = conv( string2, string2 );   
	% select peak correlation value at perfect match (recognize self)
	hitVal = ideal_set( shortLen );     
	% find matches in longer string, adjusting for convolution offset
	pos = (find( conv(string1,string2) == hitVal ) - shortLen + 1); 

%---------------------------------------------------------------------------
% End of function
%---------------------------------------------------------------------------
