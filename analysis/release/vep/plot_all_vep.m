function [] = plot_all_vep(subject_ID, publication_quality, index_list, filter_cardiac, preEventPlot_sec, postEventPlot_sec, filters, cardiac_filters)
%PLOT_ALL_VEP  Loads and plots VEP on/off responses.
%
%   PLOT_ALL_VEP(SUBJECT_ID, PUBLICATION_QUALITY, INDEX_LIST, FILTER_CARDIAC, ...
%                PREEVENTPLOT_SEC, POSTEVENTPLOT_SEC, FILTERS, CARDIAC_FILTERS)
%
% Parameters:
%
%   SUBJECT_ID is a string with the name of the subject (subject1 or subject2).
%
%   PUBLICATION_QUALITY is an integer specifying the style of the plots.
%     - 1: shaded confidence intervals
%         WARNING: MATLAB appears to have a bug that causes figures with
%                  shading to be saved improperly as PDF and EPS files.
%                  PLOT2SVG is an alternative method of saving, which
%                  avoids the problem.
%     - 2: no confidence intervals
%     - 3: dashed line for confidence intervals
%     - 4: all trials rather than confidence intervals
%     [default: 2]
%
%   INDEX_LIST is a list of indices to plot for this subject (ordered based
%   on time).
%     [default: plot all recordings for this experiment on this subject]
%
%   FILTER_CARDIAC is a boolean value that indicates whether or not to perform
%   removal of cardiac artifacts.
%     [default: true]
%
%   PREEVENTPLOT_SEC is the number of seconds before the event to start plot.
%     [default: 0.05]
%
%   POSTEVENTPLOT_SEC is the number of seconds after the event to stop plot.
%     [default: 0.1]
%
%   FILTERS is a list of filters to apply to all analog channels other than
%   the cardiac channel.
%     [default: only high-pass filter]
%
%   CARDIAC_FILTERS is a list of filters to apply to the cardiac channel.
%     [default: only high-pass filter]
%
% Output:
%
%   No return value.
%
%   Figures are saved as FIG and SVG files in the directory figures.
%
% See also PLOT_VEP, PLOT2SVG.


%% Preliminary information about plotting

% Information about recording 
[ numChannels, digitalCh, fs, channelNames, GND, earth ] = subject_information(subject_ID);

% Load names of data files and experiment log
[ pathname, experiment_log ] = get_pathname(subject_ID, 'vep');
[ files, comments ] = get_information(pathname, experiment_log, 'vep');

% Get list of channels to plot and colors for each channel
[ channelToPlot, CM ] = plot_settings();


%% Set necessary default values

% Default publication quality is no confidence intervals
if (nargin < 2) || isempty(publication_quality)
    publication_quality = 2;
end

% Default index_list is to plot everything available
if (nargin < 3) || isempty(index_list)
    index_list = 1:numel(files);
end

% Default filter_cardiac is to remove cardiac artifacts
if (nargin < 4) || isempty(filter_cardiac)
    filter_cardiac = true;
end

% Default preEventPlot_sec is to start plot 0.05 seconds (50 ms) before event
if (nargin < 5) || isempty(preEventPlot_sec)
    preEventPlot_sec = 0.05;
end

% Default postEventPlot_sec is to end plot 0.1 seconds (100 ms) after event
if (nargin < 6) || isempty(postEventPlot_sec)
    postEventPlot_sec = 0.1;
end

% Default filters is to only use high-pass filter
% Note: allow filters to be empty (do not enforce default)
if (nargin < 7)
    filters = get_filters(fs, true, false, false, false, false);
end

% Default cardiac filters is to only use high-pass filter
% Note: allow cardiac_filters to be empty (do not enforce default)
if (nargin < 8)
    cardiac_filters = get_filters(fs, true, false, false, false, false);
end


%% Generate the plots
for i = index_list

    % Print progress
    filename = files{i};
    fprintf('%d / %d:\t%s\n', i, length(files), filename);

    % Load analog channels from electrode and digital in (LED on / off)
    data_all = load_data([pathname filename], numChannels); % data from all channels
    cleanDigitalIn = (data_all(digitalCh, :) > 0);          % binary digital in channel
    data = data_all(channelToPlot, :);                      % data for relevant channels
    cardiac_data = []; % empty array if no cardiac artifact filtering
    if (filter_cardiac)
        % cardiac channel for removal of cardiac artifacts
        cardiac_data = data_all(strcmp(channelNames, 'Bottom Precordial'), :);
    end

    % Plot VEP On Response
    plot_vep(data, cleanDigitalIn, filename, fs, publication_quality, cardiac_data, 'On', preEventPlot_sec, postEventPlot_sec, filters, cardiac_filters, CM, channelNames(channelToPlot), comments{i});
    % Plot VEP Off Response
    plot_vep(data, cleanDigitalIn, filename, fs, publication_quality, cardiac_data, 'Off', preEventPlot_sec, postEventPlot_sec, filters, cardiac_filters, CM, channelNames(channelToPlot), comments{i});

    close all;

end % for i = index_list

end % function plot_all_vep

