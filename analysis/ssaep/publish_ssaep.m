% sampling rate
fs = 9600;
windlengthSeconds = 2;
windlength = windlengthSeconds * fs;
noverlapPercent = 0.0;
noverlap = windlength * noverlapPercent;

% seconds of data to be discarded from the beginning of the data
% as usualy there are some artifact at the beginning discarding 2 or 3
% seconds of the data is suggested
cutSecondsBegining = 20;
cutSecondsEnd = 20;

cutLengthB = fs * cutSecondsBegining;
cutLengthE = fs * cutSecondsEnd;

data = dataExp;

% choose the colormap for the plots
CM = [hex2dec('e9'), hex2dec('00'), hex2dec('3a'); hex2dec('ff'), hex2dec('ba'),hex2dec('00'); hex2dec('18'),hex2dec('26'),hex2dec('b0'); hex2dec('58'),hex2dec('e0'), hex2dec('00')];
CM = CM/400;

% the titles in the legend
legends = [];

dataname = 'SSVEP';

% channels on scalp
scalpCh = [8,4,6,7];

% draw the figure with white background and full screen
figure('Color',[1 1 1],'units','normalized','outerposition',[0 0 0.9 0.9]);
hold on

x_lines = [11, 22, 33, 44, 55, 60, 120];
y_limits = [-100; 100];
y_grid = repmat(y_limits, 1, numel(x_lines));
x_grid = [x_lines; x_lines];
plot(x_grid, y_grid, ':', 'color', [1,1,1]/2,'linewidth',2); 
%set(gca, 'XTick', listOfTheoreticalValues);

expPSDs = [];
ctrPSDs = [];

% compute PSD of all channels and plot the PSD + 95% confidence intervals
for i=1:length(scalpCh)
    i

    m = [];
    expPSDs = [];
    ctrPSDs = [];

    for j=1:(windlength - noverlap):(length(dataExp{scalpCh(i),2})-windlength)
        
        [lpxx, f] = pwelch(dataExp{scalpCh(i),2}(j:j+windlength), blackmanharris(length(dataExp{scalpCh(i),2}(j:j+windlength))), 0, length(dataExp{scalpCh(i),2}(j:j+windlength)), fs);
        
        nump = 1000;    
        f = f(1:nump);
        lpxx = lpxx(1:nump);
        
        expPSDs(end+1, :) = lpxx;
        
    end
    
    for j=1:(windlength - noverlap):(length(dataCtr{scalpCh(i),2})-windlength)
        
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
            %m(end+1,:) = log10(expPSDs(iExp,:)) - log10(ctrPSDs(iCtr,:));
            %m(end+1,:) = log10(ctrPSDs(iExp,:));
            m(end+1,:) = log10(expPSDs(iExp,:));
        end
    end
    
    size(m)
    
    mod_mean = @(x) mean(x(1:60,:));
    confMean = bootci(500, {mod_mean, m}, 'alpha', 0.01, 'type', 'per');
    
    px=[f', fliplr(f')];
    py = [confMean(1,:),  fliplr(confMean(2,:))];
    patch(px,py,1,'FaceColor',CM(i,:),'EdgeColor','none');
    
    alpha(.3);
    
    legends(end+1) = plot(f',mean([confMean(1,:); confMean(2,:)]),'color',CM(i,:),'linewidth',3);

    %legends(end+1) = plot(f, log10(pxx),'color',CM(i,:),'linewidth',2);
    %legends(end+1) = plot(f, log10(pxx),'color',CM(i,:),'linewidth',2);
end

% add the legend
%legend(legends, {'left eye','right eye', 'middle head', 'back head'}, 'Location', 'SouthOutside');
legend(legends, {'left eye','right eye', 'middle head', 'back head'}, 'Location', 'NorthOutside', 'Orientation' , 'horizontal');

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
%grid on
%grid minor

%ylim([-4 12]);
%xlim([0 180]);

ylim([-0.66 0.66]);
ylim([-0.7 0.7]);

uistack(legends, 'top');

outerpos = [-0.0047    0.4008    1.0094    0.5833];
set(gcf,'OuterPosition', outerpos);

% save the figure in file
%myaa([3 3], [dataname '_' filename '_experiment_psd.png']);

