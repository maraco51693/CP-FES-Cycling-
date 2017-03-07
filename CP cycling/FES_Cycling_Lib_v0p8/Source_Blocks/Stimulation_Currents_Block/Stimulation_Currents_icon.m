% ==========================================
% Stimulation_Currents_icon.m


% ==========================================
% Set up plot;
gca; cla;
axis([0 1 0 1]);
hold on;
set(gcf, 'position', [50 50 260 150]);

Quad_R = [110]; Ham_R = [100]; Glut_R = [90]; Calf_R = [0];
Quad_L = [110]; Ham_L = [100]; Glut_L = [90]; Calf_L = [0];

% ==========================================
% Begin:
text(0.5, 0.9, 'Stimulation Current', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');

plot([0.05 0.95], [0.65 0.65]);
plot([0.35 0.35], [0.8 0.2]);
plot([0.65 0.65], [0.8 0.2]);

text(0.2, 0.7, 'M', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
text(0.5, 0.7, 'Right', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
text(0.8, 0.7, 'Left', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');

text(0.2, 0.55, 'Q', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
text(0.5, 0.55, num2str(Quad_R), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
text(0.8, 0.55, num2str(Quad_L), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');

text(0.2, 0.45, 'H', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
text(0.5, 0.45, num2str(Ham_R), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
text(0.8, 0.45, num2str(Ham_L), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');

text(0.2, 0.35, 'G', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
text(0.5, 0.35, num2str(Glut_R), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
text(0.8, 0.35, num2str(Glut_L), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');

text(0.2, 0.25, 'C', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
text(0.5, 0.25, num2str(Calf_R), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
text(0.8, 0.25, num2str(Calf_L), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');


% ==========================================
% End of file