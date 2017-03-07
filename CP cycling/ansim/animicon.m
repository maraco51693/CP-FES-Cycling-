function handles = animicon(action)
%ANIMICON Icon library for Animation block object icons.
%       action
%       -------
%       lineobj
%	patchobj
%       

%	Loren Dean April, 1995.
%   6/16/97 KGK change icon shape; implement switch/case flow ctrl
%   $Author$  $State$
%	Copyright (c) 1990-97 by The MathWorks, Inc.
% 	$Revision$  $Date$

switch lower(action),

case 'lineobj',
  handles = line([.2 .8 ],[.8 .2],'Color','k','LineWidth',2);

case 'patchobj',
  color=[1 1 1]*0;
  handles=patch( ...
               'XData',[0.20 0.85 0.6 0.8 0.2], ...
               'YData',[0.15 0.15 0.4 0.8 0.8], ...
               'EdgeColor',color    , ...
               'FaceColor',color      ...
               );
end
% end animicon
