function [] = publish_ssavep(data, fs, windlengthSeconds, noverlapPercent, cleanDigitalIn, channelToPlot, filters, CM, experiment, filename, comment, publication_quality, name)

% sampling rate
%fs = 9600;
%windlengthSeconds = 2;
windlength = windlengthSeconds * fs;
%noverlapPercent = 0.25;%windlength * 0.25; % number overlap percent
noverlap = windlength * noverlapPercent; % number overlap (timesteps)

threshold = 4; % Threshold for 60 Hz harmonics

time_axis = (0:numel(cleanDigitalIn)-1)*1.0/fs;
%figure;plot(time_axis,dataColumnDig);

t1 = diff(cleanDigitalIn); % -1: experiment turns off, 0: no change, 1: experiment turns on
t2 = find(t1 == 1); % first time when led turns on (experiment starts)
t3 = find(t1 == -1); % last time when led turns off (experiment ends)

if isempty(t3)
    t3 = length(cleanDigitalIn);
end

cutLengthB = t2; %fs * cutSecondsBegining;
cutLengthE = t3; %fs * cutSecondsEnd;

assert(numel(cutLengthB) == 1);
assert(numel(cutLengthE) == 1);

assert(cutLengthB < cutLengthE);

%channelToPlot = [2,3,5,7,8];
channels_plotted = [];

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
%CM = [hex2dec('e9'), hex2dec('00'), hex2dec('3a');
%      hex2dec('ff'), hex2dec('ba'), hex2dec('00');
%      hex2dec('40'), hex2dec('40'), hex2dec('ff');
%      hex2dec('58'), hex2dec('e0'), hex2dec('00');
%      hex2dec('b0'), hex2dec('00'), hex2dec('b0')];
%CM = CM/256;

%scalpCh = [8,4,6,7];

% the titles in the legend
legends = [];


% draw the figure with white background and full screen
%fgh = figure('Color',[1 1 1],'units','normalized','outerposition',[0 0 1 1]);
%fgh = figure('Color',[1 1 1],'units','pixels','outerposition',[0 0 1366 768]);
%fgh = figure('Color',[1 1 1],'units','pixels','outerposition',[0 0 1400 1100], 'visible', 'off');
%fgh = figure('Color',[1 1 1],'units','pixels','outerposition',[0 0 700 700], 'visible', 'off');
%fgh = figure('Color',[1 1 1],'units','pixels','position',[0 0 700 700],'ActivePositionProperty', 'position', 'visible', 'off');
width = 600;
height = 500;
margins = 200;
fgh = figure('Color',[1 1 1],'units','pixels','outerposition',[0 0 (width + 2 * margins) (height + 2 * margins)], 'visible', 'off');
axes('units', 'pixel', 'position', [margins margins width height])

%fgh = figure('Color',[1 1 1],'units','pixels','outerposition',[0 0 1366 768]);
hold on

[ nominal_frequency, frequency ] = get_frequency(comment, filename);

% compute PSD of all channels and plot the PSD + 95% confidence intervals
f_plot = cell(size(channelToPlot));
temp_plot = cell(size(channelToPlot));

cardiacData = run_filters(data{find(strcmp(data, 'Bottom Precordial')), 2}, filters);

