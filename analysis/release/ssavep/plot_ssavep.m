function [ fgh ] = plot_ssavep(data, cleanDigitalIn, name, ssavep, fs, cardiac_data, windlengthSeconds, noverlapPercent, filters, cardiac_filters, CM, channelNames, comment, data2, cleanDigitalIn2, cardiac_data2)
%PLOT_SSAVEP  Plots the SSAEP/SSVEP response for a single run.
%
% FGH = PLOT_SSAVEP(DATA, CLEANDIGITALIN, NAME, EXPERIMENT, FS, ...
%                   CARDIAC_DATA, WINDLENGTHSECONDS, NOVERLAPPERCENT, ...
%                   FILTERS, CARDIAC_FILTERS, CM, CHANNELNAMES, COMMENT)
%
% Parameters:
%
%   DATA is a matrix of values from the analog channels connected to the
%   electrodes. Each of the rows corresponds to one of the channels. Each of
%   the columns corresponds to a sample from one of the timesteps.
%
%   CLEANDIGITALIN is a binary vector of the digital in channel (whether or not
%   the LED is on at each time step).
%
%   NAME is a string of the filename to save to (should not include suffix).
%
%   SSAVEP is a string that selects which experiment to plot (ssaep or ssvep).
%
%
%   CARDIAC_DATA is a vector of the values from the analog channel connected
%   to the cardiac electrode. This vector should be empty if removal of
%   cardiac artifacts is not desired.
%
%   WINDLENGTHSECONDS is the length of the windows in seconds to be used for
%   calculating the power spectral density.
%
%   NOVERLAPPERCENT is the fraction of windows that overlap for calculating
%   the power spectral density.
%
%   FILTERS is a list of filters to apply to all analog channels other than
%   the cardiac channel.
%
%   CARDIAC_FILTERS is a list of filters to apply to the cardiac channel.
%
%   CM is a matrix of the colors for each of the channels in the plot. Each
%   row corresponds to one of the channels, and the three columns are the RGB
%   values for the color.
%
%   CHANNELSNAMES is a list of strings for the names of the channels. This is not
%   currently used, but is available to use in the legend.
%
%   COMMENT is a string that is the line from the experiment log corresponding
%   to this run. This is not currently used, but is available to use as the
%   title.
%
% Output:
%
%   FGH is the figure handle of the generated figure.
%
% In general, if the data is in the same format as the example data, it is
% easier to use PLOT_ALL_SSAVEP.
%
% See also PLOT_ALL_SSAVEP.
set(0,'defaultAxesFontName', 'SansSerif');
set(0,'defaultTextFontName', 'SansSerif');
set(0,'DefaultAxesFontSize', 20);
set(0,'DefaultTextFontSize', 20);


%% Constants

% Figure window size
width = 275;   % width of figure (just plot itself, not labels)
height = 225;  % height of figure (just plot itself, not labels)
margins = 100; % extra space for labels

% Axes for figure
%if (strcmp(ssavep, 'ssvep'))
%    xrange = ([0 800] / 1000);                    % x-axis limits for ssvep
%else
%    xrange = ([0 4800] / 1000);                   % x-axis limits for ssaep
%end
xrange = [0 4800];
%xrange = [0 1000];
%yrange = (10 .^ [-1 3]);                          % y-axis limits
yrange = (10 .^ [-4 1]);                          % y-axis limits
xticks = linspace(xrange(1), xrange(2), 5);       % tick marks on x-axis
yticks = logspace(log10(yrange(1)), log10(yrange(2)), 6); % tick marks on y-axis

% constants for computing power spectral density (psd)
windlength = windlengthSeconds * fs;     % window length
noverlap = windlength * noverlapPercent; % number of overlap timesteps

% Thresholds for being considered close to a harmonic
threshold_60 = 3;        % Threshold for 60 Hz harmonics
threshold_harmonics = 3; % Threshold to be considered a harmonic

% whether or not to plot points on harmonics
harmonic_points = false;

SPLICING = (nargin >= 15);

%% Create the figure

% make the figure with white background, with fixed size (in pixels) and invisible
fgh = figure('Color',[1 1 1],'units','pixels','position',[0 0 (width + 2 * margins) (height + 2 * margins)], 'visible', 'off');
% make axes with correct margins
axes('units', 'pixel', 'position', [margins margins width height]);
hold on; % Allow all channels to be shown


