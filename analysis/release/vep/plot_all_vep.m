% plot_all_vep.m
%
% Script to load and plot (using plot_vep.m) all of the VEP trials in a
% directory.
%
% Arguments:
%   subject_ID: string with the name of the subject
%     - 'subject1' or 'subject2'
%   publication_quality: style of the plots
%     - 1: shaded confidence intervals
%         WARNING: MATLAB appears to have a bug that causes figures with
%                  shading to be saved improperly as PDF and EPS files.
%                  plot2svg.m is an alternative method of saving, which
%                  avoids the problem.
%     - 2: no confidence intervals
%     - 3: dashed line for confidence intervals
%     - 4: all trials rather than confidence intervals
%     [default: 2]
%   index_list: list of indices to plot
%     [default: plot all available recordings for subject]
%   filter_cardiac: whether or not to perform cardiac removal
%     [default: true]
%   preEventPlot_sec: number of seconds before event to start plotting
%     [default: 0.05]
%   postEventPlot_sec: number of seconds after event to stop plotting
%     [default: 0.1]
%   filters: filters to apply to all analog channels other than cardiac
%     [default: only high-pass filter]
%   cardiac_filters: filters to apply to cardiac channel
%     [default: only high-pass filter]
%
% Output:
%   No return value.
%   Figures are saved as FIG and SVG files in figures/.

function [] = plot_all_vep(subject_ID, publication_quality, index_list, filter_cardiac, preEventPlot_sec, postEventPlot_sec, filters, cardiac_filters)


%% Preliminary information about data

% Information about recording 
[ maxNumberOfChannels, digitalInCh, original_sampling_rate_in_Hz, channelNames, gtechGND, earth ] = subject_information(subject_ID);

% Load names of data files and experiment log
[ pathname, pathname_comments ] = get_pathname(subject_ID, 'vep');
[ files, comments ] = get_information(pathname, pathname_comments, 'vep');

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

% Default preEventPlot_sec is to plot 0.05 seconds (50 ms) before event
if (nargin < 5) || isempty(preEventPlot_sec)
    preEventPlot_sec = 0.05;
end

% Default postEventPlot_sec is to plot 0.1 seconds (100 ms) after event
if (nargin < 6) || isempty(postEventPlot_sec)
    postEventPlot_sec = 0.1;
end

% Default filters is to only use high-pass filter
% Note: allow filters to be empty (do not enforce default)
if (nargin < 7)
    filters = get_filters(original_sampling_rate_in_Hz, true, false, false, false, false);
end

% Default cardiac)filters is to only use high-pass filter
% Note: allow filters to be empty (do not enforce default)
if (nargin < 8)
    cardiac_filters = get_filters(original_sampling_rate_in_Hz, true, false, false, false, false);
end


%% Generate the plots
for i = index_list

    % Print progress
    filename = files{i};
    fprintf('%d / %d:\t%s\n', i, length(files), filename);

    % Load analog channels from electrode and digital in (LED on / off)
    [ data, cleanDigitalIn ] = load_data([pathname filename], maxNumberOfChannels, digitalInCh, channelNames);

    % Plot VEP On Response
    plot_vep(data, cleanDigitalIn, files{i}, original_sampling_rate_in_Hz, publication_quality, filter_cardiac, 'On', preEventPlot_sec, postEventPlot_sec, filters, cardiac_filters, channelToPlot, CM, comments{i});
    % Plot VEP Off Response
    plot_vep(data, cleanDigitalIn, files{i}, original_sampling_rate_in_Hz, publication_quality, filter_cardiac, 'Off', preEventPlot_sec, postEventPlot_sec, filters, cardiac_filters, channelToPlot, CM, comments{i});

    close all;

end % for i = index_list

end % function [] = plot_all_vep

