% ==========================================
% DAQ_Read_icon.m


% ==========================================
% Set up plot;
gca; cla;
axis([0 1 0 1]);
hold on;
set(gcf, 'position', [50 50 200 90]);

lowsign = '-';
gain_str = '1';
channels = [1 2 3 4];

% ==========================================
% Begin:

text(0.5, 0.85, 'Analogue Inputs', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');

plot([0.1 0.15 0.15; 0.15 0.15 0.1], [0.6 0.6 0.4; 0.6 0.4 0.4]);
plot([0.15 0.2 0.23; 0.23 0.23 0.2], [0.5 0.47 0.5; 0.5 0.5 0.53]);

plot([0.25:0.002:0.45], 0.1.*(-sin(70.*[0.2:0.001:0.3]+0.5)+sin(200.*[0.2:0.001:0.3]-1.2))+0.5);

plot([0.47 0.5 0.5; 0.5 0.47 0.55], [0.47 0.5 0.5; 0.5 0.53 0.5]);

text(0.07, 0.6, '+', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
text(0.07, 0.4, lowsign, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');

text(0.8, 0.5, ['Gain=', gain_str], 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');

text(0.5, 0.15, ['Channels ', num2str(channels)], 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');

% ==========================================
% End of file