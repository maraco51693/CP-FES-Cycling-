function rout = round2num( rin, rto, rtype )

%ROUND2NUM - rounds to a given number
%  ROUND2NUM( number, granularity, direction ) rounds the real number
%  NUMBER either up, down, or to the closest number based on the 
%  DIRECTION so that the resulting number will be a multiple of 
%  GRANULARITY. All parameters must be scalars or vectors.
%
%  DIRECTION, d, may be any one of the following values:
%    d > 0, or d = 'up'              rounds up
%    d = 0, or (no d parameter)      round to nearest GRANULARITY
%    d < 0, or d = 'down'            rounds down
%
%  ROUND2NUM( number ) rounds NUMBER to the nearest integer, 
%  and is identical to ROUND( number ).
%
% See also ROUND, FLOOR, CEIL, FIX

% Written by: Kevin G Kohrt
% Written on: 6/96

% Validate input arguments
if nargin < 1;                           % not even 1 argument given! error out
  help round2num; 
  error('Not enough arguments'); 
elseif isstr( rin ) | ~isreal( rin )     % 1st argument not valid! errpr out
  help round2num; 
  error('The first argument must be a real number'); 
elseif nargin < 2;                       % only 1 argument: do default rounding
  rout = round( rin );
  return;
elseif nargin < 3;                       % only 2 args: set default for 3rd arg
  rtype = 0; 
end

rlen = length(rin);

% Set round-off flags
if isstr(rtype),
  goup = strcmp(lower(rtype(1)),'u');
  godown = strcmp(lower(rtype(1)),'d');
  goany = 0;
else
  goup = (rtype > 0);
  godown = (rtype < 0);
  goany = (rtype == 0);
end

% If there are more input numbers than ways to round them...
if rlen > length(goup);         
  % vector expand the 1st rounding direction, and ignore the rest
  goup = goup(1)*ones(1,rlen);
  godown = godown(1)*ones(1,rlen);
end

% If there are more input numbers than numbers to round to...
if rlen > length(rto);         
  % vector expand the 1st round-to number, and ignore the rest
  rto= rto(1)*ones(1,rlen);
end

% round off
rerr = mod( rin, rto );

for idx = 1:rlen,
  if (rerr(idx) == 0),
    rout(idx) = rin(idx);
  elseif goup(idx),
    rout(idx) = rin(idx) + rto(idx) - rerr(idx);
  elseif godown(idx),
    rout(idx) = rin(idx) - rerr(idx);
  elseif rerr(idx) >= rto(idx)/2,
    rout(idx) = rin(idx) + rto(idx) - rerr(idx);
  elseif rerr(idx) < rto(idx)/2,
    rout(idx) = rin(idx) - rerr(idx);
  else
    rout(idx) = pi;
    disp('Something went wrong with the roundoff algorithm')
  end
end


  
  
