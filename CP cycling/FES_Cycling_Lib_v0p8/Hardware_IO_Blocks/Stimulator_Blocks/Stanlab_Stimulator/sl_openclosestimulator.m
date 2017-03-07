% the stimulator block should have the following properties set:-
% set_param(gcb,'InitFcn','sl_openclosestimulator(0)')
%   => ensures that stimulator is opened when simulation starts
%      (Note that StartFcn is not suitable since it gets executed too late.)
% set_param(gcb,'OpenFcn','sl_openclosestimulator(1)')
%   better: sl_openclosestimulator(1,eval(get_param(gcb,'chan_stanlab')))
%   => enables opening / closing of stimlator by clicking on block
% set_param(gcb,'LoadFcn','set_param(gcb,''BackgroundColor'',''red'')')
%   => ensures that the stimulator block color is always red (=closed) upon 
%      opening the model
% set_param(gcb,'DeleteFcn','sl_openclosestimulator(-1)');

function [] = sl_openclosestimulator(flag,channels)

com=get_param(gcb,'UserData');
if nargin <2
    channels = str2num(get_param(gcb,'chan_stanlab'));
end 
disp(['Channels are so far = ', num2str(channels)]);
port = get_param(gcb,'com_port');

if (flag>=0)
  if (isempty(com) | ~strcmp('uint32',class(com)))
	 % stimulator not opened
	 fprintf('Trying to open stimulator on port %s with channels',port);
    if ~isempty(channels)
      for(k=1:length(channels))
        fprintf(' %i', channels(k));
      end
    end
    fprintf(' ...\n');
	 com =openstimulator(port,channels);
	 
	 if (com~=0)
		fprintf('Opening successful\n');
		set_param(gcb,'BackgroundColor','green');
		set_param(gcb,'UserData',com);
		% set the CloseFcn of the model to close the stimulator
		%set_param(gcs,'CloseFcn','sl_openclosestimulator(-1)');
	 else
		set_param(gcb,'BackgroundColor','red');
		set_param(gcb,'UserData','');
	 end
  else
	 if (flag==1)
		% close stimulator
		fprintf('Trying to close stimulator\n');
		closestimulator(com);
		set_param(gcb,'BackgroundColor','red');
		set_param(gcb,'UserData','');
	 end
  end
elseif (flag==-1)
  if (~isempty(com) & com~=0)
	 % close stimulator
	 set_param(gcb,'BackgroundColor','red');
	 set_param(gcb,'UserData','');
	 pause(1);
	 fprintf('Closing system: ');
	 fprintf('Trying to close stimulator\n');
	 closestimulator(com);
  else
	 fprintf('Hint: If stimulator is still open try:\n\tload openstimulator.mat\n\tclosestimulator(com)\n');
  end
end

