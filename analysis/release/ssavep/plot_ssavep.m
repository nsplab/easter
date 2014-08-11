% plot_ssavep.m
%
% Plots the SSAEP/SSVEP response for a single experiment. In general, if the
% data is in the same format as the example data, it is easier to use
% plot_all_ssavep.m.
%
% Arguments:
%   data: cell array of the analog channel data
%         each row corresponds to one of the channels
%         first column is a string of the channel name
%         second column is an array of the data
%   cleanDigitalIn: binary array for the digital in channel (whether or not
%                   experiment is running)
%   experiment: either 'ssaep' or 'ssvep', specifying which experiment to plot
%   fs: sampling frequency
%   publication_quality: style of the plots
%     - 1: shaded confidence intervals (not functional as of 8/6/14)
%         WARNING: MATLAB appears to have a bug that causes figures with
%                  shading to be saved improperly as PDF and EPS files.
%                  plot2svg.m is an alternative method of saving, which
%                  avoids the problem.
%     - 2: no confidence intervals
%   windlengthSeconds: window length in seconds for power spectral density
%   noverlapPercent: overlap percentage for power spectral density windows
%   filters: filters to apply to all analog channels other than cardiac
%   cardiac_filters: filters to apply to cardiac channel
%   channelToPlot: list of channel indices to plot
%   CM: list of the colors for each of the channels in the plot
%   name: filename to save to (does not include suffix)
%   filter_cardiac: whether or not to perform cardiac removal
%   comment: line from the experiment log corresponding to this run
%            Not currently used, but could be added as title.
%
% Output:
%   fgh: figure handle

function [ fgh ] = plot_ssavep(data, cleanDigitalIn, name, experiment, fs, publication_quality, windlengthSeconds, noverlapPercent, filters, cardiac_filters, channelToPlot, CM, comment)

%% Information about plots

% constants for computing power spectral density (psd)
windlength = windlengthSeconds * fs;     % window length
noverlap = windlength * noverlapPercent; % number of overlap timesteps

% Threshold for being considered close to a harmonic
threshold_60 = 3;        % Threshold for 60 Hz harmonics
threshold_harmonics = 3; % Threshold to be considered a harmonic

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

% get frequency of stimulus based on experiment log
[ nominal_frequency, frequency ] = get_frequency(comment, filename);

% get unprocessed analog channel from cardiac electrode
cardiacDataRaw = data{strcmp(data, 'Bottom Precordial'), 2};
% filter cardiac data
cardiacData = run_filters(cardiacDataRaw, cardiac_filters);

%% Create the figure

% Constants for figure size
width = 275;   % width of figure (just plot itself, not labels)
height = 225;  % height of figure (just plot itself, not labels)
margins = 100; % extra space for labels

% make the figure with white background, with fixed size (in pixels) and invisible
fgh = figure('Color',[1 1 1],'units','pixels','position',[0 0 (width + 2 * margins) (height + 2 * margins)], 'visible', 'off');
% make axes with correct margins
axes('units', 'pixel', 'position', [margins margins width height]);
% Allow all channels to be shown
hold on;

% frequencies / ratio at the harmonics for each channel
f_harmonic = cell(1, numel(channelToPlot));
ratio_harmonic = cell(1, numel(channelToPlot));

