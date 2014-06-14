% sampling rate
fs = 4800;
windlengthSeconds = 2;
windlength = windlengthSeconds * fs;
noverlapPercent = 0.0;
noverlap = windlength * noverlapPercent;

% seconds of data to be discarded from the beginning of the data
% as usualy there are some artifact at the beginning discarding 2 or 3
% seconds of the data is suggested
cutSecondsBegining = 0;
cutSecondsEnd = 10;

cutLengthB = fs * cutSecondsBegining;
cutLengthE = fs * cutSecondsEnd;

data = dataExp;

% choose the colormap for the plots
CM = [hex2dec('e9'), hex2dec('00'), hex2dec('3a'); hex2dec('ff'), hex2dec('ba'),hex2dec('00'); hex2dec('18'),hex2dec('26'),hex2dec('b0'); hex2dec('58'),hex2dec('e0'), hex2dec('00')];
CM = CM/330;

% the titles in the legend
legends = [];

dataname = 'SSVEP';

% channels on scalp
scalpCh = [8,9,6,4];

% draw the figure with white background and full screen
figure('Color',[1 1 1],'units','normalized','outerposition',[0 0 1 1]);
hold on

expPSDs = [];
ctrPSDs = [];

% compute PSD of all channels and plot the PSD + 95% confidence intervals
for i=1:length(scalpCh)
    i

    m = [];
    expPSDs = [];
    ctrPSDs = [];

    for j=1:(windlength - noverlap):(length(dataExp{scalpCh(i),2})-windlength - cutSecondsEnd * fs)
        
        [lpxx, f] = pwelch(dataExp{scalpCh(i),2}(j:j+windlength), blackmanharris(length(dataExp{scalpCh(i),2}(j:j+windlength))), 0, length(dataExp{scalpCh(i),2}(j:j+windlength)), fs);
        
        nump = 1000;    
        f = f(1:nump);
        lpxx = lpxx(1:nump);
        
        expPSDs(end+1, :) = lpxx;
        
    end
    
    for j=1:(windlength - noverlap):(length(dataCtr{scalpCh(i),2})-windlength - cutSecondsEnd * fs)
        
        [lpxxC, f] = pwelch(dataCtr{scalpCh(i),2}(j:j+windlength), blackmanharris(length(dataCtr{scalpCh(i),2}(j:j+windlength))), 0, length(dataCtr{scalpCh(i),2}(j:j+windlength)), fs);
        
        nump = 1000;    
        f = f(1:nump);
        lpxxC = lpxxC(1:nump);
        
        ctrPSDs(end+1, :) = lpxxC;
        
    end
    
    size(expPSDs)
    size(ctrPSDs)
    
    for iExp=1:size(expPSDs,1)
        for iCtr=1:size(ctrPSDs,1)
            m(end+1,:) = log(expPSDs(iExp,:)) - log(ctrPSDs(iCtr,:));
            %m(end+1,:) = log10(ctrPSDs(iExp,:));
            %m(end+1,:) = log10(expPSDs(iExp,:));
        end
    end
    
    size(m)
    
    %mod_mean = @(x) mean(x(1:60,:));
    %mod_mean = @(x) mean(x(1:30,:));
    mod_mean = @(x) mean(x);
    confMean = bootci(500, {mod_mean, m}, 'alpha', 0.01, 'type', 'per');
    
    px=[f', fliplr(f')];
    py = [confMean(1,:),  fliplr(confMean(2,:))];
    patch(px,py,1,'FaceColor',CM(i,:),'EdgeColor','none');
    
    alpha(.4);
    
    legends(end+1) = plot(f',mean([confMean(1,:); confMean(2,:)]),'color',CM(i,:),'linewidth',3);

    %legends(end+1) = plot(f, log10(pxx),'color',CM(i,:),'linewidth',2);
    %legends(end+1) = plot(f, log10(pxx),'color',CM(i,:),'linewidth',2);
end

% add the legend
%legend(legends, {'left eye','right eye', 'middle head', 'back head'});
legend(legends, {'left eye','right eye', 'right ear', 'left ear'});

% put a tick every 10 Hz
%tmp = get(gca,'xlim');
%set(gca,'XTick',[0:10:tmp(2)]);

% set labels and grid
xlabel('frequency (Hz)');
ylabel('${log}_{10} (\mu V^2/{Hz})$','Interpreter','LaTex');
%tmp = ylabel('Power Ratio (experiment/control)');
%set(tmp,'interpreter','none');
%tmp = title(['Experiment PSD: ' dataname  '_' filenameExp ' |  window length (secs)=' int2str(windlengthSeconds) '  overlap=' num2str(noverlapPercent)]);
%set(tmp,'interpreter','none');
grid on
grid minor
%ylim([-4 12]);
xlim([0 180]);

% save the figure in file
%myaa([3 3], [dataname '_' filename '_experiment_psd.png']);

