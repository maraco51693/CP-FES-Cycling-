% ==========================================
% DAQ_Read_icon.m


% ==========================================
% Set up plot;
gca; cla;
axis([0 1 0 1]);
hold on;
set(gcf, 'position', [50 50 200 90]);

port = 1;

% ==========================================
% Begin:

text(0.5, 0.85, 'Digital I/O', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');

%plot([0.10 0.13 0.16 0.19 0.22 0.25 0.28; 0.13 0.16 0.19 0.22 0.25 0.28 0.31], [0.50 0.57 0.60 0.80 0.55 0.70 0.47; 0.50 0.57 0.60 0.80 0.55 0.70 0.47]);


% plot([0.10 0.13 0.16 0.19 0.22 0.25 0.28; 0.13 0.16 0.19 0.22 0.25 0.28 0.31]+0.05, [0.50 0.57 0.60 0.80 0.55 0.70 0.47; 0.50 0.57 0.60 0.80 0.55 0.70 0.47]-0.05);
% plot([0.13 0.16 0.19 0.22 0.25 0.28; 0.13 0.16 0.19 0.22 0.25 0.28]+0.05, [0.50 0.57 0.60 0.80 0.55 0.70; 0.57 0.60 0.80 0.55 0.70 0.47]-0.05);

plot([0.10 0.15 0.20 0.25 0.30 0.35 0.40; 0.15 0.20 0.25 0.30 0.35 0.40 0.45]-0.05, [0.50 0.57 0.60 0.70 0.53 0.60 0.47; 0.50 0.57 0.60 0.70 0.53 0.60 0.47]-0.05);
plot([0.15 0.20 0.25 0.30 0.35 0.40; 0.15 0.20 0.25 0.30 0.35 0.40]-0.05, [0.50 0.57 0.60 0.70 0.53 0.60; 0.57 0.60 0.70 0.53 0.60 0.47]-0.05);

plot([0.45 0.50 0.50; 0.55 0.55 0.55], [0.50 0.46 0.54; 0.50 0.50 0.50]);

text(0.75, 0.5, ['0 1 0 0 1'], 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');

text(0.5, 0.15, ['Port ', num2str(port)], 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');

% ==========================================
% End of file