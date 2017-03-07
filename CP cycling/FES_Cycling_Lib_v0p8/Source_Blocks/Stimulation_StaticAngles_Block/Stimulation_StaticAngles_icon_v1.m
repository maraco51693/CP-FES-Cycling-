% ==========================================
% Stimulation_StaticAngles_icon_v1.m


% ==========================================
% Set up plot;
gca; cla;
axis([0 1 0 1]);
hold on;
set(gcf, 'position', [50 50 260 150]);

Quad_R = [55 155]; Ham_R = [188 265]; Glut_R = [90 180]; Calf_R = [0 1];
Quad_L = [235 335]; Ham_L = [8 85]; Glut_L = [270 0]; Calf_L = [180 181];

% ==========================================
% Begin:
text(0.5, 0.9, 'Static Stimulation Angles', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');

plot([0.05 0.95], [0.65 0.65]);
plot([0.2 0.2], [0.8 0.2]);
plot([0.6 0.6], [0.8 0.2]);

text(0.1, 0.7, 'M', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
text(0.4, 0.7, 'Right', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
text(0.8, 0.7, 'Left', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');

text(0.1, 0.55, 'Q', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
text(0.4, 0.55, num2str(Quad_R), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
text(0.8, 0.55, num2str(Quad_L), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');

text(0.1, 0.45, 'H', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
text(0.4, 0.45, num2str(Ham_R), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
text(0.8, 0.45, num2str(Ham_L), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');

text(0.1, 0.35, 'G', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
text(0.4, 0.35, num2str(Glut_R), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
text(0.8, 0.35, num2str(Glut_L), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');

text(0.1, 0.25, 'C', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
text(0.4, 0.25, num2str(Calf_R), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
text(0.8, 0.25, num2str(Calf_L), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');


% ==========================================
% End of file