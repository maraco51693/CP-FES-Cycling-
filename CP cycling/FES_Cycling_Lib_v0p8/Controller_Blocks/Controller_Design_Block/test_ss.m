% test_ss

clear all; clc;


cd Controllers;
try load SPZ_KJH_04_02_24_motor_1.mat;
catch cd('..'); error(lasterr); return;
end
cd ..

mdl_p = idss(controllerData.ident.id_mdl);

% Rename the plant parameters
Phi_p = mdl_p.A;
Gma_p = mdl_p.B;
C_p   = mdl_p.C;
Ts    = mdl_p.Ts;

a = ss_design_ben(Phi_p, Gma_p, C_p, Ts, [5 0.9], [8 0.8]);

