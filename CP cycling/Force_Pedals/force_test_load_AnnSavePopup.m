%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% forst_test_load.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This script loads all parameters required by the force_collection test simulink
% model and opens force_collection.mdl


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calibration and General Constants
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%SRM Constants
freq_zero = 116.7756;
freq_range = 466.8;
slope = 14.1374;

f=gcf;

bla=findobj(f,'Style','edit','Tag','zopm');
parameters.srm_conversion.ZOPM = str2double(get(bla,'String'));

bla=findobj(f,'Style','edit','Tag','angleshift');
parameters.angle_shift = str2double(get(bla,'String'));

close(f);
% open('force_collection.mdl');
open('Ann_Pedals_SavePopup.mdl');    %Sue M. changed on 12Dec2011
