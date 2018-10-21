function [y] = downmix(fc,Rx_Matrix,t,fir)
I_channel=Rx_Matrix.*cos(2*pi*fc*t);
I_filtered = filter(fir, 1, I_channel,[],2);
Q_channel=Rx_Matrix.*-sin(2*pi*fc*t);
Q_filtered = filter(fir, 1, Q_channel,[],2);
y = I_filtered+j*Q_filtered;
end

