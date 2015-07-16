function [] = plot_all_ssavep(ssavep, subject_ID, index_list, filter_cardiac, filters, cardiac_filters)
%PLOT_ALL_SSAVEP  Loads and plots SSAEP and SSVEP frequency responses.
%
%   PLOT_ALL_SSAVEP(SSAVEP, SUBJECT_ID, INDEX_LIST, FILTERS, CARDIAC_FILTERS)
%
%   SSAVEP is a string that selects which experiment to plot (ssaep or ssvep).
%
%   SUBJECT_ID is a string with the name of the subject (subject1 or subject2).
%
%   INDEX_LIST is a list of indices to plot for this experiment on this
%   subject (ordered based on time).
%     [default: plot all recordings for this experiment on this subject]
%
%   FILTER_CARDIAC is a boolean value that indicates whether or not to perform
%   removal of cardiac artifacts.
%     [default: true]
%
%   FILTERS is a list of filters to apply to all analog channels other than
%   the cardiac channel.
%     [default: only high-pass filter]
%
%   CARDIAC_FILTERS is a list of filters to apply to the cardiac channel.
%     [default: only high-pass filter]

% Output:
%
%   No return value.
%
%   Figures are saved as FIG, PDF, and SVG files in figures/.
%
% See also PLOT_SSAVEP.


%% Constants

% Information about how to compute power spectral density
windlengthSeconds = 2;  % window length in seconds
noverlapPercent = 0.25; % number overlap percent


%% Preliminary information about data

% Information about recording 
[ numChannels, digitalCh, fs, channelNames, GND, earth ] = subject_information(subject_ID);

% Load names of data files and experiment log
[ pathname, experiment_log ] = get_pathname(subject_ID, ssavep);
[ files, comments ] = get_information(pathname, experiment_log, ssavep);
comments = {'1', '2', '3', '4'};
comments = {'11:14:51 - SSVEP 40 Hz, experiment, electrode = X-pedion-10 @ catheter tip, position = basilar tip', '11:23:01 - SSVEP 40 Hz, live-animal-control, electrode = X-pedion-10 @ catheter tip, position = basilar tip', '15:48:24 - SSVEP 40 hz, experiment, electrode =  guidewire @ catheter tip, position = basilar tip', '15:48:24 - SSVEP 40 hz, experiment, electrode =  guidewire @ catheter tip, position = basilar tip', '15:48:24 - SSVEP 40 hz, experiment, electrode =  guidewire @ catheter tip, position = basilar tip', '15:48:24 - SSVEP 40 hz, experiment, electrode =  guidewire @ catheter tip, position = basilar tip'}

% Get list of channels to plot and colors for each channel
[ channelToPlot, CM ] = plot_settings();
endo = strcmp(channelNames(channelToPlot), 'Endo');

CMi = CM;
CMi(endo, :) = [1.0 0.0 0.0];
CMi(~endo, :) = repmat([0.0 1.0 0.0], sum(~endo), 1);
CMf = CM;
CMf(endo, :) = [0.0 0.0 0.0];
CMf(~endo, :) = repmat([0.0 0.0 1.0], sum(~endo), 1);

if (strcmp(subject_ID, 'subject1') == 1)
  pathnames = {'data/subject1/ssvep/', 'data/subject1/ssaep/', 'data/subject1/ssaep/', 'data/subject1/ssvep/', 'data/subject1/ssaep/', 'data/subject1/ssaep/'};
  files = {'Thu_15_05_2014_12_08_22', 'Thu_15_05_2014_12_28_28', 'Thu_15_05_2014_12_31_02', 'Thu_15_05_2014_16_38_47', 'Thu_15_05_2014_16_54_15', 'Thu_15_05_2014_16_58_34'};
  CMs = {CMi, lighten(CMi, 0.25), lighten(CMi, 0.5), CMf, lighten(CMf, 0.25), lighten(CMf, 0.5)};
