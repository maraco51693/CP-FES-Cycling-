function [id_model, id_range] = mdl_ident_ben(ident_data, mdl_order, Ts, rmv_trend, user_range)
% id_model = mdl_ident_ben(ident_data, [na nb nc nk], Ts)
%   This m function is used to automatically identify a
%   model based on measured data.  This m function uses
%   standard identification functions.
%
%   ident_data: should be a 2xn element matrix where
%     column 1 is the ident referrence signal (usually
%     PRBS) and column 2 is the plant responce to the
%     referrence.
%
%   [na nb nc nk]: see help armax.
%
%   Ts: Sample time.
%
%   id_model: is the identified model in idpoly format.
%
% mdl_ident_ben(ident_data, [na nb nc nk], rmv_trend)
%   The parameter rmv_trend can be used to select
%   whether to remove trends from the data.  If
%   rmv_trend = 0, then only the mean is subtracted
%   from the data.  Default is rmv_trend = 1.
%
% mdl_ident_ben(ident_data, [na nb nc nk], rmv_trend, [r1 r2])
%   Can be used to set the identification range to
%   within (or including) r1 and r2. If [r1 r2] is not
%   used the function will ask the user to select a
%   range from a plot using the mouse.
%
% [id_model id_range] = mdl_ident_ben(ident_data, ...)
%   Will also give the exact data set used in
%   identification.  The format of id_range is iddata.

% Author : Benjamin A Saunders
%   Date : 10 / October 2003
% University of Glasgow - Mechanical Engineering

% Updates:
%   11 Oct 2003 : Benjamin A Saunders
%      Added rmv_trend and user_range features to this
%      function.


% ------------------------------------------------------
% Check inputs

% Set default outputs (if function should fail)
id_model = []; id_range = [];

% Set debugging mode
debugging = 0;

if nargin < 3
    error('Parameters ''ident_data'', ''[na nb nc nk]'' and ''Ts'' are required for this function.');
else
    if (size(ident_data,2) ~= 3)
        error('Parameter ''ident_data'' should be a nx3 matrix.');
    end
    if (length(mdl_order) ~= 4)
        error('Parameter ''[na nb nc nk]'' does not have 4 elements.');
    end
end

if nargin < 4
    remove_just_mean = 0;
else
    if ((rmv_trend ~= 0) & (rmv_trend ~= 1))
        error('Parameter ''rmv_trend'' should be either 0 or 1.');
    end
    remove_just_mean = ~rmv_trend;
end

if nargin < 5
    get_ident_range_from_plot = 1;
else
    if ((length(user_range) ~= 2) | (~isreal(user_range)))
        error('Parameter ''[r1 r2]'' should be real and have only 2 elements.');
    end
    get_ident_range_from_plot = 0;
end


% ------------------------------------------------------
% Use the plot to select a range of data to use in identification

if get_ident_range_from_plot
    
    % --------------------------
    % first plot the ident data
    f_h = figure; cla; hold on;
    plot(ident_data(:,1), ident_data(:,2)./max(ident_data(:,2)), 'k');
    plot(ident_data(:,1), ident_data(:,3)./max(ident_data(:,3)), 'b');
    title('Please select X cordinates to containe the identification data');
    axis([ident_data(1,1) ident_data(end,1) get(gca,'YLim')]);
        
    % --------------------------
    % now get the data from the plot using ginput
    button = 'No';
    while ~strcmp(button, 'Yes');
        
        % get input (and then display current selection)
        [g_x, g_y] = ginput(2);
        
        % If not enough inputs
        if (isempty(g_x) | (length(g_x) ~= 2))
            % cancel whole identification
            warning('Invalid range entered via ginput.');
            close(f_h);
            return;
        end
        
        %display current selection
        l_h = line([g_x(1) g_x(2); g_x(1) g_x(2)], [get(gca,'YLim')' get(gca,'YLim')'], 'Color', 'r');
            
        % make sure that g_x is assending
        if g_x(2) < g_x(1)
            g_x = [g_x(2) g_x(1)];
            g_y = [g_y(2) g_y(1)]; % g_y is not used but best keep values together
        end
        
        % Request confirmation from user that range is correct
        button = questdlg(['Use data between ', num2str(g_x(1)), ' and ', num2str(g_x(2)),' ?'], ...
            'Selection of identification range');
        if strcmp(button, 'Cancel')
            % cancel whole identification
            close(f_h);
            return;
        elseif strcmp(button, 'No')
            % delete lines from plot and re-start the while loop to select a new range
            delete(l_h);
        end
    end
    
    % use selected range to find index elements
    ident_range_idx = [max(find(ident_data(:,1) < g_x(1)))+1 min(find(ident_data(:,1) > g_x(2)))-1];
    
    % close the figure for selecting a identification range
    close(f_h);
    
else
    
    % make sure that user_range is assending
    if user_range(2) < user_range(1)
        user_range = [user_range(2) user_range(1)];
    end
    ident_range_idx = [max(find(ident_data(:,1) < user_range(1)))+1 min(find(ident_data(:,1) > user_range(2)))-1];
    
end


% ------------------------------------------------------
% Data conditioning (remove trends etc)

if remove_just_mean
    
    % remove just the means from the data
    ident_range = [ident_data(ident_range_idx(1):ident_range_idx(2),1) ...
            detrend(ident_data(ident_range_idx(1):ident_range_idx(2),[2 3]), ...
            'constant')];
    
else
    
    % remove trends from the data using detrend
    ident_range = [ident_data(ident_range_idx(1):ident_range_idx(2),1) ...
            detrend(ident_data(ident_range_idx(1):ident_range_idx(2),[2 3]))];
end

if debugging
    figure; clf; hold on;
    plot(ident_range(:,1), ident_range(:,2), 'k');
    plot(ident_range(:,1), ident_range(:,3), 'b');
    title('Conditioned Data for Identification')
end

% Transform ident_data into iddata format and
% set the id_range output to the function
id_range = iddata(ident_range(:,3), ident_range(:,2), Ts);
id_data  = iddata(ident_data(:,3),  ident_data(:,2),  Ts); % used for compare function


% ------------------------------------------------------
% Identify model from selected data range using the
% idpoly format with the identification functions

% Identify the model
armax = armax(id_range, mdl_order);
arx   = arx(id_range, mdl_order([1 2 4]));

% Set the id_model output to the function
id_model = armax;


% ------------------------------------------------------
% Simulate the identified model over the identification range

disp_simulation_plot = 0;
if disp_simulation_plot
    
    figure; clf; hold on;
    compare(id_data, armax, 'm:', arx, 'g-.');
end

print_fit_percent = 1;
if print_fit_percent
    [cmpr_out, cmpr_fit] = compare(id_range, armax, arx);
    disp(['Orders = [', num2str(mdl_order), ']'])
    disp(['armax fit = ',num2str(cmpr_fit(1)), '%']);
    %disp(['arx fit   = ',num2str(cmpr_fit(2)), '%']);
    disp(' ');
end

show_step_response = 1;
if show_step_response
    % To Do Later ------------
end

