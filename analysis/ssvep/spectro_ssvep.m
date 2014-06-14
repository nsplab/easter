
fs = 9600;
windlengthSeconds = 4;
windlength = windlengthSeconds * fs;
noverlapPercent = 0.95;%windlength * 0.25;
noverlap = windlength * noverlapPercent;


for i=1:size(data,1)

    [S,F,T,P] = spectrogram(data{i,2},blackmanharris(windlength),noverlap,windlength,fs);
    %[S,F,T,P] = spectrogram(dataExp{i,2},blackmanharris(windlength),noverlap,windlength,fs);
    %[Sc,Fc,Tc,Pc] = spectrogram(dataCtr{i,2},blackmanharris(windlength),noverlap,windlength,fs);
    
    diffPower = log10(P);% - log10(Pc);
    %diffPower = log10(P) - log10(Pc);
    %diffPower(diffPower<0) = 0.00001;
    
    
    figure('Color',[1 1 1],'units','normalized','outerposition',[0 0 1 1]);
    surf(T,F,diffPower,'edgecolor','none');
    axis tight, view(0,90);
    xlabel 'Time (s)', ylabel 'Frequency (Hz)', title(data{i,1});
    ylim([0 180]);
    
end
