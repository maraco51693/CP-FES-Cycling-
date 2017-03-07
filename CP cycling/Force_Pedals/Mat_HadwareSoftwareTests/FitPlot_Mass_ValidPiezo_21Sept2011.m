close all

MF_R_sort = sort(MF_Rxyz,1);

MF_L_sort = sort(MF_Lxyz,1);

LinFit_R = polyfit(MF_Rxyz(:,1),MF_Rxyz(:,4),1)
mod_R = polyval(LinFit_R,MF_Rxyz(:,1));

LinFit_L = polyfit(MF_Lxyz(:,1),MF_Lxyz(:,4),1)
mod_L = polyval(LinFit_L,MF_Lxyz(:,1));


figure

subplot(2,1,1)
plot(MF_Rxyz(:,1),MF_Rxyz(:,4),'*',MF_Rxyz(:,1),mod_R,'r'),...
    xlabel('Mass (Kg)'),ylabel('Force (N)'),title('Right Force Pedal'), grid on

subplot(2,1,2)
plot(MF_Lxyz(:,1),MF_Lxyz(:,4),'*',MF_Lxyz(:,1),mod_L,'r'),...
    xlabel('Mass (Kg)'),ylabel('Force (N)'),title('Left Force Pedal'), grid on



