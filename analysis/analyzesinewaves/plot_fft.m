function pl = plot_fft(data, fs, color)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

N = length(data);
xdft = fft(data);
xdft = xdft(1:N/2+1);
freq = 0:fs/length(data):fs/2;
pl = plot(freq,log(xdft), color); grid on;
title('Periodogram Using FFT');
xlabel('Frequency (Hz)'); ylabel('Log(FFT)');


end