% ==========================================
% Stimulation_StaticAngles_icon_v2.m


% ==========================================
% Set up plot;
gca; cla;
axis([0 1 0 1]);
hold on;
set(gcf, 'position', [50 50 230 180]);

Quad_R = [55 155]; Ham_R = [188 265]; Glut_R = [90 180]; Calf_R = [0 1];
Quad_L = [235 335]; Ham_L = [8 85]; Glut_L = [270 0]; Calf_L = [180 181];

circle_center = [0.4, 0.4]; circle_radius = 0.35;
icon_circle_x = circle_radius.*sin([0:pi/18:2*pi]) + circle_center(1);
icon_circle_y = circle_radius.*cos([0:pi/18:2*pi]) + circle_center(2);

patch_width = 0.04;
ip_params = [...
    Quad_R(1), Quad_R(2), 0.35; ...
    Quad_L(1), Quad_L(2), 0.35; ...
    Ham_R(1),  Ham_R(2),  0.30; ...
    Ham_L(1),  Ham_L(2),  0.30; ...
    Glut_R(1), Glut_R(2), 0.25; ...
    Glut_L(1), Glut_L(2), 0.25; ...
    Calf_R(1), Calf_R(2), 0.20; ...
    Calf_L(1), Calf_L(2), 0.20; ...
    ];

ip_params(:,1) = ip_params(:,1)+90;
ip_params(:,2) = ip_params(:,2)+90;

for i = 1 : length(ip_params(:,1))
    if ip_params(i,2) < ip_params(i,1) ip_params(i,2) = ip_params(i,2) + 360; end
    x_outer = ip_params(i,3).*sin([(ip_params(i,1)/180)*pi:pi/18:(ip_params(i,2)/180)*pi]) + circle_center(1);
    y_outer = ip_params(i,3).*cos([(ip_params(i,1)/180)*pi:pi/18:(ip_params(i,2)/180)*pi]) + circle_center(1);
    x_inner = (ip_params(i,3)-patch_width).*sin([(ip_params(i,2)/180)*pi:-pi/18:(ip_params(i,1)/180)*pi]) + circle_center(1);
    y_inner = (ip_params(i,3)-patch_width).*cos([(ip_params(i,2)/180)*pi:-pi/18:(ip_params(i,1)/180)*pi]) + circle_center(1);
    patch_coord_x{i} = [x_outer x_inner];
    patch_coord_y{i} = [y_outer y_inner];
end


% ==========================================
% Begin:
text(0.5, 0.9, 'Static Stimulation Angles', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');

plot(icon_circle_x, icon_circle_y);
patch(patch_coord_x{1}, patch_coord_y{1}, [1 0 0]);
patch(patch_coord_x{2}, patch_coord_y{2}, [1 0 0]);
patch(patch_coord_x{3}, patch_coord_y{3}, [0 0 1]);
patch(patch_coord_x{4}, patch_coord_y{4}, [0 0 1]);
patch(patch_coord_x{5}, patch_coord_y{5}, [0 1 0]);
patch(patch_coord_x{6}, patch_coord_y{6}, [0 1 0]);
patch(patch_coord_x{7}, patch_coord_y{7}, [1 1 0]);
patch(patch_coord_x{8}, patch_coord_y{8}, [1 1 0]);

plot(circle_center(1)+[0 circle_radius+0.05], [circle_center(2) circle_center(2)]);

patch([0 -0.05 -0.05 0]+0.9, [-0.025 -0.025 0.025 0.025]+0.55, [1 0 0]);
text(0.92, 0.55, 'Q', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle');

patch([0 -0.05 -0.05 0]+0.9, [-0.025 -0.025 0.025 0.025]+0.45, [0 0 1]);
text(0.92, 0.45, 'H', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle');

patch([0 -0.05 -0.05 0]+0.9, [-0.025 -0.025 0.025 0.025]+0.35, [0 1 0]);
text(0.92, 0.35, 'G', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle');

patch([0 -0.05 -0.05 0]+0.9, [-0.025 -0.025 0.025 0.025]+0.25, [1 1 0]);
text(0.92, 0.25, 'C', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle');




% ==========================================
% End of file