% plot_all_ssavep.m
%
% Script to load and plot (using plot_ssavep.m) all of the SSAEP or SSVEP
% trials in a directory. The same type of plots are generated for both SSAEP
% and SSVEP, so there is no difference in the code.
%
% Arguments:
%   ssavep: either 'ssaep' or 'ssvep' (string) - selects which experiment to plot
%   subject_ID: string with the name of the subject
%     - 'subject1' or 'subject2'
%   publication_quality: either 1 or 2, 1 is supposed to plot confidence
%                        intervals (not functional as of 8/6/14), 2 does not
%                        plot confidence intervals (is functional)
%                        [optional - defaults to 2]
%   index_list: list of indices to plot
%                [optional - defaults to all experiments]
%   filters: filters to apply to all analog channels other than cardiac
%     [default: only high-pass filter]
%   cardiac_filters: filters to apply to cardiac channel
%     [default: only high-pass filter]
%
% Output:
%   No return value.
%   Figures are saved as FIG, PDF, and SVG files in figures/.

function plot_all_ssavep(ssavep, subject_ID, publication_quality, index_list, filters, cardiac_filters)


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
if (nargin < 3) || isempty(publication_quality)
    publication_quality = 2;
end

% Default index_list is to plot everything available
if (nargin < 4) || isempty(index_list)
    index_list = 1:numel(files);
end

% Default filters is to only use high-pass filter
% Note: allow filters to be empty (do not enforce default)
if (nargin < 5)
    filters = get_filters(original_sampling_rate_in_Hz, true, false, false, false, false);
end

% Default cardiac)filters is to only use high-pass filter
% Note: allow filters to be empty (do not enforce default)
if (nargin < 6)
    cardiac_filters = get_filters(original_sampling_rate_in_Hz, true, false, false, false, false);
end

% Information about how to compute power spectral density
windlengthSeconds = 2;  % window length in seconds
noverlapPercent = 0.25; % number overlap percent

%% Generate the plots
for i = index_list

    % Print progress
    filename = files{i};
    fprintf('%d / %d:\t%s\n', i, length(files), filename);

    % Load analog channels from electrode and digital in (LED on / off)
    [ data, cleanDigitalIn ] = load_data([pathname filename], maxNumberOfChannels, digitalInCh, channelNames);

    % Plot SSAEP/SSVEP response
    plot_ssavep(data, cleanDigitalIn, files{i}, ssavep, original_sampling_rate_in_Hz, publication_quality, windlengthSeconds, noverlapPercent, filters, cardiac_filters, channelToPlot, CM, comments(i))

    close all;

end % for i = index_list

end % function [] = plot_all_ssavep