for ii=1:numel(channelToPlot)
    fprintf('ii: %d / %d\n', ii, numel(channelToPlot));

    channels_plotted = [channels_plotted channelToPlot(ii)];

    m = [];
    expPSDs = []; % power spectral density during experiment
    ctrPSDs = []; % power spectral density during control/baseline

    % blackmanharris is a window - selected somewhat arbitrarily
    % pwelch - Welch's method
    % because we select no overlap, this is actually bartlett's method
    chData = run_filters(data{channelToPlot(ii),2}, filters);
    chData = qrs_removal(chData, cardiacData);

    %chData(1+cutLengthB:cutLengthE) = chData(1+cutLengthB:cutLengthE) / norm(chData(1+cutLengthB:cutLengthE));
    %if (strcmp(name, '_Tue_06_05_2014_11_14_51_ssvep_40'))
    %if (strcmp(name, '_Thu_15_05_2014_12_26_26_ssaep_ctr_86'))
    [lpxx, f, lpxxc] = pwelch(chData((1*fs+cutLengthB):(-1*fs+cutLengthE)), blackmanharris(windlength), noverlap, windlength, fs, 'ConfidenceLevel', 0.95);
    if (strcmp(name, '_Thu_15_05_2014_14_20_24_ssvep_40'))
        [lpxx, f, lpxxc] = pwelch(chData((6*9600+cutLengthB):(-1*fs+cutLengthE)), blackmanharris(windlength), noverlap, windlength, fs, 'ConfidenceLevel', 0.95); % for rabbit 10 ssvep i = 23 (large dc shift at ~5 seconds after cutLengthB)
    end


    expPSDs = lpxx;
    confMeanExp = lpxxc';

    exp_psds{ii} = expPSDs;


    if (cutLengthB > length(cleanDigitalIn) - cutLengthE)
        baseline = (1*fs):(cutLengthB - 1 * fs);
    else
        baseline = (cutLengthE + 1 * fs):(-1*fs+length(cleanDigitalIn));
    end
    %assert((30*fs) < (1+cutLengthB));
    %chData(1:30*fs) = chData(1:30*fs) / norm(chData(1:30*fs));
    %[lpxx, f, lpxxc] = pwelch(chData(1:30*fs), blackmanharris(windlength), noverlap, windlength, fs, 'ConfidenceLevel', 0.95);
    [lpxx, f, lpxxc] = pwelch(chData(baseline), blackmanharris(windlength), noverlap, windlength, fs, 'ConfidenceLevel', 0.95);
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
    %temp = log10(expPSDs ./ ctrPSDs);
    %temp = log10(ctrPSDs); % TODO
    %temp = log10(expPSDs);
    %temp = expPSDs' ./ (confMeanExp(2, :) - confMeanExp(1, :));
    %temp = (expPSDs - ctrPSDs)' ./ (confMeanExp(2, :) - confMeanExp(1, :));
    %temp = (confMeanCtr(2, :) - confMeanCtr(1, :)) ./ (confMeanExp(2, :) - confMeanExp(1, :));
    %temp = log(expPSDs);
    temp = expPSDs ./ ctrPSDs;
    
    num_harmonics = floor(f(end)/frequency);
    f_plot{ii} = zeros(1, num_harmonics);
    temp_plot{ii} = zeros(1, num_harmonics);
    for count = 1:num_harmonics
        h = count * frequency;
        [~, index] = min(abs(f - h));
        f_plot{ii}(count) = h;
        %index = index + (-2:2);
        index = index + (-10:10);
        index = index(index > 0 & index <= numel(temp));
        temp_plot{ii}(count) = max(temp(index));
    end

    for j = 1:numel(f)
        if any(abs(mod(f(j), 60) + [0 -60]) <= threshold)
            temp(j) = nan;
        end
    end

    valid = ~isnan(temp);

    if strcmp(data{channelToPlot(ii), 1}, 'Endo')
        %plot(f, temp,'color',CM(ii,:),'linewidth',5);
        %plot(f, temp,'color',CM(ii,:) + 0.6 * (1 - CM(ii,:)),'linewidth',2);
        plot(f(valid) / 1000, temp(valid),'color',CM(ii,:) + 0.6 * (1 - CM(ii,:)),'linewidth',1);
    else
        %plot(f, temp,'color',CM(ii,:),'linewidth',3);
        plot(f(valid) / 1000, temp(valid),'color', 0.65 * [1 1 1],'linewidth',1);
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
    for count = 1:num_harmonics
        h = count * frequency;
        if any(abs(mod(h, 60) + [0 -60]) <= threshold)
            temp_plot{ii}(count) = nan;
        end
    end
        %plot(f_plot{ii}, temp_plot{ii},'color',CM(ii,:),'linewidth',3);
        valid = ~isnan(temp_plot{ii});
        plot(f_plot{ii}(valid) / 1000, temp_plot{ii}(valid),'color',CM(ii,:),'linewidth',7);
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
    %scatter(f_plot{ii}, temp_plot{ii},144,[0 0 0], 'fill');
    %scatter(f_plot{ii}, temp_plot{ii},81,CM(ii,:), 'fill');
    %scatter(f_plot{ii} / 1000, temp_plot{ii},26^2,[0 0 0], 'fill');
    %scatter(f_plot{ii} / 1000, temp_plot{ii},22^2,CM(ii,:), 'fill');
end

