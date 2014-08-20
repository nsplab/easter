function pl = plot_psd(data, fs, color)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

N = length(data);
xdft = fft(data);
xdft = xdft(1:N/2+1);
psdx = (1/(fs*N)).*abs(xdft).^2;
psdx(2:end-1) = 2*psdx(2:end-1);
freq = 0:fs/length(data):fs/2;
pl = plot(freq,log10(psdx), color); grid on;
title('Periodogram Using FFT');
xlabel('Frequency (Hz)'); ylabel('Power/Frequency (dB/Hz)');


end

