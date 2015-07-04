% sampling rate
fs = 9600;
windlengthSeconds = 2;
windlength = windlengthSeconds * fs;
noverlapPercent = 0.25;%windlength * 0.25; % number overlap percent
noverlap = windlength * noverlapPercent; % number overlap (timesteps)

% ask the user to select the data file
%run('../loaddata.m');

time_axis = (0:length(dataColumnDig)-1)*1.0/fs;
%figure;plot(time_axis,dataColumnDig);

tmp = (dataColumnDig>0); % true when experiment is on, false when off
t1 = diff(tmp); % -1: experiment turns off, 0: no change, 1: experiment turns on
t2 = find(t1==1); % first time when led turns on (experiment starts)
t3 = find(t1==-1); % last time when led turns off (experiment ends)

if isempty(t3)
    t3 = length(dataColumnDig);
end

cutSecondsBegining = 10;
cutSecondsEnd = 15;

cutLengthB = t2; %fs * cutSecondsBegining;
cutLengthE = t3; %fs * cutSecondsEnd;

assert(numel(cutLengthB) == 1);
assert(numel(cutLengthE) == 1);

assert(cutLengthB < cutLengthE);

%channelToPlot = [1,4,2,3,5,7,8];
channelToPlot = [2,3,5,7,8];
channels_plotted = [];

hp = fdesign.highpass('Fst,Fp,Ast,Ap',(2.0),(10.0),90,1,fs);             %highpass filter; passband 90 Hz, stopband 105 Hz, 1dB passband ripple, 90 dB stopband attenuation, sampling frequency fs, butterworth 
hpf = design(hp, 'butter');

% choose the colormap for the plots
%CM = [hex2dec('00'), hex2dec('00'), hex2dec('00');
%      hex2dec('00'), hex2dec('00'), hex2dec('00');
%      hex2dec('e9'), hex2dec('00'), hex2dec('3a');
%      hex2dec('ff'), hex2dec('ba'), hex2dec('00'); 
%      hex2dec('18'), hex2dec('26'), hex2dec('b0');
%      hex2dec('58'), hex2dec('e0'), hex2dec('00');
%      hex2dec('a0'), hex2dec('00'), hex2dec('a0')];
%CM = [hex2dec('e9'), hex2dec('00'), hex2dec('3a');
%      hex2dec('ff'), hex2dec('ba'), hex2dec('00'); 
%      hex2dec('18'), hex2dec('26'), hex2dec('b0');
%      hex2dec('58'), hex2dec('e0'), hex2dec('00');
%      hex2dec('a0'), hex2dec('00'), hex2dec('a0')];
CM = [hex2dec('e9'), hex2dec('00'), hex2dec('3a');
      hex2dec('ff'), hex2dec('ba'), hex2dec('00');
      hex2dec('40'), hex2dec('40'), hex2dec('ff');
      hex2dec('58'), hex2dec('e0'), hex2dec('00');
      hex2dec('b0'), hex2dec('00'), hex2dec('b0')];
CM = CM/256;

%scalpCh = [8,4,6,7];

% the titles in the legend
legends = [];


dataname = 'SSVEP';

% draw the figure with white background and full screen
%fgh = figure('Color',[1 1 1],'units','normalized','outerposition',[0 0 1 1]);
%fgh = figure('Color',[1 1 1],'units','pixels','outerposition',[0 0 1366 768]);
fgh = figure('Color',[1 1 1],'units','pixels','outerposition',[0 0 1366 768], 'visible', 'off');

hold on

tmpCmt = allData(i);
f = [4800];

harmonics = [];
if ~isempty(strfind(tmpCmt{1}(9:35), '10'))
    for h=1:floor(f(end)/9.8000)
        harmonics = [harmonics (h*9.8000)];
    end
end
if ~isempty(strfind(tmpCmt{1}(9:35), '12')) % TODO: check if this is exact
    for h=1:floor(f(end)/12)
        harmonics = [harmonics (h*12)];
    end
