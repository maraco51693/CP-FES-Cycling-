% ==========================================
% DAQ_Write_icon.m


% ==========================================
% Set up plot;
gca; cla;
axis([0 1 0 1]);
hold on;
set(gcf, 'position', [50 50 200 90]);


channel = 1;

% ==========================================
% Begin:
text(0.5, 0.85, 'Analogue Outputs', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');

plot([0.02 0.05 0.05; 0.05 0.02 0.1], [0.47 0.5 0.5; 0.5 0.53 0.5]);

plot([0.15:0.002:0.35], 0.1.*(-sin(70.*[0.2:0.001:0.3]+0.5)+sin(200.*[0.2:0.001:0.3]-1.2))+0.5);

plot([0.42 0.45 0.45; 0.45 0.42 0.5], [0.47 0.5 0.5; 0.5 0.53 0.5]);

text(0.75, 0.5, ['Channel ', num2str(channel)], 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');


% ==========================================
% End of file