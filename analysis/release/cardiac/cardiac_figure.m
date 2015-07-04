function [ f_start, f_end, f1, f2, f3, f4, f5 ] = cardiac_figure(subject_ID, experiment, index, interval, filters, cardiac_filters)
%CARDIAC_FIGURE  Generates figures demonstrating removal of cardiac artifacts.
%
%   [ FS, FE, F1, F2, F3, F4, F5 ] = CARDIAC_FIGURE(SUBJECT_ID, EXPERIMENT, ...
%                                                   INDEX, INTERVAL, FILTERS, ...
%                                                   CARDIAC_FILTERS)
%
% Parameters:
%
%   SUBJECT_ID is a string with the name of the subject (subject1 or subject2).
%
%   EXPERIMENT is a string with the name of the experiment to use (vep, ssaep,
%   or ssvep).
%
%   INDEX is the trial number of this experiment to plot.
%
%   INTERVAL is the time interval in seconds to plot the example contaminated
%   and cleaned signal for.
%
%   FILTERS is a list of filters to apply to all analog channels other than
%   the cardiac channel.
%
%   CARDIAC_FILTERS is a list of filters to apply to the cardiac channel.
%
% Output:
%
%   FS is the figure handle for the starting, contaminated example signal.
%
%   FE is the figure handle for the ending, cleaned example signal.
%
%   F1 is the figure handle for the plot of the cardiac signal with the
%   detected peaks.
%
%   F2 is the figure handle for the plot of the time between the detected
%   peaks.
%
%   F3 is the figure handle for the plot of the time between complexes.
%
%   F4 is the figure handle for the plot of the averaged complexes and
%   confidence intervals for the averages.
%
%   F5 is the figure handle for the plot of all of the complexes, aligned to
%   the detected R peak.
%
%   Figures are saved as PDF, SVG, and FIG files in the directory figures.


%% Constants

% Figure window size
width = 275;   % width of figure (just plot itself, not labels)
height = 225;  % height of figure (just plot itself, not labels)
margins = 100; % extra space for labels
position = [0 0 (width + 2 * margins) (height + 2 * margins)];

% Axes for figure
xrange = [0 1000];
yrange = [-200, 200];                         % y-axis limits for figure
xticks = linspace(xrange(1), xrange(end), 5); % tick marks on x-axis
yticks = [-200, -100, 0, 100, 200];           % tick marks on y-axis

% Figure formatting
font_size = 20; % size of labels on figure
cardiac_scale = 0.20; % scale for cardiac channel


%% Preliminary information about data

% Information about recording 
[ numChannels, digitalCh, fs, channelNames, GND, earth ] = subject_information(subject_ID);

% Load names of data files and experiment log
[ pathname, experiment_log ] = get_pathname(subject_ID, experiment);
[ files, comments ] = get_information(pathname, experiment_log, experiment);

% Get list of channels to plot and colors for each channel
[ channelToPlot, CM ] = plot_settings();

% Specify which section of data to plot
time = (interval(1) * fs):(interval(2) * fs); % indices to be plotted
time_axis = (time - time(1)) / fs * 1000;       % timestamps to show on plot (ms)


%% Set necessary default values

% Default filters is to only use high-pass filter
% Note: allow filters to be empty (do not enforce default)
if (nargin < 5)
    filters = get_filters(fs, true, false, false, false, false);
end

% Default cardiac filters is to only use high-pass filter
% Note: allow cardiac_filters to be empty (do not enforce default)
if (nargin < 6)
    cardiac_filters = get_filters(fs, true, false, false, false, false);
end


%% Loading data
filename = files{index};

% Load analog channels from electrode and digital in (LED on / off)
data_all = load_data([pathname filename], numChannels);                % data from all channels
cleanDigitalIn = (data_all(digitalCh, :) > 0);                         % binary digital in channel
data = data_all(channelToPlot, :);                                     % data for relevant channels
cardiac_data = data_all(strcmp(channelNames, 'Bottom Precordial'), :); % cardiac channel for removal of cardiac artifacts
cardiac_data = run_filters(cardiac_data, cardiac_filters);             % filter cardiac data


%% Preparing figures

