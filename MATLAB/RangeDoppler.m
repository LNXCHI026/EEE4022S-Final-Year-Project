function [RangeAxis,VelocityAxis,Rangedoppler_abs1,Rangedoppler_abs2]=RangeDoppler()
%%constants
pause(2);
PRI=0.05;
PRF=1/PRI;
c=340;
fc=10e3;
lamda = c/fc;
fs=84677;
f0=8e3;
f1=12e3;
ts=1/fs;
T=0.025;
num_pulses=64;
num_samples= ceil(fs*PRI)*num_pulses;
%% generating tx pulse
tx_pulse_time =(0:ts:T);
tx_pulse=round(chirp(tx_pulse_time,f0,tx_pulse_time(end),f1)*2000+2047);
%% USB VCP with STM32
load('fir.mat');
s = serial('COM4');
s.BaudRate=12e6;
s.InputBufferSize=1000000;
fopen(s);
fprintf(s,'1');
data=fread(s,num_samples*2,'uint8').';
fclose(s);
delete(s);
%% Reconstructing the data from the STM32
data = reshape(data,[2,num_samples]).';
data(:,1) = bitshift(data(:,1),8);
rx = data(:,1)+data(:,2);
N=length(rx);
rx_matrix = reshape(rx, round(N/num_pulses), num_pulses).';
rx_pulse_time =(0:ts:(PRI));
%% down mixing
tx_base = downmix(fc,tx_pulse,tx_pulse_time,down_fir);
rx_base = downmix(fc,rx_matrix,rx_pulse_time,down_fir);
%% matched filtering and range doppler
mf = matchfilter(tx_base,rx_base,fs,PRI,T);
m = max(mf(32,:));
[rowsOfMaxes colsOfMaxes] = find(mf == m);
mf=circshift(mf,-colsOfMaxes,2);
RangeAxis = rx_pulse_time*c/2;
slow_filter=[1 -2 1];
mf_no_clutter=filter(slow_filter, 1, mf,[],1);
C=repmat(hamming(size(mf,1)),1,size(mf,2));
Rangedoppler1=circshift(fft(C.*mf,[],1),31);
Rangedoppler2=circshift(fft(C.*mf_no_clutter,[],1),31);
Rangedoppler_abs1=20*log10(abs(Rangedoppler1));
Rangedoppler_abs2=20*log10(abs(Rangedoppler2));
VelocityAxis = ((-1/2):1/num_pulses:1/2-1/num_pulses)*PRF*lamda/2*100;
% clims=[max(Rangedoppler_abs1(:))-30 max(Rangedoppler_abs1(:))];
% figure(1);imagesc(RangeAxis,VelocityAxis,Rangedoppler_abs1,clims);colorbar;colormap('jet');
% ylabel('Velocity (cm/s)');
% xlabel('Range (m)');
