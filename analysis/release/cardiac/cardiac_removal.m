function [ chData ] = cardiac_removal(chData, cardiacData, fs, color, f1, f2, f3, f4)
%CARDIAC_REMOVAL  Removes cardiac artifact from another channel.
%
% CHDATA = CARDIAC_REMOVAL(CHDATA, CARDIACDATA, FS, COLOR, F1, F2, F3, F4)
%
% Parameters:
%
%   CHDATA is an vector of data representing an analog channel from which to
%   remove cardiac artifacts. This channel must be highpass filtered for this
%   function to perform well.
%
%   CARDIACDATA is a vector of data representing a channel recording from a
%   cardiac electrode.
%
%   COLOR specifies which color to plot this channel in (if plots are
%   requested).
%
%   F1 is the figure handle for the plot of the cardiac signal with the
%   detected peaks.
%
%   F2 is the figure handle for the plot of the time between the detected
%   peaks.
%
%   F3 is the figure handle for the plot of the averaged complexes and
%   confidence intervals for the averages.
%
%   F4 is the figure handle for the plot of all of the complexes, aligned to
%   the detected R peak.
%
%   Note that any of F1, F2, F3, or F4 may be set to 0 or omitted if the plot
%   is not desired.
%
% Output:
%
%   CHDATA is the same as the original data, with cardiac artifacts filtered
%   out.


%% Constants
font_size = 10;    % font size for labels
min_time = 0.18;   % minimum valid amount of time between pulses in seconds
breakpoint = 0.63; % fraction of time after R peak to keep as part of this complex
                   % (fraction of complex between R peak and midpoint of P and T wave
beat_range = [150 300]; % range of time between heart beats to show (ms)
voltage_range = [-200 200]; % range of voltages to show for cardiac activity (uV)
voltage_ticks = [-200 -100 0 100 200]; % ticks for voltages (uV)

assert(all(size(chData) == size(cardiacData)));
[ ~, locs ] = findpeaks(cardiacData, 'minpeakdistance', round(min_time * fs));
% TODO: could take cardiac spikes as argument, rather than cardiacData

if (nargin >= 5 && f1 ~= 0)
    %% Plot Cardiac Data with Detected Peaks
    set(0, 'CurrentFigure', f1);
    hold on;

    % Get range of data
    yrange = [min(cardiacData), max(cardiacData)];

    % Plot the detected peaks (vertical lines)
    for i = 1:numel(locs)
        plot(locs(i) * [1 1] / fs, yrange, 'color', 'black');
    end

    % Plot the cardiac data
    plot((1:numel(cardiacData)) / fs, cardiacData, 'color', color);

    % Figure formatting and labelling
    xlim([0 numel(cardiacData) / fs]);
    ylim(yrange);
    xlabel('Time (seconds)');
    ylabel('$\mu V$', 'interpreter', 'LaTeX');
    set(findall(f1,'type','text'),'fontSize',font_size,'fontWeight','normal', 'color', [0 0 0]); % Mostly to get rid of the italics from latex
    title('Detected R Wave');
end

if (nargin >= 6 && f2 ~= 0)
    %% Plot Distance between R peaks
    set(0, 'CurrentFigure', f2);
    dt = diff(locs);
    scatter(1:numel(dt), dt / fs * 1000, 36, color);

    % Figure formatting and labelling
    xlim([0 numel(dt)]);
    ylim(beat_range);
    xlabel('Interval Number');
    ylabel('Interval Length (ms)');
    title('Time Between R Peaks');

    set(findall(f2,'type','text'),'fontSize',font_size,'fontWeight','normal', 'color', [0,0,0]);
    set(gca,'FontSize',font_size);
end

%% Compute interval (include first, exclude last)
cutoff = [1, locs(1:(end-1)) + round(breakpoint * diff(locs)), numel(chData) + 1];

%% Compute start, R peak, end, and length of each interval
r_peak = locs;
start = cutoff(1:(end-1));
finish = cutoff(2:end);

% Check that start, r_peak, and finish have same number of elements
assert(all(size(start) == size(r_peak)));
assert(all(size(start) == size(finish)));

assert(all(start < r_peak));  % start before peak
assert(all(r_peak < finish)); % peak before end

% Compute limit and "normal" times before / after peak
max_before = max(r_peak - start);
max_after = max(finish - r_peak);
median_before = median(r_peak - start);
median_after = median(finish - r_peak);

%% Gather and align the channel data
padded = zeros(numel(r_peak), max_before + max_after);
for i = 1:numel(r_peak)
    padded(i, (start(i):(finish(i)-1)) - r_peak(i) + max_before + 1) = chData(start(i):(finish(i)-1));
end

%% Check that every column/row has a non-nan value
assert(all(any(~isnan(padded), 1)));
assert(all(any(~isnan(padded), 2)));

%% Remove trials that have extreme values
invalid = any(abs(padded) > 1e3, 2); % for some reason after applying hpf/lpf/nf, first and last area have extreme values
num_invalid = sum(invalid);
assert(num_invalid < 15);            % check that few trials are removed
padded = padded(~invalid, :);        % keep only valid trials

%% Mean cardiac activity across trials
cardiac = nanmean(padded, 1);

if (nargin >= 7 && f3 ~= 0)
    %% Plot Mean and Confidence Interval

    % time centered with R peak at 0
    time_axis = ((1:numel(cardiac)) - max_before) / fs * 1000;

    % plot mean of cardiac activity
    set(0, 'CurrentFigure', f4);
    hold on;
    plot(time_axis, cardiac, 'color', color, 'linewidth', 2);

    % plot confidence intervals of mean
    confMean = bootci(100, @nanmean, padded);
    px = [time_axis, fliplr(time_axis)];
    py = [confMean(1,:), fliplr(confMean(2,:))];
    patch(px,py,1,'FaceColor',color,'EdgeColor','none');

    % Figure formatting and labelling
    xlim([-median_before, median_after] / fs * 1000);
    ylim(voltage_range);
    xlabel('Time (ms)');
    ylabel('$\mu V$', 'interpreter', 'LaTeX');
    set(gca,'YTick', voltage_ticks);
    set(findall(f3,'type','text'),'fontSize',font_size,'fontWeight','normal', 'color', [0,0,0]);
    set(gca,'FontSize',font_size);
end

if (nargin >= 8 && f4 ~= 0)
    %% Plot all curves

    % time centered with R peak at 0
    time_axis = ((1:numel(cardiac)) - max_before) / fs * 1000;

    % plot all cardiac activity trials
    set(0, 'CurrentFigure', f5);
    hold on;
    plot(time_axis, padded, 'color', color);

    xlim([-median_before, median_after] / fs);
    ylim(voltage_range);
    xlabel('Time (seconds)');
    ylabel('$\mu V$', 'interpreter', 'LaTeX');
    set(gca,'YTick', voltage_ticks);
    set(findall(f4,'type','text'),'fontSize',font_size,'fontWeight','normal', 'color', [0,0,0]);
    set(gca,'FontSize',font_size);
end

%% Remove cardiac activity
filtered_data = zeros(size(chData));
for i = 1:numel(r_peak)
    chData(start(i):(finish(i)-1)) = chData(start(i):(finish(i)-1)) - cardiac((start(i):(finish(i)-1)) - r_peak(i) + max_before + 1);
end

end