%% Information about plots

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

if (SPLICING)
    t12 = diff(cleanDigitalIn2); % -1: experiment turns off, 0: no change, 1: experiment turns on
    t22 = find(t12 == 1);        % times when digital in turns on (experiment starts)
    t32 = find(t12 == -1);       % times when digital in turns off (experiment ends)
    
    if isempty(t32) % digital in never turns off
        % experiment ends when data stops
        t32 = length(cleanDigitalIn2);
    end
    
    cutLengthB2 = t22; % time steps to cut from beginning
    cutLengthE2 = t32; % time steps to cut from end
    
    assert(numel(cutLengthB2) == 1); % bad data with multiple experiment starts
    assert(numel(cutLengthE2) == 1); % bad data with multiple experiment ends
    
    assert(cutLengthB2 < cutLengthE2); % bad data with experiment ending before starting

    % filter cardiac data, if cardiac data is available
    if (~isempty(cardiac_data2))
        cardiac_data2 = run_filters(cardiac_data2, cardiac_filters);
    end
end

% get frequency of stimulus based on experiment log
[ nominal_frequency, frequency ] = get_frequency(comment, name);

% filter cardiac data, if cardiac data is available
if (~isempty(cardiac_data))
    cardiac_data = run_filters(cardiac_data, cardiac_filters);
end



% frequencies / ratio at the harmonics for each channel
f_harmonic = cell(1, size(data, 1));
ratio_harmonic = cell(1, size(data, 1));

%% Plot for each channel
for ii=1:size(data, 1)

    % Print progress
    fprintf('ii: %d / %d\n', ii, size(data, 1));

    chDataRaw = data(ii, :);                  % get unprocessed analog channel from electrode
    chData = run_filters(chDataRaw, filters); % filter electrode data
    if (~isempty(cardiac_data))               % remove cardiac artifacts, if requested
        chData = cardiac_removal(chData, cardiac_data, fs);
    end

    if (SPLICING)
        chDataRaw2 = data2(ii, :);                  % get unprocessed analog channel from electrode
        chData2 = run_filters(chDataRaw2, filters); % filter electrode data
        if (~isempty(cardiac_data2))               % remove cardiac artifacts, if requested
            chData2 = cardiac_removal(chData2, cardiac_data2, fs);
        end
    end

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
    %fprintf('Experiment: %d %d\n', start, finish); % print timestamps for experiment
    fprintf('Experiment: %f\n', (finish - start) / fs); % print timestamps for experiment

    % power spectral density during experiment
    expPSDs = lpxx;
    confMeanExp = lpxxc';


    % use the longer of the beginning/ending as the resting state
    % Resting state power spectral density
    %if (strcmp(name, 'Tue_06_05_2014_11_42_15') || strcmp(name, 'Tue_06_05_2014_11_37_22'))
    if (SPLICING)
        if (cutLengthB2 > length(cleanDigitalIn2) - cutLengthE2)
            resting = (1*fs):(cutLengthB2 - 1 * fs);
        else
            resting = (cutLengthE2 + 1 * fs):(-1*fs+length(cleanDigitalIn2));
        end
        %fprintf('Baseline: %d %d\n', resting(1), resting(end)); % print timestep during resting state
        fprintf('SPLICING\n');
        fprintf('Baseline: %f\n', (resting(end) - resting(1)) / fs); % print timestep during resting state
        [lpxx, f, lpxxc] = pwelch(chData2(resting), blackmanharris(windlength), noverlap, windlength, fs, 'ConfidenceLevel', 0.95);
        % power spectral density during resting state
        ctrPSDs = lpxx;
        confMeanCtr = lpxxc';
    else
        if (cutLengthB > length(cleanDigitalIn) - cutLengthE)
            resting = (1*fs):(cutLengthB - 1 * fs);
        else
            resting = (cutLengthE + 1 * fs):(-1*fs+length(cleanDigitalIn));
        end
        %fprintf('Baseline: %d %d\n', resting(1), resting(end)); % print timestep during resting state
        fprintf('Baseline: %f\n', (resting(end) - resting(1)) / fs); % print timestep during resting state
        [lpxx, f, lpxxc] = pwelch(chData(resting), blackmanharris(windlength), noverlap, windlength, fs, 'ConfidenceLevel', 0.95);
        % power spectral density during resting state
        ctrPSDs = lpxx;
        confMeanCtr = lpxxc';
    end

    % ratio of experimental psd to resting psd
    ratio = expPSDs ./ ctrPSDs;
    ratio = ctrPSDs;
    
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
    if strcmp(channelNames(ii), 'Endo')
        color = CM(ii,:) + 0.6 * (1 - CM(ii,:)); % special color for endo
    end
    % Display faded data in background (not near 60 Hz or stimulus harmonics)
    %plot(f(~isnan(ratio)) / 1000, ratio(~isnan(ratio)),'color', color,'linewidth',1);
    plot(f(~isnan(ratio)), ratio(~isnan(ratio)),'color', color,'linewidth',1);
    
    axis tight;

