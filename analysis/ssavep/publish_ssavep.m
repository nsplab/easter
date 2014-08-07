function [] = publish_ssavep(data, fs, windlengthSeconds, noverlapPercent, cleanDigitalIn, channelToPlot, filters, CM, experiment, filename, comment, publication_quality, name, cardiac_filters)

% sampling rate
windlength = windlengthSeconds * fs;
noverlap = windlength * noverlapPercent; % number overlap (timesteps)

threshold_60 = 3; % Threshold for 60 Hz harmonics
threshold_harmonics = 3; % Threshold to be considered a harmonic

time_axis = (0:numel(cleanDigitalIn)-1)*1.0/fs;

t1 = diff(cleanDigitalIn); % -1: experiment turns off, 0: no change, 1: experiment turns on
t2 = find(t1 == 1);        % times when digital in turns on (experiment starts)
t3 = find(t1 == -1);       % times when digital in turns off (experiment ends)

if isempty(t3) % digital in never turns off
    % experiment ends when data stops
    t3 = length(cleanDigitalIn);
end

cutLengthB = t2; % time steps to cut from beginning
cutLengthE = t3; % time steps to cut from end

assert(numel(cutLengthB) == 1); % bad data with multiple experiment starts
assert(numel(cutLengthE) == 1); % bad data with multiple experiment ends

assert(cutLengthB < cutLengthE); % bad data with experiment ending before starting

% draw the figure with white background and fixed size (in pixels)
width = 275;   % width of figure (just plot itself, not labels)
height = 225;  % height of figure (just plot itself, not labels)
margins = 100; % extra space for labels

% Open invisible screen for figure
fgh = figure('Color',[1 1 1],'units','pixels','position',[0 0 (width + 2 * margins) (height + 2 * margins)], 'visible', 'off');
axes('units', 'pixel', 'position', [margins margins width height]);
hold on

[ nominal_frequency, frequency ] = get_frequency(comment, filename);

cardiacData = run_filters(data{find(strcmp(data, 'Bottom Precordial')), 2}, cardiac_filters);

f_harmonic = cell(1, numel(channelToPlot));
ratio_harmonic = cell(1, numel(channelToPlot));

