function [s1,f1,t,p1] = Spectro()
%%constants
PRI=0.05;
fs=84677;
ts=1/fs;
num_pulses=64;
num_samples= ceil(fs*PRI)*num_pulses;
%% USB VCP with STM32
load('spec_fil.mat');
s = serial('COM4');
s.BaudRate=12e6;
s.InputBufferSize=1000000;
fopen(s);
fprintf(s,'2');
data=fread(s,num_samples*2,'uint8').';
fclose(s);
delete(s);
%% Reconstructing the data from the STM32
data = reshape(data,[2,num_samples]).';
data(:,1) = bitshift(data(:,1),8);
rx = data(:,1)+data(:,2);
rx_pulse_time =(0:ts:(PRI*64));
%% spectrogram
Wo = 12e3/(84677/2);  BW = 60/(84677/2);
[b,a] = iirnotch(Wo,BW); 
rx_filter=filter(b,a,rx);
[s,f,t,p]=spectrogram(rx_filter,hamming(2^13),2^13-20,[],fs,'MinThreshold',-20,'yaxis');
f1= f > 11.5e3 & f<12.5e3;
p1=p(f1,:);
s1=s(f1,:);
f1=f(f1);
end