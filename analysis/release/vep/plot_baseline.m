function [ fgh ] = plot_baseline(subject_ID)

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

% Default filter_card is to remove cardiac artifacts
if (nargin < 4) || isempty(filter_card)
    filter_card = true;
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


%pathname = 'data/subject1/vep/';
%files = {'Thu_15_05_2014_12_15_47', 'Thu_15_05_2014_17_22_22'};
if (strcmp(subject_ID, 'subject1') == 1)
  pathname = 'data/subject1/ssvep/';
  files = {'Thu_15_05_2014_12_08_22', 'Thu_15_05_2014_16_38_47'};
else
  pathname = 'data/subject2/ssvep/';
  files = {'Tue_06_05_2014_11_14_51', 'Tue_06_05_2014_15_48_24'};
end
index_list = 1:2;


%% Generate the plots
for i = index_list

    % Print progress
    filename = files{i};
    fprintf('%d / %d:\t%s\n', i, length(files), filename);

    % Load analog channels from electrode and digital in (LED on / off)
    data_all = load_data([pathname filename], numChannels); % data from all channels

    cleanDigitalIn = (data_all(digitalCh, :) > 0);          % binary digital in channel
    %finish = numel(cleanDigitalIn);
    finish = find(cleanDigitalIn == 1, 1, 'first') - 1;
finish = 5387 * 44;
    cleanDigitalIn = mod(floor((1:numel(data_all(digitalCh, :))) / 5387), 2);
    %diff(find(diff(cleanDigitalIn) ~= 0)) % 5387

    data = data_all(channelToPlot, :);                      % data for relevant channels

    cardiac_data = []; % empty array if no cardiac artifact filtering
    if (filter_card)
        % cardiac channel for removal of cardiac artifacts
        cardiac_data = data_all(strcmp(channelNames, 'Bottom Precordial'), :);
    end

    %finish
    %numel(cardiac_data)
    data = data(:, 1:finish);
    cleanDigitalIn = cleanDigitalIn(1:finish);
    cardiac_data = cardiac_data(1:finish);

    % Plot VEP On Response
    plot_vep(data, cleanDigitalIn, filename, fs, publication_quality, cardiac_data, 'On', preEventPlot_sec, postEventPlot_sec, filters, cardiac_filters, CM, channelNames(channelToPlot), comments{i});
    % Plot VEP Off Response
    plot_vep(data, cleanDigitalIn, filename, fs, publication_quality, cardiac_data, 'Off', preEventPlot_sec, postEventPlot_sec, filters, cardiac_filters, CM, channelNames(channelToPlot), comments{i});

    %close all;

end % for i = index_list

end