for ii=1:numel(channelToPlot)

    fprintf('ii: %d / %d\n', ii, numel(channelToPlot));

    chData = run_filters(data{channelToPlot(ii),2}, filters);
    chData = qrs_removal(chData, cardiacData);

    % blackmanharris is a window - selected somewhat arbitrarily
    % pwelch - Welch's method
    % Experiment power spectral density
    [lpxx, f, lpxxc] = pwelch(chData((1*fs+cutLengthB):(-1*fs+cutLengthE)), blackmanharris(windlength), noverlap, windlength, fs, 'ConfidenceLevel', 0.95);
    fprintf('Experiment: %d %d\n', (1*fs+cutLengthB), (-1*fs+cutLengthE));
    if (strcmp(name, '_Thu_15_05_2014_14_20_24_ssvep_40'))
        % for rabbit 10 ssvep i = 23 (large dc shift at ~5 seconds after cutLengthB)
        [lpxx, f, lpxxc] = pwelch(chData((6*fs+cutLengthB):(-1*fs+cutLengthE)), blackmanharris(windlength), noverlap, windlength, fs, 'ConfidenceLevel', 0.95);
        fprintf('Experiment: %d %d\n', (6*fs+cutLengthB), (-1*fs+cutLengthE));
    end
    % power spectral density during experiment
    expPSDs = lpxx;
    confMeanExp = lpxxc';

    % use the longer of the beginning/ending as the resting state
    % Resting state power spectral density
    if (cutLengthB > length(cleanDigitalIn) - cutLengthE)
        resting = (1*fs):(cutLengthB - 1 * fs);
    else
        resting = (cutLengthE + 1 * fs):(-1*fs+length(cleanDigitalIn));
    end
    fprintf('Baseline: %d %d\n', resting(1), resting(end));
    [lpxx, f, lpxxc] = pwelch(chData(resting), blackmanharris(windlength), noverlap, windlength, fs, 'ConfidenceLevel', 0.95);
    % power spectral density during control/baseline
    ctrPSDs = lpxx;
    confMeanCtr = lpxxc';

    px=[f', fliplr(f')];

    % ratio of experimental psd to baseline psd
    ratio = expPSDs ./ ctrPSDs;
    
    % get harmonics of stimulus
    num_harmonics = floor(f(end)/frequency);
    f_harmonic{ii} = zeros(1, num_harmonics);
    ratio_harmonic{ii} = zeros(1, num_harmonics);
    near_harmonic = false(size(f));
    for count = 1:num_harmonics
        h = count * frequency;
        [~, index] = min(abs(f - h));
        f_harmonic{ii}(count) = h;
        near_this_harmonic = (abs(f - h) <= threshold_harmonics);
        ratio_harmonic{ii}(count) = max(ratio(near_this_harmonic));
        near_harmonic = (near_harmonic | near_this_harmonic);
    end

    % set 60 Hz harmonics to nan
    valid = ~any(abs(mod(repmat(f, 1, 2), 60) + repmat([0 -60], numel(f), 1)) <= threshold_60, 2);
    ratio(~valid) = nan;

    % Cover up data near harmonics
    ratio(near_harmonic) = nan;

    color = 0.65 * [1 1 1]; % default color
    if strcmp(data{channelToPlot(ii), 1}, 'Endo')
        color = CM(ii,:) + 0.6 * (1 - CM(ii,:)); % special color for endo
    end
    plot(f(~isnan(ratio)) / 1000, ratio(~isnan(ratio)),'color', color,'linewidth',1);
    
    % confidence intervals (may not work - 8/6/14)
    if publication_quality == 1
        py = [confMeanDiff(1,:),  fliplr(confMeanDiff(2,:))];
        patch(px,py,1,'FaceColor',CM(ii,:),'EdgeColor','none');
        alpha(.4);
    end

    axis tight

end

for ii=1:length(channelToPlot)
    % set 60 Hz harmonics to nan
    valid = ~any(abs(mod(repmat(f_harmonic{ii}, 2, 1), 60) + repmat([0;-60], 1, numel(f_harmonic{ii}))) <= threshold_60, 1);
    ratio_harmonic{ii}(~valid) = nan;
    plot(f_harmonic{ii}(valid) / 1000, ratio_harmonic{ii}(valid),'color',CM(ii,:),'linewidth',5);
end

for ii=1:length(channelToPlot)
    %scatter(f_harmonic{ii} / 1000, ratio_harmonic{ii},10^2,[0 0 0], 'fill');
    %scatter(f_harmonic{ii} / 1000, ratio_harmonic{ii},6^2,CM(ii,:), 'fill');
end

ylim(10 .^ [-1 3]);

%set(gca, 'TickDir', 'out')

box on;

if (strcmp(experiment, 'ssvep'))
    xlim([0 800] / 1000);
else
    xlim([0 f(end)] / 1000);
end

set(gca,'yscale','log');

font_size = 20;
xlabel('Frequency (kHz)');
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
title('|', 'color', 'white', 'fontsize', font_size);

saveas(fgh, ['matlab_data/' name '.fig']);      %save the matlab figure to file
save2pdf(['matlab_data/' name '_labelled.pdf'], fgh, 150);      %save the matlab figure to file

%% Figure with no labels
set(gca, 'XTick', xticks);
set(gca, 'YTick', yticks);
set(gca, 'YTickLabel', {});
set(findall(fgh,'type','text'),'fontSize',font_size,'fontWeight','normal', 'color', [1 1 1]);
ylabel('');

save2pdf(['matlab_data/' name '.pdf'], fgh, 150);      %save the matlab figure to file

end

