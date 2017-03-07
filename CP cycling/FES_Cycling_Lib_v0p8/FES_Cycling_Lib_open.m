function FES_Cycling_Lib_open(flag)
% FES_Cycling_Lib_open Opens the Simulink Block Libirary
%   This file will also add any requred sub-directories to the
%   matlab path.

% Benjamin Saunders
% 20 July 2006

% Debugging:
%disp(['Debugging (',mfilename,'): Running!']);


switch flag
    case 0 % Initialisation of the block library
        initLib;
    case 1 % Opening of the Library
        openLib;
    otherwise
        disp(['Warning (', mfilename, '): Unknown input flag!']);
end


% ===============================================================
function initLib()

% Debugging:
%disp(['Debugging (',mfilename,'): Updating path.']);

% Get the path of this file and use this as the root for the
% Simulink libirary
file_path = mfilename('fullpath');
[p n e v] = fileparts(file_path);

% add all the directories under the one this file is in to the
% matlab search path (including the path itself).
addpath(genpath(p));


% ===============================================================
function openLib()

% Open the simulink model
open_system('Hasomed_Lib.mdl');


