% sampling rate
fs = 9600;
windlengthSeconds = 2;
windlength = windlengthSeconds * fs;
noverlapPercent = 0.45;%windlength * 0.25;
noverlap = windlength * noverlapPercent;

% ask the user to select the data file
%run('../loaddata.m');

fid = fopen([pathname filename], 'r');
digitalinCh = 65;
fseek(fid, 4*(digitalinCh-1), 'bof');
dataColumn = fread(fid, Inf, 'single', 4*64);
time_axis = (0:length(dataColumn)-1)*1.0/fs;
figure;plot(time_axis,dataColumn);

tmp = (dataColumn>0);
t1 = diff(tmp);
t2 = find(t1==1);
t3 = find(t1==-1);

if isempty(t3)
    t3 = length(dataColumn);
end

cutSecondsBegining = 10;
cutSecondsEnd = 15;

cutLengthB = t2; %fs * cutSecondsBegining;
cutLengthE = length(dataColumn); %fs * cutSecondsEnd;

if strcmp(rabbit_ID, '9rabbit_may_6_2014')
    if isempty(t2),
        t2 = (32 * fs);
    end

    if t2 < (30 * fs),
        t2 = (32 * fs);
    end
    
    cutLengthB = t2; %fs * cutSecondsBegining;
    cutLengthE = 30 * fs + t2; %fs * cutSecondsEnd;
    
    if cutLengthE > length(dataColumn)
        cutLengthE = length(dataColumn);
    end
    
end

channelToPlot = [2,3,5,7,8];
channels_plotted = [];

% choose the colormap for the plots
CM = [hex2dec('e9'), hex2dec('00'), hex2dec('3a');
      hex2dec('ff'), hex2dec('ba'), hex2dec('00'); 
      hex2dec('18'), hex2dec('26'), hex2dec('b0');
      hex2dec('58'), hex2dec('e0'), hex2dec('00');
      hex2dec('00'), hex2dec('00'), hex2dec('00')];
CM = CM/256;

%scalpCh = [8,4,6,7];

% the titles in the legend
legends = [];


dataname = 'SSAEP';

% draw the figure with white background and full screen
fgh = figure('Color',[1 1 1],'units','normalized','outerposition',[0 0 1 1]);
hold on