baseColor = [0 0 0] + 0.6;
mergedColor = [0.4 0 0] + 0.6;
color60 = [1 0 0];
%for sp = 1:3
    %subplot(3,1,sp);hold on;
    %ylim([0 6]);
    %ylim([-2 7]);
    ylim(10 .^ [-1 3]);
    %ylim([-10 5]); % TODO
    %ylim([-4 2]);
    %ylim([-0.5 3]);
    yl = ylim;
    for h=1:floor(f(end)/frequency)
        color = baseColor;
        if any(abs(mod((h*frequency), 60) + [0 -60]) < threshold)
            color = mergedColor;
            continue
        end
        %plot([(h*frequency) (h*frequency)], ylim,'Color',color,'linewidth',1)
    end

    for h=1:floor(f(end)/60)
        %plot([(h*60) (h*60)], ylim,'Color',color60,'linewidth',1)
        %scatter(h*60, yl(2), 'fill', 'red');
    end
    ylim(yl);
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
%xlabel('Frequency (Hz)');
%ylabel('${log}_{10} (p_{exp} / p_{base})$', 'Interpreter', 'LaTeX');
%ylabel('log_{10} (p_{exp} / p_{base})'); % TODO
%ylabel('log_{10} p_{base}');
%ylabel('log_{10} p_{experiment}');
set(gca, 'TickDir', 'out')
%set(gca, 'XTick', roundn([0 harmonics], -1));
if nominal_frequency == 40
    set(gca, 'XTick', roundn([0:2 3:2:num_harmonics] * frequency, 0));
    set(gca, 'XTick', roundn((1:15:num_harmonics) * frequency, 0));
else
    set(gca, 'XTick', roundn((0:num_harmonics) * frequency, 0));
    set(gca, 'XTick', roundn((1:7:num_harmonics) * frequency, 0));
end
set(gca, 'XTick', []);
set(gca, 'YTick', []);

%subplot(3,1,1);
%tmp = title(['SSVEP: '  allData(i)]);
%set(tmp,'interpreter','none');
%set(gca, 'TickDir', 'out')

%saveas(fgh, ['matlab_data/' S{i} '.fig']);
%save2pdf(['matlab_data/' int2str(i) '.pdf'], fgh, 1200);
%name = [name '_baseline']; % TODO
%name = [name '_experimental'];
%name = [name '_temp'];
%xlim([-50, 100])
%pause(3)
%save2pdf(pdf_name, f, 300);

%tmp = title(sprintf('SSVEP: %s, window: %f secs, overlap: %f, %s, start: %f sec, end: %f sec\n%s', name, windlengthSeconds, noverlapPercent, rabbit_ID, t2 / fs, t3 / fs, allData{i}), 'Interpreter', 'None');
%tmp = title(sprintf('SSVEP: window: %0.1f secs, overlap: %0.2f, %s, start: %0.1f sec, end: %0.1f sec\n%s', windlengthSeconds, noverlapPercent, rabbit_ID, t2 / fs, t3 / fs, allData{i}), 'Interpreter', 'None');
%tmp = title(sprintf('%s: %.1f to %.f seconds', upper(experiment), cutLengthB / fs, cutLengthE / fs), 'Interpreter', 'None');


set(findall(fgh,'type','text'),'fontSize',40,'fontWeight','normal', 'color', [0,0,0]);
set(gca,'FontSize',40);
box on;

saveas(fgh, ['matlab_data/' name '.fig']);      %save the matlab figure to file

if (frequency < 40)
    xlim([0 200]);
else
    xlim([0 500]);
end
if (strcmp(experiment, 'ssvep'))
    xlim([0 800] / 1000);
else
    xlim([0 f(end)] / 1000);
end

set(gca,'yscale','log');

font_size = 40;
xlabel('Frequency (kHz)');
%% Figure with no labels
xl = xlim();
xticks = linspace(xl(1), xl(2), 5);
yl = ylim();
yticks = logspace(log10(yl(1)), log10(yl(2)), 5);

%% Figure with labels
set(gca, 'XTick', xticks);
set(gca, 'YTick', yticks);

ylabel('p_{exp} / p_{rest}');
set(findall(fgh,'type','text'),'fontSize',font_size,'fontWeight','normal', 'color', [0 0 0]);
set(gca,'FontSize',font_size);

saveas(fgh, ['matlab_data/' name '.fig']);      %save the matlab figure to file
save2pdf(['matlab_data/' name '_labelled.pdf'], fgh, 150);      %save the matlab figure to file

set(gca, 'XTick', xticks);
set(gca, 'YTick', yticks);
set(gca, 'YTickLabel', {});
set(gca,'FontSize',font_size);
set(findall(fgh,'type','text'),'fontSize',font_size,'fontWeight','normal', 'color', [1 1 1]);
ylabel('');

save2pdf(['matlab_data/' name '.pdf'], fgh, 150);      %save the matlab figure to file

end

