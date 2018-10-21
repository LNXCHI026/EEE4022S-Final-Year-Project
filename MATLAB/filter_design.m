%% butterworth filter design
fc=13e3;
r1=10e3;
c=0.01e-6;
k1=0.1592;
k2=0.586;
r=k1/(c*fc);
rf=r1*k2;
s=sprintf('r: %f, rf: %f \n',r,rf);
disp(s);

%% Db calculation
fc=12e3;
fs=160e3;
f=fs-fc;
%2^12-1 is max DAC value  zoh func
dB=20*log10(2^12-1)+20*log10((abs(sinc(f/(fs/2)))));
disp(dB);