% compute PSD of all channels and plot the PSD + 95% confidence intervals
for ii=1:length(channelToPlot)
    ii
    
    channels_plotted = [channels_plotted channelToPlot(ii)];
    
    m = [];
    expPSDs = [];
    ctrPSDs = [];

    
    
    for jj=(1+cutLengthB):(windlength - noverlap):((cutLengthE)-windlength)
        
        [lpxx, f] = pwelch(data{channelToPlot(ii),2}(jj:jj+windlength), blackmanharris(length(data{channelToPlot(ii),2}(jj:jj+windlength))), 0, length(data{channelToPlot(ii),2}(jj:jj+windlength)), fs);
        
        %nump = 1000;    
        %f = f(1:nump);
        %lpxx = lpxx(1:nump);
        
        expPSDs(end+1, :) = lpxx;
        
    end
    
    exp_psds{ii} = expPSDs;
    
    for jj=1:(windlength - noverlap):((30*fs))
        
        [lpxxC, f] = pwelch(data{channelToPlot(ii),2}(jj:jj+windlength), blackmanharris(length(data{channelToPlot(ii),2}(jj:jj+windlength))), 0, length(data{channelToPlot(ii),2}(jj:jj+windlength)), fs);
        
        %nump = 1000;    
        %f = f(1:nump);
        %lpxxC = lpxxC(1:nump);
        
        ctrPSDs(end+1, :) = lpxxC;
        
    end
    
    ctr_psds{ii} = ctrPSDs;
    
    %size(expPSDs)
    %size(ctrPSDs)
    
    for iExp=1:size(expPSDs,1)
        for iCtr=1:size(ctrPSDs,1)
            m(end+1,:) = (expPSDs(iExp,:)) - (ctrPSDs(iCtr,:));
            %m(end+1,:) = log10(ctrPSDs(iExp,:));
            %m(end+1,:) = log10(expPSDs(iExp,:));
        end
    end
    
    size(m)
    
    %mod_mean = @(x) mean(x(1:60,:));
    %mod_mean = @(x) mean(x(1:30,:));
    if publication_quality == 1
        mod_mean = @(x) log(mean(x));
        confMeanDiff = bootci(500, {mod_mean, m}, 'alpha', 0.01, 'type', 'per');
        confMeanExp = bootci(500, {mod_mean, expPSDs}, 'alpha', 0.01, 'type', 'per');
        confMeanCtr = bootci(500, {mod_mean, ctrPSDs}, 'alpha', 0.01, 'type', 'per');
    end

    
    px=[f', fliplr(f')];
   
    %{
    [pxx, f] = pwelch(data{channelToPlot(ii),2}((1+cutLengthB):(cutLengthE)), (windlength), noverlap, windlength, fs);
    if (windlength < cutLengthB)
        [pxxC, fC] = pwelch(data{channelToPlot(ii),2}((1):(cutLengthB+1)), (windlength), noverlap, windlength, fs);
    else
        [pxxC, fC] = pwelch(data{channelToPlot(ii),2}((1+cutLengthE):end), (windlength), noverlap, windlength, fs);
    end
    %}
    %[pxx, f, pxxc] = pwelch(dataExp{scalpCh(i),2}((1+cutLengthB):(end-(cutLengthE))), (windlength), noverlap, windlength, fs, 'ConfidenceLevel', 0.95);
    %[pxxC, fC, pxxcC] = pwelch(dataCtr{scalpCh(i),2}((1+cutLengthB):(end-(cutLengthE))), (windlength), noverlap, windlength, fs, 'ConfidenceLevel', 0.95);
    
    %{
    nump = 10000;    
    f = f(1:nump);
    fC = fC(1:nump);
    pxx = pxx(1:nump);
    pxxC = pxxC(1:nump);
    %}

    pxx = log(mean(expPSDs));
    pxxC = log(mean(ctrPSDs));
    
    diffPow = (pxx) - (pxxC);
    %diffPower(diffPower<0) = 0.00001;
    
    subplot(3,1,1);hold on;
    legends(end+1) = plot(f, (pxx),'color',CM(ii,:),'linewidth',3);
    
    if publication_quality == 1
        py = [confMeanExp(1,:),  fliplr(confMeanExp(2,:))];
        patch(px,py,1,'FaceColor',CM(ii,:),'EdgeColor','none');
        alpha(.4);
    end
    axis tight
    
    subplot(3,1,2);hold on;
    plot(f, (pxxC),'color',CM(ii,:),'linewidth',3);
    
    if publication_quality == 1
        py = [confMeanCtr(1,:),  fliplr(confMeanCtr(2,:))];
        patch(px,py,1,'FaceColor',CM(ii,:),'EdgeColor','none');
        alpha(.4);
    end
    axis tight
    
    subplot(3,1,3);hold on;
    plot(f, diffPow,'color',CM(ii,:),'linewidth',3);
    
    if publication_quality == 1
        py = [confMeanDiff(1,:),  fliplr(confMeanDiff(2,:))];
        patch(px,py,1,'FaceColor',CM(ii,:),'EdgeColor','none');
        alpha(.4);
    end
    axis tight
    
end

ssaep_data{i,3} = exp_psds;
ssaep_data{i,4} = ctr_psds;
ssaep_data{i,5} = f;
ssaep_data{i,6} = {data{channels_plotted,1}};

tmpCmt = allData{1}(i);
subplot(3,1,1);hold on;
harmonics = [];
if ~isempty(strfind(tmpCmt{1}(9:25), '12'))
    for h=1:floor(f(end)/12)
        %harmonics = [harmonics (h*9.8000)];
        plot([(h*12) (h*12)], ylim,'Color',[0 0 0]+0.6,'linewidth',1)
    end
