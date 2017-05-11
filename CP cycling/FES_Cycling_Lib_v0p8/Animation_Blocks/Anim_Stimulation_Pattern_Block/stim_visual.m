function varargout = tim_Visual(varargin)
% STIM_VISUAL Application M-file for Stim_Visual.fig
%    FIG = STIM_VISUAL launch Stim_Visual GUI.
%    STIM_VISUAL('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 18-Jun-2003 20:40:59

if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');

	% Use system color scheme for figure:
	set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);

	if nargout > 0
		varargout{1} = fig;
	end

elseif strcmp(varargin{1}, 'update') % run user function update
    
    if length(varargin) ~= 8
        disp(['stim_Visual usage:']);
        disp([' ']);
        disp(['stim_Visual - will open the GUI']);
        disp([' ']);
        disp(['stim_Visual(''update'', h, angle, vel, thrtl, pw, stimPat, stimAct)']);
        disp(['   This will set the position of the graphics on the GUI.']);
        disp(['   Where: ']);
        disp(['      h       = the GUI handle']);
        disp(['      angle   = the crank angle (deg.)']);
        disp(['      vel     = the velocity of the crank (deg./s)']);
        disp(['      thrtl   = the throttle value']);
        disp(['      pw      = the pulsewidth']);
        disp(['      stimPat = the stimulation pattern']);
        disp(['       = [[QR HR GR CR QL HL GL CL];  % start angles']);
        disp(['          [QR HR GR CR QL HL GL CL]]; % stop angles']);
        disp(['      stimAct = the stimulation activation']);
        disp(['       = [QR HR GR CR QL HL GL CL];  % either 0 or 1']);
        disp([' ']);
        return;
    else
        this_h  = varargin{2};
        angle   = varargin{3};
        vel     = varargin{4};
        thrtl   = varargin{5};
        pw      = varargin{6};
        stimPat = varargin{7};
        stimAct = varargin{8};
        
        hndls = guihandles(this_h);
        set(this_h, 'HandleVisibility', 'on'); % allow the function to work from the command line
        updateFigure(hndls, angle, vel, thrtl, pw, stimPat, stimAct);
        set(this_h, 'HandleVisibility', 'callback'); % return the protection to the GUI
    end
        
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

	try
		if (nargout)
			[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
		else
			feval(varargin{:}); % FEVAL switchyard
		end
	catch
		disp(lasterr);
	end

end


%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and 
%| sets objects' callback properties to call them through the FEVAL 
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the 
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.


% --------------------------------------------------------------------
function updateFigure(handles, angle, vel, thrtl, pw, stimPat, stimAct);
% This is a user function (not part of the gui callbacks but used by them)

% Inputs are:
% handles = the handles of the components on the GUI
% angle   = crank angle (in deg. please)
% vel     = crank angular velocity  (in deg./sec. please)
% thrtl   = throttle value
% pw      = stimulation pulsewidth (in micro sec. please)
% stimPat = (modified with vel) stimulation pattern  (in deg. please)
%         = [[QR, HR, GR, CR, QL, HL, GL, CL]; start angles
%         =  [QR, HR, GR, CR, QL, HL, GL, CL]]; stop angles
% stimAct = stimulation activation (either 0 or 1)
%         = [QR, HR, GR, CR, QL, HL, GL, CL];

if isempty(handles) % if GUI is not built yet then just return;
    %disp('no handles :-(');
    return;
end

axes(handles.visual_axes); % set this to the current axes

% Load axes userdata and if not empty delete all children with handles stored here
old_h = get(handles.visual_axes, 'UserData');
if ~isempty(old_h)
    delete(old_h);
end

% plot patches on the axes
patch_c = { ...
        [1 0 0], ... % R Quads (red)
        [0 0 1], ... % R Hams (blue)
        [0 1 0], ... % R Gluts (green)
        [1 1 0], ... % R Calfs (yellow)
        [1 0 0], ... % L Quads (red)
        [0 0 1], ... % L Hams (blue)
        [0 1 0], ... % L Gluts (green)
        [1 1 0]};    % L Calfs (yellow)

% change color based on stimulation activation
act_c = 0.5.*(1+stimAct);
for i = 1 : length(patch_c)
    patch_c{i} = patch_c{i}.*act_c(i);
end

arc_r = [ ...
        0.94 0.84 0.74 0.64 0.94 0.84 0.74 0.64; ... % arc radius top: QR, HR, GR, CR, QL, HL, GL, CL
        0.86 0.76 0.66 0.56 0.86 0.76 0.66 0.56];    % arc radius bottom: QR, HR, GR, CR, QL, HL, GL, CL

new_h = []; % prepare to get a new set of handles

for i = 1 : length(stimPat(1,:))
    if (stimPat(1,i) < stimPat(2,i))
        a = [stimPat(1,i):1:stimPat(2,i)];
    elseif (stimPat(1,i) > stimPat(2,i))
        a = [stimPat(1,i):1:359 0:1:stimPat(2,i)];
    end
    if (stimPat(1,i) ~= stimPat(2,i))
        patch_x = [arc_r(1,i).*cos((a(1:1:end)./180).*pi) arc_r(2,i).*cos((a(end:-1:1)./180).*pi)];
        patch_y = [-arc_r(1,i).*sin((a(1:1:end)./180).*pi) -arc_r(2,i).*sin((a(end:-1:1)./180).*pi)];
        new_h(end+1) = patch(patch_x, patch_y, patch_c{i});
    end
end

% draw angle line (draw this after the patches so it appears on top of them)
new_h(end+1) = line([0 cos((angle./180).*pi)], [0 -sin((angle./180).*pi)], 'Color', 'k', 'LineWidth', 1.5);

% Save handles of patches and angle line in userdata of the axes
set(handles.visual_axes, 'UserData', new_h);


% set the text values
try % Text components may not be constructed yet 
    set(handles.angleText, 'String', num2str(round(angle)));
    set(handles.velText, 'String', num2str(round(vel)));
    set(handles.throttleText, 'String', num2str(round(thrtl)));
    set(handles.pulsewidthText, 'String', num2str(round(pw)));
    
    if     stimAct(1) set(handles.quadsText, 'String', 'Right');
    elseif stimAct(5) set(handles.quadsText, 'String', 'Left');
    else   set(handles.quadsText, 'String', '');
    end;
    if     stimAct(2) set(handles.hamsText, 'String', 'Right');
    elseif stimAct(6) set(handles.hamsText, 'String', 'Left');
    else   set(handles.hamsText, 'String', '');
    end;
    if     stimAct(3) set(handles.glutsText, 'String', 'Right');
    elseif stimAct(7) set(handles.glutsText, 'String', 'Left');
    else   set(handles.glutsText, 'String', '');
    end;
    if     stimAct(4) set(handles.calfsText, 'String', 'Right');
    elseif stimAct(8) set(handles.calfsText, 'String', 'Left');
    else   set(handles.calfsText, 'String', '');
    end;
    
end


% --------------------------------------------------------------------
function varargout = visual_axes_CreateFcn(h, eventdata, handles, varargin)

axes(h); % set this to the current axes

% draw a circumfurance around the plot area
a = [0:1:360]; line([cos((a./180).*pi)], [sin((a./180).*pi)], 'Color', 'k');
% draw zero angle
line([0 1], [0 0], 'Color', 'k', 'LineStyle', '-.');


% --------------------------------------------------------------------
function varargout = test(handles)

example = 1;

switch example
case 1
    % Set_up default values
    angle   = 10;    % crank angle
    vel     = 20;    % crank angular velocity
    thrtl   = 30;    % throttle value
    pw      = 40;    % stimulation pulsewidth
    stimPat = [ ... % (modified with vel) stimulation pattern
            55, 188,  90,  0, 235,  8, 270, 180; ... % start angles: QR, HR, GR, CR, QL, HL, GL, CL
            155, 265, 180, 10, 335, 85,   0, 190  ... % stop angles:  QR, HR, GR, CR, QL, HL, GL, CL
        ];
    stimAct = [ ... % stimulation activation
            0, 0, 0, 0, 0, 0, 0, 0 ... % QR, HR, GR, CR, QL, HL, GL, CL
        ];
    
    %  Update the figure with the default values
    updateFigure(handles, angle, vel, thrtl, pw, stimPat, stimAct);
case 2
    % Set_up default values
    angle   = 50;    % crank angle
    vel     = 30;    % crank angular velocity
    thrtl   = 40;    % throttle value
    pw      = 50;    % stimulation pulsewidth
    stimPat = [ ... % (modified with vel) stimulation pattern
            55, 188,  90,  0, 235,  8, 270, 180; ... % start angles: QR, HR, GR, CR, QL, HL, GL, CL
            155, 265, 180, 10, 335, 85,   0, 190  ... % stop angles:  QR, HR, GR, CR, QL, HL, GL, CL
        ];
    stimPat = stimPat+5;
    stimAct = [ ... % stimulation activation
            0, 1, 0, 1, 1, 0, 1, 0 ... % QR, HR, GR, CR, QL, HL, GL, CL
        ];
    
    %  Update the figure with the default values
    updateFigure(handles, angle, vel, thrtl, pw, stimPat, stimAct);
end


% --------------------------------------------------------------------
function varargout = exitBut_Callback(h, eventdata, handles, varargin)

close(handles.Stim_Visual_fig);
