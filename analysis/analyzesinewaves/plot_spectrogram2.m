function plot_spectrogram2( data, window, fs )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
figure
[S,F,T,P] = spectrogram(double(data), hann(window), window/2, window, fs);
surf(T,F,10*log10(P),'edgecolor','none'); axis tight;
title('Spectrogram, Channel 2');
view(0,90);

end