end
if ~isempty(strfind(tmpCmt{1}(9:25), '42'))
    for h=1:floor(f(end)/42)
        %harmonics = [harmonics (h*40.8333)];
        plot([(h*42) (h*42)], ylim,'Color',[0 0 0]+0.6,'linewidth',1)
    end
end
if ~isempty(strfind(tmpCmt{1}(9:25), '86'))
    for h=1:floor(f(end)/86)
        %harmonics = [harmonics (h*54.4444)];
        plot([(h*86) (h*86)], ylim,'Color',[0 0 0]+0.6,'linewidth',1)
    end
end

%set(gca,'XTick', harmonics);

subplot(3,1,2);hold on;
%set(gca,'XTick', harmonics);
if ~isempty(strfind(tmpCmt{1}(9:25), '12'))
    for h=1:floor(f(end)/12)
        %harmonics = [harmonics (h*9.8000)];
        plot([(h*12) (h*12)], ylim,'Color',[0 0 0]+0.6,'linewidth',1)
    end
end
if ~isempty(strfind(tmpCmt{1}(9:25), '42'))
    for h=1:floor(f(end)/42)
        %harmonics = [harmonics (h*40.8333)];
        plot([(h*42) (h*42)], ylim,'Color',[0 0 0]+0.6,'linewidth',1)
    end
end
if ~isempty(strfind(tmpCmt{1}(9:25), '86'))
    for h=1:floor(f(end)/86)
        %harmonics = [harmonics (h*54.4444)];
        plot([(h*86) (h*86)], ylim,'Color',[0 0 0]+0.6,'linewidth',1)
    end
end

subplot(3,1,3);hold on;
%set(gca,'XTick', harmonics);
if ~isempty(strfind(tmpCmt{1}(9:25), '12'))
    for h=1:floor(f(end)/12)
        %harmonics = [harmonics (h*9.8000)];
        plot([(h*12) (h*12)], ylim,'Color',[0 0 0]+0.6,'linewidth',1)
    end
end
if ~isempty(strfind(tmpCmt{1}(9:25), '42'))
    for h=1:floor(f(end)/42)
        %harmonics = [harmonics (h*40.8333)];
        plot([(h*42) (h*42)], ylim,'Color',[0 0 0]+0.6,'linewidth',1)
    end
end
if ~isempty(strfind(tmpCmt{1}(9:25), '86'))
    for h=1:floor(f(end)/86)
        %harmonics = [harmonics (h*54.4444)];
        plot([(h*86) (h*86)], ylim,'Color',[0 0 0]+0.6,'linewidth',1)
    end
end


% add the legend
subplot(3,1,1);
legend(legends, data{channels_plotted,1})

%legend(legends, {'left eye','right eye', 'middle head', 'back head'});

% put a tick every 10 Hz
%tmp = get(gca,'xlim');
%set(gca,'XTick',[0:10:tmp(2)]);

% set labels and grid
subplot(3,1,1);
xlabel('frequency (Hz)');
ylabel('experiment: ${log}_{10} (\mu V^2/{Hz})$','Interpreter','LaTex');
%tmp = title(['Experiment PSD: ' dataname  '_' filename ' |  window length (secs)=' int2str(windlengthSeconds) '  overlap=' num2str(noverlapPercent)]);
%set(tmp,'interpreter','none');
%grid on
%grid minor
%ylim([-7 6]);

subplot(3,1,2);
xlabel('frequency (Hz)');
ylabel('baseline: ${log}_{10} (\mu V^2/{Hz})$','Interpreter','LaTex');
set(gca, 'TickDir', 'out')

subplot(3,1,3);
xlabel('frequency (Hz)');
ylabel('${log}_{10} (\mu V^2/{Hz} $exp$) - {log}_{10} (\mu V^2/{Hz} $base$)$','Interpreter','LaTex');
set(gca, 'TickDir', 'out')

subplot(3,1,1);
tmp = title(['SSAEP: '  allData{1}(i)]);
set(tmp,'interpreter','none');
set(gca, 'TickDir', 'out')

%saveas(fgh, ['matlab_data/' S{i} '.fig']);

