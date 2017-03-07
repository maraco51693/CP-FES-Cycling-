function [out, prem_data] = fuzzy_controller_ben(c_in, b, b_width)
% out = fuzzy_controller_ben(c_in, b)
%   Calculates the output from a fuzzy logic controller
%   for the vector of inputs c_in.  The position of
%   output membership funciton should be given in the
%   matrix b.  The number of dimensions of b should be
%   the same as the length of c_in.  The number of
%   elements in each dimension will be the number of
%   membership functions used for each input.
%
%   At the moment just triangular membership functions
%   are used.
%
% out = fuzzy_controller_ben(c_in, b, b_width)
%   Adding the input b_width to specify the width of
%   the output membership functions.  Default is 1.
%
% [out, prem_data] = fuzzy_controller_ben(c_in, b, b_width)
%   Will return the premise data in the form of an
%   vector of structures of size n.  The length of this
%   vector depends on the number of inputs and how the
%   membership functions overlap.  (For symetric
%   triangular functions n=2^length(c_in).) The
%   structure has 2 fields prem_data(n).mFcns shows the
%   active input membership functions used to calculate
%   the premise value given in prem_data(n).value. The
%   length of prem_data 

% Author : Benjamin A Saunders
%   Date : 01 December 2003
% University of Glasgow - Mechanical Engineering

% Updates:
%   02 Dec 2003 : Benjamin A Saunders
%      Changed the b_width to a function input
%      variable.  Also added prem_data as an output.
%

% Activate debugging mode
debugging = 0;
plot_input_tracking = 1;


% ------------------------------------------------------
% Check inputs

if nargin < 1
	help fuzzy_controller_ben;
	return;
else
	if length(c_in) < 1
		error('Empty input vector.');
	end
end

if nargin < 2
	%could use a standard b if one is not input? maybe impliment later ...
	error('Empty b matrix');
elseif (ndims(b) > 2) & (min(size(b)) < 2)
	error('Requires more than one membership function for each input (via size of b).');
end

if (ndims(b) > 2) & (ndims(b) ~= length(c_in))
	error('Dimension missmatch, the number of inputs must be equal the number of dims of b.');
end

if (ndims(b) == 2) & (min(size(b)) == 1) & (length(c_in) ~= 1)
	error('Dimension missmatch, the number of inputs must be equal the number of dims of b.');
end

if (ndims(b) == 2) & (min(size(b)) > 1) & (length(c_in) ~= 2)
	error('Dimension missmatch, the number of inputs must be equal the number of dims of b.');
end

if nargin < 3
	b_width = 1;
else
	if b_width <= 0
		error('The width of output membership functions can not be 0 or negative.');
	end
end


% ------------------------------------------------------
% Set up default values

% number of input membership functions
% for each input is defined by the size
% of the dimensions of b
if (ndims(b) == 2) & (min(size(b)) == 1)
	n_mFcns = length(b);
else
	n_mFcns = size(b);
end

for i = 1 : length(c_in)
	
	% universe of discorse
	UoD(i,:) = [-1 1];
	
end


% ------------------------------------------------------
% Fuzzification of the inputs

% Calculate the values of each input membership function
for i = 1 : length(c_in)
	
	% normal equation doesn't work for c_in(i) == UoD(i,2)
	if c_in(i) == UoD(i,2)
		mFcns_act(i,:) = [n_mFcns(i)-1 n_mFcns(i)];
		mFcns_val(i,:) = [0 1];
	else
		
		% Temp calculation (used below)
		temp = ((c_in(i) - UoD(i,1)) * (n_mFcns(i)-1)) / (UoD(i,2) - UoD(i,1));
		
		% Calculate the active membership functions
		mFcns_act(i,:) = [floor(temp)+1 floor(temp)+2];
		
		% Calculate the value of the active membership functions
		mFcns_val(i,:) = [mFcns_act(i,1)-temp 1-(mFcns_act(i,1)-temp)];
	end
	
	if debugging
		disp(['Debugging (', mfilename, '): Input ', num2str(i), ...
				' = ', num2str(c_in(i)), '; which has ', num2str(n_mFcns(i)), ...
				' membership functions.']);
		disp(['Debugging (', mfilename, '): Input ', num2str(i), ...
				' mFcns[', num2str(mFcns_act(i,:)), '] = ', num2str(mFcns_val(i,:))]);
		disp([' ']);
	end
end

