clc, close all

[B,A] = butter(2,0.01);
PowerFilt_a= filtfilt(B, A, Power);

[maxPwr, I_maxP]  = max(PowerFilt_a(1:end - 100));
maxPwr_text = num2str(maxPwr);

figure
subplot(2,1,1)
plot(vel_rpm), ylabel('Velocity(rpm)'), xlabel('Index'), grid on
subplot(2,1,2)
plot(1:length(PowerFilt_a),PowerFilt_a,I_maxP,maxPwr, 'go'),...
    ylabel('Power(W)'), xlabel('Index'), grid on, text(I_maxP,maxPwr-20,maxPwr_text)


[B,A] = butter(2,0.01);
PowerFilt= filtfilt(B, A, Power);

[maxPwr, I_maxP]  = max(PowerFilt(1:end - 100));
maxPwr_text = num2str(maxPwr);

figure
subplot(2,1,1)
plot(sim_time,vel_rpm), ylabel('Velocity(rpm)'), xlabel('Time(s)'), grid on
subplot(2,1,2)
plot(sim_time,PowerFilt,sim_time(I_maxP),maxPwr, 'go'),...
    ylabel('Power(W)'), xlabel('Time(s)'), grid on, text(sim_time(I_maxP),maxPwr-20,maxPwr_text)

Baseline = mean(Power(end-120:end-50));
Pwr_minBase = Power-Baseline;
[B,A] = butter(2,0.01);
PowerFilt_mBase= filtfilt(B, A, Pwr_minBase);

[maxPwr_mBase, I_maxP]  = max(PowerFilt_mBase(1:end - 100));
maxPwr_mBase_text = num2str(maxPwr_mBase);

figure
subplot(2,1,1)
plot(sim_time,vel_rpm), ylabel('Velocity(rpm)'), xlabel('Time(s)'), grid on
subplot(2,1,2)
plot(sim_time,PowerFilt_mBase,sim_time(I_maxP),maxPwr_mBase, 'ro'),...
    ylabel('Power(W)'), xlabel('Time(s)'), grid on, text(sim_time(I_maxP),maxPwr_mBase-20,maxPwr_mBase_text)


Power_CalcFromTorq = Torque.*vel_rpm.*pi/30;
Baseline = mean(Power_CalcFromTorq(end-120:end-50));
Pwr_FrTorq_mBase = Power_CalcFromTorq-Baseline;
[B,A] = butter(2,0.01);
PowerFilt_FrmTorq_mBase= filtfilt(B, A, Pwr_FrTorq_mBase);

[maxPwr_FrmTorq_mBase, I_FrmTorq_maxP]  = max(PowerFilt_FrmTorq_mBase(1:end - 100));
maxPwr_FrmTorq_mBase_text = num2str(maxPwr_FrmTorq_mBase);

figure
subplot(2,1,1)
plot(sim_time,Torque), ylabel('Torque(N-m)'), xlabel('Time(s)'), grid on

subplot(2,1,2)
plot(sim_time,PowerFilt_FrmTorq_mBase,sim_time(I_FrmTorq_maxP),maxPwr_FrmTorq_mBase, 'ro'),...
    ylabel('Power(W)'), xlabel('Time(s)'), grid on,...
    text(sim_time(I_FrmTorq_maxP),maxPwr_FrmTorq_mBase-20,maxPwr_FrmTorq_mBase_text),...
    title('Power calculated from Torque')

