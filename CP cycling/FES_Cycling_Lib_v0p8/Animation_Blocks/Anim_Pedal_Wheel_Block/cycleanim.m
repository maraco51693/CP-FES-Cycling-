function varargout = cycleAnim(varargin)
% CYCLEANIM Application M-file for cycleAnim.fig
%    FIG = CYCLEANIM launch cycleAnim GUI.
%    CYCLEANIM('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 18-Jul-2003 11:42:11

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
function varargout = new_wheel_angle(gui_h, angle)

angle = angle - (360 * floor(angle/360));

hndls = guihandles(gui_h);

wheel_center_x = 7;
wheel_center_y = 9;

line_hs = get(hndls.animAxes, 'UserData');

current_angle = get(line_hs.wheel_angle, 'UserData');
rotate_angle = angle - current_angle;
if (rotate_angle == 0) return; end;

rotate(line_hs.wheel_lines, [0.0 0.0 -1.0], rotate_angle, [wheel_center_x wheel_center_y 0.0]);
rotate(line_hs.wheel_angle, [0.0 0.0 -1.0], rotate_angle, [wheel_center_x wheel_center_y 0.0]);

set(line_hs.wheel_angle, 'UserData', angle);


% --------------------------------------------------------------------
function varargout = new_pedal_angle(gui_h, angle)

angle = angle - (360 * floor(angle/360));

hndls = guihandles(gui_h);

ring_pedal_center_x = 19;
ring_pedal_center_y = 9;
pedal_size = [1.0 0.5];

line_hs = get(hndls.animAxes, 'UserData');

current_angle = get(line_hs.pedal_parts(1), 'UserData');
rotate_angle = angle - current_angle;
if (rotate_angle == 0) return; end;

if (get(line_hs.chain(1), 'lineStyle') == ':')
    set(line_hs.chain(1), 'lineStyle', '-.');
    set(line_hs.chain(2), 'lineStyle', '-.');
else
    set(line_hs.chain(1), 'lineStyle', ':');
    set(line_hs.chain(2), 'lineStyle', ':');
end

rotate(line_hs.pedal_parts(1), [0.0 0.0 -1.0], rotate_angle, [ring_pedal_center_x ring_pedal_center_y 0.0]);
pedal_x = get(line_hs.pedal_parts(1), 'XData')-(pedal_size(1)/2);
pedal_y = get(line_hs.pedal_parts(1), 'YData')-(pedal_size(2)/2);
set(line_hs.pedal_parts(2), 'Position', [pedal_x(1) pedal_y(1) pedal_size]);
set(line_hs.pedal_parts(3), 'Position', [pedal_x(2) pedal_y(2) pedal_size]);

set(line_hs.pedal_parts(1), 'UserData', angle);


% --------------------------------------------------------------------
function varargout = shift_wheel_angle(gui_h, rotate_angle)

if (rotate_angle == 0) return; end;

hndls = guihandles(gui_h);

wheel_center_x = 7;
wheel_center_y = 9;

line_hs = get(hndls.animAxes, 'UserData');

current_angle = get(line_hs.wheel_angle, 'UserData');

rotate(line_hs.wheel_lines, [0.0 0.0 -1.0], rotate_angle, [wheel_center_x wheel_center_y 0.0]);
rotate(line_hs.wheel_angle, [0.0 0.0 -1.0], rotate_angle, [wheel_center_x wheel_center_y 0.0]);

new_angle = current_angle + rotate_angle;
new_angle = new_angle - (360 * floor(new_angle/360));

set(line_hs.wheel_angle, 'UserData', new_angle);


% --------------------------------------------------------------------
function varargout = shift_pedal_angle(gui_h, rotate_angle)

if (rotate_angle == 0) return; end;

hndls = guihandles(gui_h);

ring_pedal_center_x = 19;
ring_pedal_center_y = 9;
pedal_size = [1.0 0.5];

line_hs = get(hndls.animAxes, 'UserData');

current_angle = get(line_hs.pedal_parts(1), 'UserData');

if (get(line_hs.chain(1), 'lineStyle') == ':')
    set(line_hs.chain(1), 'lineStyle', '-.');
    set(line_hs.chain(2), 'lineStyle', '-.');
else
    set(line_hs.chain(1), 'lineStyle', ':');
    set(line_hs.chain(2), 'lineStyle', ':');
end

rotate(line_hs.pedal_parts(1), [0.0 0.0 -1.0], rotate_angle, [ring_pedal_center_x ring_pedal_center_y 0.0]);
pedal_x = get(line_hs.pedal_parts(1), 'XData')-(pedal_size(1)/2);
pedal_y = get(line_hs.pedal_parts(1), 'YData')-(pedal_size(2)/2);
set(line_hs.pedal_parts(2), 'Position', [pedal_x(1) pedal_y(1) pedal_size]);
set(line_hs.pedal_parts(3), 'Position', [pedal_x(2) pedal_y(2) pedal_size]);

new_angle = current_angle + rotate_angle;
new_angle = new_angle - (360 * floor(new_angle/360));

set(line_hs.pedal_parts(1), 'UserData', new_angle);


% --------------------------------------------------------------------
function varargout = new_var_vals(gui_h, wheelVel, AvgTorqu, pedalVel)

hndls = guihandles(gui_h);

set(hndls.wheelVel_value,   'String', num2str(wheelVel));
set(hndls.Torque_value,     'String', num2str(AvgTorqu));
set(hndls.PedCadence_value, 'String', num2str(pedalVel));


% --------------------------------------------------------------------
function varargout = animAxes_CreateFcn(h, eventdata, handles, varargin)

axes(h); cla; axis([0 24 0 18]); % 24 x 18

wheel_radius = 6;
wheel_thickness = 1;
wheel_center_x = 7;
wheel_center_y = 9;
ring_wheel_radius = 1;
ring_pedal_radius = 2;
ring_pedal_center_x = 19;
ring_pedal_center_y = 9;
pedal_radius = 4;
pedal_size = [1.0 0.5];

p = [(pi/45) : (pi/45) : 2*pi];

wheel_X_outer = (wheel_radius.*sin(p))+wheel_center_x;
wheel_Y_outer = (wheel_radius.*cos(p))+wheel_center_y;
wheel_X_inner = ((wheel_radius-wheel_thickness).*sin(p))+wheel_center_x;
wheel_Y_inner = ((wheel_radius-wheel_thickness).*cos(p))+wheel_center_y;
patch(wheel_X_outer, wheel_Y_outer, 'k');
patch(wheel_X_inner, wheel_Y_inner, 'w');

ring_wheel_X = (ring_wheel_radius.*sin([0 p]))+wheel_center_x;
ring_wheel_Y = (ring_wheel_radius.*cos([0 p]))+wheel_center_y;
line(ring_wheel_X, ring_wheel_Y, 'Color', 'k');

ring_pedal_X = (ring_pedal_radius.*sin([0 p]))+ring_pedal_center_x;
ring_pedal_Y = (ring_pedal_radius.*cos([0 p]))+ring_pedal_center_y;
line(ring_pedal_X, ring_pedal_Y, 'Color', 'k');

line_hs.wheel_lines = line([wheel_X_inner(1:2:end); wheel_X_outer([3:2:end 1])], [wheel_Y_inner(1:2:end); wheel_Y_outer([3:2:end 1])], 'Color', 'm', 'linestyle', ':');
line_hs.wheel_angle = line([wheel_center_x wheel_center_x+(wheel_radius-wheel_thickness)], [wheel_center_y wheel_center_y], 'Color', 'k', 'LineWidth', 2);
set(line_hs.wheel_angle, 'UserData', 0);

line_hs.chain = line([wheel_center_x wheel_center_x; ring_pedal_center_x ring_pedal_center_x], ...
    [wheel_center_y+ring_wheel_radius wheel_center_y-ring_wheel_radius; ...
        ring_pedal_center_y+ring_pedal_radius ring_pedal_center_y-ring_pedal_radius], ...
    'lineStyle', ':');

line_hs.pedal_parts(1) = line([ring_pedal_center_x-pedal_radius ring_pedal_center_x+pedal_radius], [ring_pedal_center_y ring_pedal_center_y], 'Color', 'k', 'LineWidth', 2);
set(line_hs.pedal_parts(1), 'UserData', 0);
pedal_x = get(line_hs.pedal_parts(1), 'XData')-(pedal_size(1)/2);
pedal_y = get(line_hs.pedal_parts(1), 'YData')-(pedal_size(2)/2);
line_hs.pedal_parts(2) = rectangle('Position', [pedal_x(1) pedal_y(1) pedal_size], 'FaceColor', [0.5 0.0 0.5]);
line_hs.pedal_parts(3) = rectangle('Position', [pedal_x(2) pedal_y(2) pedal_size], 'FaceColor', [0.5 0.0 0.5]);

set(h, 'UserData', line_hs);