if plot_input_tracking % only works for one thread of this at once!
	% plot input membership functions
	fig_h = findobj('name', 'Fuzzy Input Tracking');
	if isempty(fig_h)
		
		for i = 1 : length(c_in)
			BenPlot([1 length(c_in)], [1 i 1 1], 0, 1);
			axis([UoD(i,1)-0.1*(UoD(i,2)-UoD(i,1)) UoD(i,2)+0.1*(UoD(i,2)-UoD(i,1)) -0.1 1.1]);
			hold on;
			
			% calculate the width of each membership function
			mFcn_width = (UoD(i,2)-UoD(i,1))/(n_mFcns(i)-1);
			
			% get the center of each membership function
			mFcn_mid_pt = [UoD(i,1) : mFcn_width : UoD(i,2)];
			
			% draw each membership function (2 lines each)
			y_pt = get(gca, 'YLim');
			for j = 2 : n_mFcns(i)-1
				% draw mid membership functions
				line([mFcn_mid_pt(j)-mFcn_width mFcn_mid_pt(j)], [y_pt(1) y_pt(2)], 'Color', 'k');
				line([mFcn_mid_pt(j) mFcn_mid_pt(j)+mFcn_width], [y_pt(2) y_pt(1)], 'Color', 'k');
			end
			% draw the end membership functions
			line([mFcn_mid_pt(1)-mFcn_width mFcn_mid_pt(1)], [y_pt(2) y_pt(2)], 'Color', 'k');
			line([mFcn_mid_pt(1) mFcn_mid_pt(1)+mFcn_width], [y_pt(2) y_pt(1)], 'Color', 'k');
			line([mFcn_mid_pt(end)-mFcn_width mFcn_mid_pt(end)], [y_pt(1) y_pt(2)], 'Color', 'k');
			line([mFcn_mid_pt(end) mFcn_mid_pt(end)+mFcn_width], [y_pt(2) y_pt(2)], 'Color', 'k');
			
			BenTitle('Fuzzified Inputs');
			
			% draw the input
			in_h = line([c_in(i); c_in(i)], [y_pt(1) y_pt(2)], 'Color', 'r');
			
			% save handles of input lines
			UD = get(gca, 'UserData');
			UD.FuzzyInput_h = in_h;
			set(gca, 'UserData', UD);
		end
		
		set(gcf, 'name', 'Fuzzy Input Tracking');
		
	else
		% get the right plot to be the active plot
		figure(fig_h);
		
		% go through each axes to update each input line
		UD_fig = get(gcf, 'UserData');
		for i = 1 : length(UD_fig.Handle_List)
			
			% use the right axes
			axes(UD_fig.Handle_List(i));
			
			% clear old input lines
			UD = get(UD_fig.Handle_List(i), 'UserData');
			in_h = UD.FuzzyInput_h;
			delete(in_h);
			
			% draw new input lines
			y_pt = get(UD_fig.Handle_List(i), 'YLim');
			in_h = line([c_in(i); c_in(i)], [y_pt(1) y_pt(2)], 'Color', 'r');
			
			% change the title of each axes
			title(['Fuzzy Input ', num2str(i), ' = ', num2str(c_in(i)), '; Activated mFcns[', ...
					num2str(mFcns_act(i,:)), '] = [', num2str(mFcns_val(i,:)), ']']);
			
			% save handles of input lines
			UD = get(UD_fig.Handle_List(i), 'UserData');
			UD.FuzzyInput_h = in_h;
			set(UD_fig.Handle_List(i), 'UserData', UD);
			
		end
	end
end


% ------------------------------------------------------
% Calculation of premise membership using the minimum operation

% initialise a premise counter
prem_c = 0;

% initialise a premise bit counter
prem_bc = zeros(1, length(c_in)+1);

while (prem_bc(end) == 0)
	
	% update the premise counter
	prem_c = prem_c + 1;
	
	% calculate premise list of active membership functions
	% and premise value (using min operator)
	temp_mFcns_list = [];
	temp_mFcns_min = 1;
	for j = 1 : length(c_in)
		temp_mFcns_list = [temp_mFcns_list mFcns_act(j,prem_bc(j)+1)];
		temp_mFcns_min = min([temp_mFcns_min mFcns_val(j,prem_bc(j)+1)]);
	end
	prem(prem_c).mFcns = temp_mFcns_list;
	prem(prem_c).value = temp_mFcns_min;
	
	if debugging
		disp(['Debugging (', mfilename, '): prem(', num2str(prem_c), ').mFcns = [', ...
				num2str(prem(prem_c).mFcns), '] => prem.value = ', ...
				num2str(prem(prem_c).value)]);
	end
	
	% update premise bit counter
	j = 1;
	while prem_bc(j) == 1
		prem_bc(j) = 0;
		j = j + 1;
	end
	prem_bc(j) = 1;
	
end

if debugging
	disp([' ']);
end


% ------------------------------------------------------
% Defuzzification using minimum implied fuzzy sets and
% Centre of Gravity (CoG) method

% initialise the GoG numerator and denominator
CoG_n = 0;
CoG_d = 0;

% sum the GoG numerator and denominator
for i = 1 : length(prem)
	
	% first change the active membership function list into a
	% string of comma seperated number characters
	temp_idx_str = [num2str(prem(i).mFcns(1))];
	for j = 2 : length(prem(i).mFcns(:))
		temp_idx_str = [temp_idx_str, ', ', num2str(prem(i).mFcns(j))];
	end
	
	% get the value of the element in the b matrix
	%disp(['Debugging (', mfilename, '): Value of temp_idx_str = (', temp_idx_str, ')']);
	eval(['temp_b_center = b(', temp_idx_str, ');']);
	
	temp_wght = b_width * (prem(i).value - ((prem(i).value^2) / 2));
	CoG_n = CoG_n + (temp_b_center * temp_wght);
	CoG_d = CoG_d + temp_wght;
end

GoG = CoG_n / CoG_d;


% ------------------------------------------------------
% Set the outputs

if nargout > 0
	out = GoG;
else
	help fuzzy_controller_ben
end

if nargout > 1
	prem_data = prem;
end


% ------------------------------------------------------
% End of File