end

%% Plot harmonic data

% Plot line for each harmonic
for ii=1:size(data, 1)
    % set 60 Hz harmonics to nan
    valid = ~any(abs(mod(repmat(f_harmonic{ii}, 2, 1), 60) + repmat([0;-60], 1, numel(f_harmonic{ii}))) <= threshold_60, 1);
    ratio_harmonic{ii}(~valid) = nan;
    %plot(f_harmonic{ii}(valid) / 1000, ratio_harmonic{ii}(valid),'color',CM(ii,:),'linewidth',5);
    plot(f_harmonic{ii}(valid), ratio_harmonic{ii}(valid),'color',CM(ii,:),'linewidth',5);
end

% Put point on each harmonic
for ii=1:size(data, 1)
    if (harmonic_points)
        % scatter(f_harmonic{ii} / 1000, ratio_harmonic{ii},10^2,[0 0 0], 'fill');
        % scatter(f_harmonic{ii} / 1000, ratio_harmonic{ii},6^2,CM(ii,:), 'fill');
        scatter(f_harmonic{ii}, ratio_harmonic{ii},10^2,[0 0 0], 'fill');
        scatter(f_harmonic{ii}, ratio_harmonic{ii},6^2,CM(ii,:), 'fill');
    end
end

%% Figure formatting

xlim(xrange);
ylim(yrange);

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
xlabel('Frequency (Hz)');
ylabel('p_{exp} / p_{rest}');
xlabh = get(gca,'XLabel');
%set(xlabh,'Position',get(xlabh,'Position') - [0 0.020 0]);
set(xlabh,'Position',get(xlabh,'Position') ./ [1 (yrange(2) / yrange(1)) ^ 0.05 1]);
ylabh = get(gca,'YLabel');
%set(ylabh,'Position',get(ylabh,'Position') - [0.070 0 0]);
set(ylabh,'Position',get(ylabh,'Position') - [0.10 * diff(xrange) 0 0]);
% set size of tick labels
set(gca,'FontSize',font_size);
%set size of labels
set(findall(fgh,'type','text'),'fontSize',font_size,'fontWeight','normal', 'color', [0 0 0]);
% fake white title to keep size of figures same when using pdfcrop (with ylabel vs. without y label)
title('|', 'color', 'white', 'fontsize', font_size);

% Save labelled version of figure
saveas(fgh, ['figures/' name '_labelled.fig']);
plot2svg(['figures/' name '_labelled.svg'], fgh, 'png');
save2pdf(['figures/' name '_labelled.pdf'], fgh, 150);
% save2pdf messes up settings
set(0,'defaultAxesFontName', 'SansSerif');
set(0,'defaultTextFontName', 'SansSerif');
set(0,'DefaultAxesFontSize', 20);
set(0,'DefaultTextFontSize', 20);

%% Figure with no labels
% Remove labels on ticks for y axis
set(gca, 'YTickLabel', {});
% Set text color to white
set(findall(fgh,'type','text'),'fontSize',font_size,'fontWeight','normal', 'color', [1 1 1]);
% remove label for y axis
ylabel('');

% Save unlabelled version of figure
saveas(fgh, ['figures/' name '.fig']);
plot2svg(['figures/' name '.svg'], fgh, 'png');
save2pdf(['figures/' name '.pdf'], fgh, 150);
% save2pdf messes up settings
set(0,'defaultAxesFontName', 'SansSerif');
set(0,'defaultTextFontName', 'SansSerif');
set(0,'DefaultAxesFontSize', 20);
set(0,'DefaultTextFontSize', 20);


end

