%data_folder = '/home/leon/Data/Characterization';
close all
clear
readdata
figure
ntp=size(channel_1,1);
fs=19200
time=1/fs*(1:ntp);
plot(time,(channel_1/1000000))
figure
plot(time,((channel_2)/1000000))
%window = 512
%figure
% [S,F,T,P] = spectrogram(double(channel_1), hann(window), window/2, window, fs);
% surf(T,F,10*log10(P),'edgecolor','none'); axis tight;
% view(0,90);
% figure
% [S,F,T,P] = spectrogram(double(channel_2), hann(window), window/2, window, fs);
% surf(T,F,10*log10(P),'edgecolor','none'); axis tight;
% view(0,90);