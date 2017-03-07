close all

%b=0;

prompt={'Enter the mass applied in Kg','Applied to Right or Left Pedal? (R=1, L=2)'};
name='Check Piezo Transducers';
numlines=1;
defaultanswer={'1','1'};
answer=inputdlg(prompt,name,numlines,defaultanswer);

Wt = str2num(char(answer(1)));
RL = str2num(char(answer(2)));

delay = 500;

R_fz_diff = diff(squeeze(R_fz.signals.values));
L_fz_diff = diff(squeeze(L_fz.signals.values));

R_fy_diff = diff(squeeze(R_fy.signals.values));
L_fy_diff = diff(squeeze(L_fy.signals.values));

R_fx_diff = diff(squeeze(R_fx.signals.values));
L_fx_diff = diff(squeeze(L_fx.signals.values));

if Wt>0        
    if RL == 1  
        [Z_maxdiff,Z_ApI] =max(R_fz_diff(delay:end-500));
        [Y_maxdiff,Y_ApI] =max(R_fy_diff(delay:end-500));
        [X_maxdiff,X_ApI] =max(R_fx_diff(delay:end-500));

    elseif RL == 2
        [Z_maxdiff,Z_ApI] =max(L_fz_diff(delay:end-500));
        [Y_maxdiff,Y_ApI] =max(L_fy_diff(delay:end-500));
        [X_maxdiff,X_ApI] =max(L_fx_diff(delay:end-500));
    end  
    
    [XYZ_max,AxisI] = max([Z_maxdiff,Y_maxdiff,X_maxdiff]);
else
    if RL == 1  
        [Z_mindiff,Z_ApI] =min(R_fz_diff(delay:end-500));
        [Y_mindiff,Y_ApI] =min(R_fy_diff(delay:end-500));
        [X_mindiff,X_ApI] =min(R_fx_diff(delay:end-500));
    elseif RL == 2
        [Z_mindiff,Z_ApI] =min(L_fz_diff(delay:end-500));
        [Y_mindiff,Y_ApI] =min(L_fy_diff(delay:end-500));
        [X_mindiff,X_ApI] =min(L_fx_diff(delay:end-500));
    end
        [XYZ_min,AxisI] = min([Z_mindiff,Y_mindiff,X_mindiff]);
end

ApIs = [Z_ApI,Y_ApI,X_ApI];

ApI = delay + ApIs(AxisI);

Indx_range = ApI+150:ApI+580;

if RL == 1 
    a = a+1
    MF_Raw_Rxyz(a,:) = [Wt,mean([squeeze(R_fx_raw.signals.values(:,:,Indx_range)),squeeze(R_fy_raw.signals.values(:,:,Indx_range)),squeeze(R_fz_raw.signals.values(:,:,Indx_range))])];
    MF_Rxyz(a,:)     = [Wt,mean([squeeze(R_fx.signals.values(:,:,Indx_range)),squeeze(R_fy.signals.values(:,:,Indx_range)),squeeze(R_fz.signals.values(:,:,Indx_range))])];
    save PedPiezoCheck_21Sept2011 MF_Raw_Rxyz MF_Rxyz

elseif RL == 2 
    b = b+1
    MF_Raw_Lxyz(b,:) = [Wt,mean([squeeze(L_fx_raw.signals.values(:,:,Indx_range)),squeeze(L_fy_raw.signals.values(:,:,Indx_range)),squeeze(L_fz_raw.signals.values(:,:,Indx_range))])];
    MF_Lxyz(b,:)     = [Wt,mean([squeeze(L_fx.signals.values(:,:,Indx_range)),squeeze(L_fy.signals.values(:,:,Indx_range)),squeeze(L_fz.signals.values(:,:,Indx_range))])]; 

    save PedPiezoCheck_21Sept2011 MF_Raw_Lxyz MF_Lxyz
end
    

% save PedPiezoCheck_21Sept2011 MF_Raw_Rxyz MF_Rxyz MF_Raw_Lxyz MF_Lxyz