for ii=1:numel(channelToPlot)

    % Print progress
    fprintf('ii: %d / %d\n', ii, numel(channelToPlot));

    % get unprocessed analog channel from electrode
    chDataRaw = data{channelToPlot(ii),2};
    % filter cardiac data
    chData = run_filters(chDataRaw, filters);
    % remove cardiac artifacts
    chData = cardiac_removal(chData, cardiacData);

    % blackmanharris is a windowing function - selected somewhat arbitrarily
    % pwelch - Welch's method
    % Experiment power spectral density
    start = (1*fs+cutLengthB);
    finish = (-1*fs+cutLengthE);
    if (strcmp(name, 'Thu_15_05_2014_14_20_24'))
        % special case (large dc shift at ~5 seconds after cutLengthB)
        start = (6*fs+cutLengthB);
    end
    [lpxx, f, lpxxc] = pwelch(chData(start:finish), blackmanharris(windlength), noverlap, windlength, fs, 'ConfidenceLevel', 0.95);
    % print timestamps for experiment
    fprintf('Experiment: %d %d\n', start, finish);

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

    % ratio of experimental psd to baseline psd
    ratio = expPSDs ./ ctrPSDs;
    
    % get harmonics of stimulus
    num_harmonics = floor(f(end)/frequency);      % highest harmonic that is relevant
    f_harmonic{ii} = zeros(1, num_harmonics);     % list of harmonic frequencies
    ratio_harmonic{ii} = zeros(1, num_harmonics); % list of ratios at harmonics
    near_harmonic = false(size(f));               % boolean of whether or not each frequency is close to any harmonic
    for count = 1:num_harmonics                                     % loop through all harmonics
        h = count * frequency;                                      % frequency of this harmonic
        [~, index] = min(abs(f - h));                               % closest frequency returned by psd
        f_harmonic{ii}(count) = h;                                  % store harmonic
        near_this_harmonic = (abs(f - h) <= threshold_harmonics);   % boolean array for being close to this harmonic
        ratio_harmonic{ii}(count) = max(ratio(near_this_harmonic)); % tip of the ratio at this harmonic
        near_harmonic = (near_harmonic | near_this_harmonic);       % update complete list of near harmonic
    end

    % set 60 Hz harmonics to nan
    valid = ~any(abs(mod(repmat(f, 1, 2), 60) + repmat([0 -60], numel(f), 1)) <= threshold_60, 2);
    ratio(~valid) = nan;

    % set stimulus harmonics to nan
    ratio(near_harmonic) = nan;

    color = 0.65 * [1 1 1]; % default color for scalp electrodes
    if strcmp(data{channelToPlot(ii), 1}, 'Endo')
        color = CM(ii,:) + 0.6 * (1 - CM(ii,:)); % special color for endo
    end
    % Display faded data in background (not near 60 Hz or stimulus harmonics)
    plot(f(~isnan(ratio)) / 1000, ratio(~isnan(ratio)),'color', color,'linewidth',1);
    
    % confidence intervals (not complete - 8/6/14)
    if publication_quality == 1
        px=[f', fliplr(f')];
        py = [confMeanDiff(1,:),  fliplr(confMeanDiff(2,:))];
        patch(px,py,1,'FaceColor',CM(ii,:),'EdgeColor','none');
        alpha(.4);
    end

    axis tight;

end

%% Plot harmonic data

% Plot line for each harmonic
for ii=1:length(channelToPlot)
    % set 60 Hz harmonics to nan
    valid = ~any(abs(mod(repmat(f_harmonic{ii}, 2, 1), 60) + repmat([0;-60], 1, numel(f_harmonic{ii}))) <= threshold_60, 1);
    ratio_harmonic{ii}(~valid) = nan;
    plot(f_harmonic{ii}(valid) / 1000, ratio_harmonic{ii}(valid),'color',CM(ii,:),'linewidth',5);
end

% Put point on each harmonic
for ii=1:length(channelToPlot)
    %scatter(f_harmonic{ii} / 1000, ratio_harmonic{ii},10^2,[0 0 0], 'fill');
    %scatter(f_harmonic{ii} / 1000, ratio_harmonic{ii},6^2,CM(ii,:), 'fill');
end

%% Figure formatting

% Use fixed axes and ticks for axes
if (strcmp(experiment, 'ssvep'))
    xrange = ([0 800] / 1000);
else
    xrange = ([0 f(end)] / 1000);
end
xlim(xrange);
yrange = (10 .^ [-1 3]);
ylim(yrange);
xticks = linspace(xrange(1), xrange(2), 5);
yticks = logspace(log10(yl(1)), log10(yl(2)), 5);

% Display full box around figures
box on;

% Log scale for y axis
set(gca,'yscale','log');

% Constant for font size
font_size = 20;

%% Figure with labels
% set ticks on axes
set(gca, 'XTick', xticks);
set(gca, 'YTick', yticks);
% label axes
xlabel('Frequency (kHz)');
ylabel('p_{exp} / p_{rest}');
% set size of tick labels
set(gca,'FontSize',font_size);
%set size of labels
set(findall(fgh,'type','text'),'fontSize',font_size,'fontWeight','normal', 'color', [0 0 0]);
% fake white title to keep size of figures same when using pdfcrop (with ylabel vs. without y label)
title('|', 'color', 'white', 'fontsize', font_size);

% Save labelled version of figure
saveas(fgh, ['figures/' name '.fig']);
plot2svg(['figures/' name '_labelled.svg'], fgh, 'png');
save2pdf(['figures/' name '_labelled.pdf'], fgh, 150);

%% Figure with no labels
% Remove labels on ticks for y axis
set(gca, 'YTickLabel', {});
% Set text color to white
set(findall(fgh,'type','text'),'fontSize',font_size,'fontWeight','normal', 'color', [1 1 1]);
% remove label for y axis
ylabel('');

% Save unlabelled version of figure
plot2svg(['figures/' name '.svg'], fgh, 'png');
save2pdf(['figures/' name '.pdf'], fgh, 150);

end