else
  pathnames = {'data/subject2/ssvep/', 'data/subject2/ssaep/', 'data/subject2/ssaep/', 'data/subject2/ssvep/', 'data/subject2/ssaep/', 'data/subject2/ssaep/'};
  files = {'Tue_06_05_2014_11_14_51', 'Tue_06_05_2014_11_31_23', 'Tue_06_05_2014_11_37_22', 'Tue_06_05_2014_15_48_24', 'Tue_06_05_2014_15_55_07', 'Tue_06_05_2014_15_57_52'};
  CMs = {CMi, lighten(CMi, 0.25), lighten(CMi, 0.5), CMf, lighten(CMf, 0.25), lighten(CMf, 0.5)};
end


%% Set necessary default values

% Default index_list is to plot everything available
if (nargin < 3) || isempty(index_list)
    index_list = 1:numel(files);
end

% Default filter_cardiac is to remove cardiac artifacts
if (nargin < 4) || isempty(filter_cardiac)
    filter_cardiac = true;
end

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


%% Generate the plots
fgh = -1;
for i = index_list
    final = (i == index_list(end));

    % Print progress
    pathname = pathnames{i};
    filename = files{i};
    CM = CMs{i};
    fprintf('%d / %d:\t%s\n', i, length(files), filename);

    % Load analog channels from electrode and digital in (experiment active)
    [ data, cleanDigitalIn ] = load_data([pathname filename], numChannels);
    data_all = load_data([pathname filename], numChannels);                % data from all channels
    cleanDigitalIn = (data_all(digitalCh, :) > 0);                         % binary digital in channel
    data = data_all(channelToPlot, :);                                     % data for relevant channels
    cardiac_data = []; % empty array if no cardiac artifact filtering
    if (filter_cardiac)
        % cardiac channel for removal of cardiac artifacts
        cardiac_data = data_all(strcmp(channelNames, 'Bottom Precordial'), :);
    end

    % Plot SSAEP/SSVEP response
    if (strcmp(filename, 'Tue_06_05_2014_11_37_22'))
        [ data2, cleanDigitalIn2 ] = load_data([pathname 'Tue_06_05_2014_11_31_23'], numChannels);
        data_all2 = load_data([pathname 'Tue_06_05_2014_11_31_23'], numChannels);                % data from all channels
        cleanDigitalIn2 = (data_all2(digitalCh, :) > 0);                         % binary digital in channel
        data2 = data_all2(channelToPlot, :);                                     % data for relevant channels
        cardiac_data2 = []; % empty array if no cardiac artifact filtering
        if (filter_cardiac)
            % cardiac channel for removal of cardiac artifacts
            cardiac_data2 = data_all2(strcmp(channelNames, 'Bottom Precordial'), :);
        end
        fgh = plot_ssavep_baseline(data, fgh, final, cleanDigitalIn, filename, ssavep, fs, cardiac_data, windlengthSeconds, noverlapPercent, filters, cardiac_filters, CM, channelNames(channelToPlot), comments(i), data2, cleanDigitalIn2, cardiac_data2);
    else if (strcmp(filename, 'Tue_06_05_2014_11_42_15'))
        [ data2, cleanDigitalIn2 ] = load_data([pathname 'Tue_06_05_2014_11_39_46'], numChannels);
        data_all2 = load_data([pathname 'Tue_06_05_2014_11_39_46'], numChannels);                % data from all channels
        cleanDigitalIn2 = (data_all2(digitalCh, :) > 0);                         % binary digital in channel
        data2 = data_all2(channelToPlot, :);                                     % data for relevant channels
        cardiac_data2 = []; % empty array if no cardiac artifact filtering
        if (filter_cardiac)
            % cardiac channel for removal of cardiac artifacts
            cardiac_data2 = data_all2(strcmp(channelNames, 'Bottom Precordial'), :);
        end
        fgh = plot_ssavep_baseline(data, fgh, final, cleanDigitalIn, filename, ssavep, fs, cardiac_data, windlengthSeconds, noverlapPercent, filters, cardiac_filters, CM, channelNames(channelToPlot), comments(i), data2, cleanDigitalIn2, cardiac_data2);
    else
      fgh = plot_ssavep_baseline(data, fgh, final, cleanDigitalIn, filename, ssavep, fs, cardiac_data, windlengthSeconds, noverlapPercent, filters, cardiac_filters, CM, channelNames(channelToPlot), comments(i));
    end

    %close all;

end % for i = index_list

end % function plot_all_ssavep