% Open invisible screens for figures
f_start = figure('Color',[1 1 1],'units','pixels','position',position, 'visible', 'on'); axes('units', 'pixel', 'position', [margins margins width height]); box on;
f_end   = figure('Color',[1 1 1],'units','pixels','position',position, 'visible', 'on'); axes('units', 'pixel', 'position', [margins margins width height]); box on;
f1      = figure('Color',[1 1 1],'units','pixels','position',position, 'visible', 'on'); axes('units', 'pixel', 'position', [margins margins width height]); box on;
f2      = figure('Color',[1 1 1],'units','pixels','position',position, 'visible', 'on'); axes('units', 'pixel', 'position', [margins margins width height]); box on;
f3      = figure('Color',[1 1 1],'units','pixels','position',position, 'visible', 'on'); axes('units', 'pixel', 'position', [margins margins width height]); box on;
f4      = figure('Color',[1 1 1],'units','pixels','position',position, 'visible', 'on'); axes('units', 'pixel', 'position', [margins margins width height]); box on;

% Plot vertical bar at time 0
set(0, 'CurrentFigure', f3);
plot([0 0], yrange, 'color', 'black', 'linewidth', 2);

% Plot vertical bar at time 0
set(0, 'CurrentFigure', f4);
plot([0 0], yrange, 'color', 'black', 'linewidth', 2);

% Plot scaled cardiac data
set(0, 'CurrentFigure', f_start);
hold on;
plot(time_axis, cardiac_scale * cardiac_data(time), 'LineWidth', 2, 'Color', [0, 0.75, 0]);

% Plot scaled cardiac data
set(0, 'CurrentFigure', f_end);
hold on;
plot(time_axis, cardiac_scale * cardiac_data(time), 'LineWidth', 2, 'Color', [0, 0.75, 0]);


%% Plot cardiac channel
cardiac_removal(cardiac_scale * cardiac_data, cardiac_data, fs, [0, 0.75, 0], f1, f2, f3, f4);


%% Plot all other channels
for ii=1:length(channelToPlot)

    % Print progress
    fprintf('ii: %d, %d\n', ii, channelToPlot(ii));

    chData = data(ii, :);                  % get this channel
    chData = run_filters(chData, filters); % Apply filters

    % Plot original contaminated data
    set(0, 'CurrentFigure', f_start);
    plot(time_axis, chData(time), 'LineWidth', 2, 'Color', CM(ii, :));

    % Remove cardiac artifacts and generate plots
    chData = cardiac_removal(chData, cardiac_data, fs, CM(ii, :), 0, 0, f3, f4);

    % Plot cleaned data
    set(0, 'CurrentFigure', f_end);
    plot(time_axis, chData(time), 'LineWidth', 2, 'Color', CM(ii, :));

end


%% Label starting and ending example data figures
for f = [f_start, f_end]
    set(0, 'CurrentFigure', f);
    xlim(xrange);
    ylim(yrange);
    xlabel('Time (ms)');
    ylabel('$\mu V$', 'interpreter', 'LaTeX');
    xlabh = get(gca,'XLabel');
    set(xlabh,'Position',get(xlabh,'Position') - [0 0.10 * diff(yrange) 0]);
    ylabh = get(gca,'YLabel');
    set(ylabh,'Position',get(ylabh,'Position') - [0.10 * diff(xrange) 0 0]);
    set(gca,'XTick',xticks);
    set(gca,'YTick',yticks);
    set(findall(f_start,'type','text'),'fontSize',font_size,'fontWeight','normal', 'color', [0,0,0]);
    set(gca,'FontSize',font_size);
end


%% Save figures

saveas(f1, ['figures/' filename '_r_peak.fig']);

saveas(f2, ['figures/' filename '_dt.fig']);
save2pdf(['figures/' filename '_dt.pdf'], f2, 150);

plot2svg(['figures/' filename '_cardiac_aligned.svg'], f3, 'png')

save2pdf(['figures/' filename '_cardiac_aligned_all.pdf'], f4, 150);

save2pdf(['figures/' filename '_start.pdf'], f_start, 150);
save2pdf(['figures/' filename '_end.pdf'], f_end, 150);

plot2svg(['figures/' filename '_cardiac_aligned_all.svg'], f4, 'png');
plot2svg(['figures/' filename '_start.svg'], f_start, 'png');
plot2svg(['figures/' filename '_end.svg'], f_end, 'png');

