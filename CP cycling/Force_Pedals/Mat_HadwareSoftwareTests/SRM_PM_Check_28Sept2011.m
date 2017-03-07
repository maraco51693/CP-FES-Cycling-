close all

prompt={'Enter the mass applied in Kg','Enter frequency from Powercontrol IV',...
    'Applied to Right or Left Pedal? (R=1, L=2)'};
name='Check SRM PowerMeter';
numlines=1;
defaultanswer={'1','420','1'};
answer=inputdlg(prompt,name,numlines,defaultanswer);

Wt   = str2num(char(answer(1)));
freq = str2num(char(answer(2)));
RL   = str2num(char(answer(3)));

if RL == 1
    a = a+1
    n = a
elseif RL == 2
    b = b+1
    n = b
end

if (a==1  && b==0) || (a==0 && b==1)
    Mass_srmVolts = NaN(7,4,2);
%     srmPM_raw = NaN(7,2);
%     Mass      = NaN(7,2);
%     fp        = NaN(7,2);
%     Torq_srm  = NaN(7,2);
end

Mass= Wt;
fp  = freq

[srmPM_raw,srmMax_I] =  max(raw_srm.signals.values);

Torq_srm = torque.signals.values(srmMax_I);

Temp = 22.5;     %Temperature (deg C); 21.5 deg C on PowerControl
Humid = 35;      %Relative Humidity (%)
Press = 1011;    %Air Pressure (HPa)

if RL == 1
    Mass_srmVolts_R(n,:) = [Mass,fp,srmPM_raw,Torq_srm];
elseif RL == 2
    Mass_srmVolts_L(n,:) = [Mass,fp,srmPM_raw,Torq_srm];

end

THP = [Temp;Humid;Press];

% range = 1:n-2;

% LinFit_R = polyfit(Mass(range,1),srmPM_raw(range,1),1)
% mod_R = polyval(LinFit_R,Mass(range,1));
% 
% figure
%  subplot(2,1,1)
% plot(Mass_srmVolts(range,1),Mass_srmVolts(range,2),'*',Mass_srmVolts(range,1),mod_R,'r'),...
%     xlabel('Mass (Kg)'),ylabel('PM Volts (V)'),title('Right Force Pedal'), grid on


%save srmPMCheck_28Sept2011_v7 Mass_srmVolts_R Mass_srmVolts_L THP

if n>3
    if RL == 1
        Mass_srmVolts = Mass_srmVolts_R;
    elseif RL == 2
        Mass_srmVolts = Mass_srmVolts_L;
    end
%     for m = 1:2
        M_calc  = Mass_srmVolts(:,1);
        fp_calc = Mass_srmVolts(:,2);
        V_calc  = Mass_srmVolts(:,3);
        T_SimOut = Mass_srmVolts(:,4);
        
        V_calc = V_calc/5;   %Normalize voltage to 5 V_calc;

        ZOPM_I = M_calc==0;
        ZOPM_calc   = nanmean(fp_calc(ZOPM_I));
        
        g = 9.807;     %acceleration due to gravity
        r = 0.134;     %radius from axis of rotation of crank to attachment of pedal to crank
        
        T_calc = M_calc*g*r
        
        slope_calc     = (fp_calc(~ZOPM_I)-ZOPM_calc)./(T_calc(~ZOPM_I))
        slope_avg = nanmean(slope_calc)

        V0_calc = nanmean(V_calc(ZOPM_I));

%         fr = (T_calc(~ZOPM_I).*slope_calc)./(V_calc(~ZOPM_I)-V0_calc)
        fr_calc = (fp_calc(~ZOPM_I)-ZOPM_calc)./(V_calc(~ZOPM_I)-V0_calc)
        fr_avg = nanmean(fr_calc)

        f0_calc = ZOPM_calc - (V0_calc*fr_calc)
        f0_avg = nanmean(f0_calc)
%     end
end