end
if ~isempty(strfind(tmpCmt{1}(9:35), '40'))
    for h=1:floor(f(end)/40.8333)
        harmonics = [harmonics (h*40.8333)];
    end
end
if ~isempty(strfind(tmpCmt{1}(9:35), '42')) % TODO: check if this is exact
    for h=1:floor(f(end)/42)
        harmonics = [harmonics (h*42)];
    end
end
if ~isempty(strfind(tmpCmt{1}(9:35), '50'))
    for h=1:floor(f(end)/54.4444)
        harmonics = [harmonics (h*54.4444)];
    end
end
if ~isempty(strfind(tmpCmt{1}(9:35), '51')) % TODO: check if this is exact
    for h=1:floor(f(end)/51)
        harmonics = [harmonics (h*51)];
    end
end

% compute PSD of all channels and plot the PSD + 95% confidence intervals
f_plot = cell(size(channelToPlot));
temp_plot = cell(size(channelToPlot));
for ii=1:length(channelToPlot)
    fprintf('ii: %d\n', ii);
    
    channels_plotted = [channels_plotted channelToPlot(ii)];
    
    m = [];
    expPSDs = []; % power spectral density during experiment
    ctrPSDs = []; % power spectral density during control/baseline
    
    % blackmanharris is a window - selected somewhat arbitrarily
    % pwelch - Welch's method
    % because we select no overlap, this is actually bartlett's method
    %data{channelToPlot(ii),1}
    %size(data{channelToPlot(ii),2}(1+cutLengthB:cutLengthE))
    %windlength
    %hp = fdesign.highpass('Fst,Fp,Ast,Ap',(2.0),(10.0),90,1,fs);
    %hpf = design(hp, 'butter');
    %chData = filtfilt(hpf.sosMatrix, hpf.ScaleValues,data{channelToPlot(ii),2});
    chData = data{channelToPlot(ii),2};
    chData = filtfilt(hpf.sosMatrix, hpf.ScaleValues,chData);
    chData = qrs_removal(chData, data{find(strcmp(data, 'Bottom Precordial')), 2});
    %figure
    %plot((1:numel(data{channelToPlot(ii),2}))/fs, chData);
    %xlabel('Time (seconds)');
    %ylabel('Measurement');
    %title(data{channelToPlot(ii),1});
    %continue
    [lpxx, f, lpxxc] = pwelch(chData(1+cutLengthB:cutLengthE), blackmanharris(windlength), noverlap, windlength, fs, 'ConfidenceLevel', 0.68);
    %figure
    %hold on;
    %plot(f, lpxx, 'Color', 'blue');
    %plot(f, lpxxc, 'Color', 'red');
    %ylim([0 1e1]);
    expPSDs = lpxx;
    confMeanExp = lpxxc';
    
    exp_psds{ii} = expPSDs;
    

    %assert((30*fs) < (1+cutLengthB));
    [lpxx, f, lpxxc] = pwelch(chData(1:30*fs), blackmanharris(windlength), noverlap, windlength, fs, 'ConfidenceLevel', 0.68);
    ctrPSDs = lpxx;
    confMeanCtr = lpxxc';
    %plot(f, lpxx, 'Color', 'green');
    %plot(f, lpxxc, 'Color', 'orange');

    %ylim([0 1e1]);
    %return
    
    ctr_psds{ii} = ctrPSDs;
    
    for iExp=1:size(expPSDs,1)
        %for iCtr=1:size(ctrPSDs,1)
        iCtr = iExp;
            m(end+1,:) = (expPSDs(iExp,:)) - (ctrPSDs(iCtr,:));
            %m(end+1,:) = log10(ctrPSDs(iExp,:));
            %m(end+1,:) = log10(expPSDs(iExp,:));
        %end
    end
    
    
    %mod_mean = @(x) mean(x(1:60,:));
    %mod_mean = @(x) mean(x(1:30,:));
    if publication_quality == 1
        mod_mean = @(x) log(mean(x));
        confMeanDiff = bootci(100, {mod_mean, m}, 'alpha', 0.01, 'type', 'per');
        %confMeanExp = bootci(100, {mod_mean, expPSDs}, 'alpha', 0.01, 'type', 'per');
        %confMeanCtr = bootci(100, {mod_mean, ctrPSDs}, 'alpha', 0.01, 'type', 'per');
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

    pxx = log(expPSDs);
    pxxC = log(ctrPSDs);
    
    diffPow = (pxx) - (pxxC);
    %diffPower(diffPower<0) = 0.00001;
    
    %subplot(3,1,1);hold on;
    %legends(end+1) = plot(f, (pxx),'color',CM(ii,:),'linewidth',3);
    %
    %if publication_quality == 1
    %    py = log([confMeanExp(1,:),  fliplr(confMeanExp(2,:))]);
    %    patch(px,py,1,'FaceColor',CM(ii,:),'EdgeColor','none');
    %    alpha(.4);
    %end
    %axis tight
    %
    %subplot(3,1,2);hold on;
    %plot(f, (pxxC),'color',CM(ii,:),'linewidth',3);
    %
    %if publication_quality == 1
    %    py = log([confMeanCtr(1,:),  fliplr(confMeanCtr(2,:))]);
    %    patch(px,py,1,'FaceColor',CM(ii,:),'EdgeColor','none');
    %    alpha(.4);
    %end
    %axis tight
    %
    %subplot(3,1,3);hold on;
    %plot(f, (diffPow),'color',CM(ii,:),'linewidth',3);
    %continue
    %temp = (expPSDs - ctrPSDs) ./ (confMeanCtr(2,:) - confMeanCtr(1,:))';
    %temp = (expPSDs - ctrPSDs) ./ ctrPSDs;
    %temp = log(abs(expPSDs - ctrPSDs));
    %temp = (expPSDs - ctrPSDs) ./ sqrt(confMeanCtr(2,:) - confMeanCtr(1,:))';
    temp = log(expPSDs ./ ctrPSDs);
    
    f_plot{ii} = zeros(size(harmonics));
    temp_plot{ii} = zeros(size(harmonics));
    for count = 1:numel(harmonics)
        h = harmonics(count);
        [~, index] = min(abs(f - h));
        %f_plot(count) = f(index);
        f_plot{ii}(count) = h;
        %temp_plot{ii}(count) = max(temp(index + (-2:2)));
        index = index + (-2:2);
        index = index(index > 0 & index <= numel(temp));
        temp_plot{ii}(count) = max(temp(index));
    end

    if strcmp(data{channelToPlot(ii), 1}, 'Endo')
        %plot(f, temp,'color',CM(ii,:),'linewidth',5);
        plot(f, temp,'color',CM(ii,:) + 0.6 * (1 - CM(ii,:)),'linewidth',2);
    else
        %plot(f, temp,'color',CM(ii,:),'linewidth',3);
        plot(f, temp,'color', 0.65 * [1 1 1],'linewidth',2);
    end
    %plot(f(1:20:end), temp(1:20:end),'color',CM(ii,:),'linewidth',3);
    
    if publication_quality == 1
        py = [confMeanDiff(1,:),  fliplr(confMeanDiff(2,:))];
        %patch(px,py,1,'FaceColor',CM(ii,:),'EdgeColor','none');
        alpha(.4);
    end
    axis tight
    
    %subplot(3,1,4);hold on;
    %%plot(f, diffPow,'color',CM(ii,:),'linewidth',3);
    %
    %if publication_quality == 1
    %    py = log(confMeanExp(2,:) - confMeanExp(1,:));
    %    plot(f',py,'Color',CM(ii,:));
    %    alpha(.4);
    %end
    %axis tight
    %
    %subplot(3,1,5);hold on;
    %%plot(f, diffPow,'color',CM(ii,:),'linewidth',3);
    %
    %if publication_quality == 1
    %    py = log(confMeanCtr(2,:) - confMeanCtr(1,:));
    %    plot(f',py,'Color',CM(ii,:));
    %    alpha(.4);
    %end
    %axis tight
    
end

for ii=1:length(channelToPlot)
        plot(f_plot{ii}, temp_plot{ii},'color',CM(ii,:),'linewidth',3);
    %if strcmp(data{channelToPlot(ii), 1}, 'Endo')
    %    %plot(f, temp,'color',CM(ii,:),'linewidth',5);
    %    plot(f_plot{ii}, temp_plot{ii},'color',CM(ii,:),'linewidth',3);
    %else
    %    %plot(f, temp,'color',CM(ii,:),'linewidth',3);
    %    plot(f_plot{ii}, temp_plot{ii},'color',[0.5 0.5 0.5],'linewidth',3);
    %end
end

for ii=1:length(channelToPlot)
    %scatter(f_plot{ii}, temp_plot{ii},100,[0 0 0], 'fill');
    %scatter(f_plot{ii}, temp_plot{ii},36,CM(ii,:), 'fill');
    scatter(f_plot{ii}, temp_plot{ii},144,[0 0 0], 'fill');
    scatter(f_plot{ii}, temp_plot{ii},81,CM(ii,:), 'fill');
end

ssvep_data{i,3} = exp_psds;
ssvep_data{i,4} = ctr_psds;
ssvep_data{i,5} = f;
ssvep_data{i,6} = {data{channels_plotted,1}};

tmpCmt = allData(i);
threshold = 5;
baseColor = [0 0 0] + 0.6;
mergedColor = [0.4 0 0] + 0.6;
color60 = [1 0 0];
%for sp = 1:3
    %subplot(3,1,sp);hold on;
    harmonics = [];
    %ylim([0 6]);
    ylim([-2 7]);
    yl = ylim;
    if ~isempty(strfind(tmpCmt{1}(9:35), '10'))
        for h=1:floor(f(end)/9.8000)
            harmonics = [harmonics (h*9.8000)];
            color = baseColor;
            if any(abs(mod((h*9.8000), 60) + [0 -60]) < threshold)
                color = mergedColor;
            end
            plot([(h*9.8000) (h*9.8000)], ylim,'Color',color,'linewidth',1)
        end
    end
    if ~isempty(strfind(tmpCmt{1}(9:35), '12')) % TODO: check if this is exact
        for h=1:floor(f(end)/12)
            harmonics = [harmonics (h*12)];
            color = baseColor;
            if any(abs(mod((h*12), 60) + [0 -60]) < threshold)
                color = mergedColor;
            end
            plot([(h*12) (h*12)], ylim,'Color',color,'linewidth',1)
        end
    end
    if ~isempty(strfind(tmpCmt{1}(9:35), '40'))
        for h=1:floor(f(end)/40.8333)
            harmonics = [harmonics (h*40.8333)];
            color = baseColor;
            if any(abs(mod((h*40.8333), 60) + [0 -60]) < threshold)
                color = mergedColor;
            end
            plot([(h*40.8333) (h*40.8333)], ylim,'Color',color,'linewidth',1)
        end
    end
    if ~isempty(strfind(tmpCmt{1}(9:35), '42')) % TODO: check if this is exact
        for h=1:floor(f(end)/42)
            harmonics = [harmonics (h*42)];
            color = baseColor;
            if any(abs(mod((h*42), 60) + [0 -60]) < threshold)
                color = mergedColor;
            end
            plot([(h*42) (h*42)], ylim,'Color',color,'linewidth',1)
        end
    end
    if ~isempty(strfind(tmpCmt{1}(9:35), '50'))
        for h=1:floor(f(end)/54.4444)
            harmonics = [harmonics (h*54.4444)];
            color = baseColor;
            if any(abs(mod((h*54.4444), 60) + [0 -60]) < threshold)
                color = mergedColor;
            end
            plot([(h*54.4444) (h*54.4444)], ylim,'Color',color,'linewidth',1)
        end
    end
    if ~isempty(strfind(tmpCmt{1}(9:35), '51')) % TODO: check if this is exact
        for h=1:floor(f(end)/51)
            harmonics = [harmonics (h*51)];
            color = baseColor;
            if any(abs(mod((h*51), 60) + [0 -60]) < threshold)
                color = mergedColor;
            end
            plot([(h*51) (h*51)], ylim,'Color',color,'linewidth',1)
        end
    end

    for h=1:floor(f(end)/60)
        %plot([(h*60) (h*60)], ylim,'Color',color60,'linewidth',1)
        scatter(h*60, yl(2), 'fill', 'red');
    end
    %ylim(yl);
%end

% add the legend
%subplot(3,1,1);
%legend(legends, data{channels_plotted,1})

%legend(legends, {'left eye','right eye', 'middle head', 'back head'});

% put a tick every 10 Hz
%tmp = get(gca,'xlim');
%set(gca,'XTick',[0:10:tmp(2)]);

% set labels and grid
%subplot(3,1,1);
%xlabel('frequency (Hz)');
%ylabel('experiment: ${log}_{10} (\mu V^2/{Hz})$','Interpreter','LaTex');
%tmp = title(['Experiment PSD: ' dataname  '_' filename ' |  window length (secs)=' int2str(windlengthSeconds) '  overlap=' num2str(noverlapPercent)]);
%set(tmp,'interpreter','none');
%grid on
%grid minor
%ylim([-7 6]);

%subplot(3,1,2);
%xlabel('frequency (Hz)');
%ylabel('baseline: ${log}_{10} (\mu V^2/{Hz})$','Interpreter','LaTex');
%set(gca, 'TickDir', 'out')

%subplot(3,1,3);
xlabel('Frequency (Hz)');
%ylabel('${log}_{10} (p_{exp} / p_{base})$', 'Interpreter', 'LaTeX');
ylabel('log_{10} (p_{exp} / p_{base})');
set(gca, 'TickDir', 'out')
%set(gca, 'XTick', roundn([0 harmonics], -1));
if ~isempty(strfind(tmpCmt{1}(9:35), '40'))
    set(gca, 'XTick', roundn([0 harmonics([1:2 3:2:end])], 0));
else
    set(gca, 'XTick', roundn([0 harmonics], 0));
end

%subplot(3,1,1);
%tmp = title(['SSVEP: '  allData(i)]);
%set(tmp,'interpreter','none');
%set(gca, 'TickDir', 'out')

%saveas(fgh, ['matlab_data/' S{i} '.fig']);
%save2pdf(['matlab_data/' int2str(i) '.pdf'], fgh, 1200);
name = S{i};
name(name == '.') = '_';
while any(name == '%')
    index = find(name == '%', 1);
    name = [name(1:(index-1)) '_' name((index+3):end)];
end
%xlim([-50, 100])
%pause(3)
%save2pdf(pdf_name, f, 300);

%tmp = title(sprintf('SSVEP: %s, window: %f secs, overlap: %f, %s, start: %f sec, end: %f sec\n%s', name, windlengthSeconds, noverlapPercent, rabbit_ID, t2 / fs, t3 / fs, allData{i}), 'Interpreter', 'None');
%tmp = title(sprintf('SSVEP: window: %0.1f secs, overlap: %0.2f, %s, start: %0.1f sec, end: %0.1f sec\n%s', windlengthSeconds, noverlapPercent, rabbit_ID, t2 / fs, t3 / fs, allData{i}), 'Interpreter', 'None');
tmp = title(sprintf('SSVEP: %.1f to %.f seconds', cutLengthB / fs, cutLengthE / fs), 'Interpreter', 'None');


set(findall(fgh,'type','text'),'fontSize',40,'fontWeight','normal', 'color', [0,0,0]);
set(gca,'FontSize',40);

saveas(fgh, ['matlab_data/' name '.fig']);      %save the matlab figure to file

if (harmonics(1) < 20)
    xlim([0 200]);
else
    xlim([0 500]);
end
saveas(fgh, ['matlab_data/' name '.epsc']);     %save the matlab figure to file
%saveas(fgh, ['matlab_data/' name '.pdf']);      %save the matlab figure to file
save2pdf(['matlab_data/' name '.pdf'], fgh, 1200);      %save the matlab figure to file

