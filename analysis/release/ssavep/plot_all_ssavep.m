% plot_all_ssavep.m
%
% Description: This script processes the paper figures for the SSAEP
%              experiments or the SSVEP experiments.
%
% Arguments:
%   ssavep: either 'ssaep' or 'ssvep' (string) - selects which experiment to plot
%   rabbit_ID: string ('9rabbit_may_6_2014' or '10rabbit_may_15_2014')
%   publication_quality: either 1 or 2, 1 is supposed to plot confidence
%                        intervals (not functional as of 8/6/14), 2 does not
%                        plot confidence intervals (is functional)
%                        [optional - defaults to 2]
%   trials_list: list of indices to plot
%                [optional - defaults to all experiments]
%
% Output: Figures are saved as PDFs in matlab_data.

function plot_all_ssavep(ssavep, rabbit_ID, publication_quality, trials_list)

[ maxNumberOfChannels, digitalInCh, original_sampling_rate_in_Hz ] = constants();

pathname = ['../../../../data/easter/' rabbit_ID '/neuro/binary_data/' ssavep '/'];%path for the data in easter binary format
pathname_comments = ['../../../../data/easter/' rabbit_ID '/neuro/neuro_experiment_log.txt'];%file containing comments written on the experiment day to use as labels for the figure titles
                                                                           % read the comments written on the experiment day to use as labels for the figure titles
                                                                           % each line correspondes to a single run of the VEP experiment
                                                                           % this file needs to be prepared by hand
                                                                           % the total # of lines should equal the number of VEP sessions
                                                                           % the ordering of comments needs to be chronological
                                                                           % example lines:
                                                                           % 12:30 This is the comment about this particular session. g.tech Ground was nose.
                                                                           % 12:45 This was the next condition. Used Faraday cage. g.tech Ground was right leg.

[ channelNames, gtechGND, earth ] = rabbit_information(rabbit_ID);

[ S, allData ] = get_information(pathname, pathname_comments, upper(ssavep));

% Default for publication_quality argument
if (nargin < 3)
    publication_quality = 2;
end

% Default for trials_list argument
if (nargin < 4)
    trials_list = 1:numel(S);
end

windlengthSeconds = 2;
noverlapPercent = 0.25; % number overlap percent

[ channelToPlot, CM ] = plot_settings();

filters = get_filters(original_sampling_rate_in_Hz, true, false, false, false, false);
cardiac_filters = get_filters(original_sampling_rate_in_Hz, true, false, false, false, false);

for i = trials_list
    filename = S{i};
    fprintf('filename: %s,\t%d / %d\n', filename, i, length(S));

    [ data, cleanDigitalIn ] = load_data([pathname filename], maxNumberOfChannels, digitalInCh, channelNames);

    publish_ssavep(data, original_sampling_rate_in_Hz, windlengthSeconds, noverlapPercent, cleanDigitalIn, channelToPlot, filters, CM, ssavep, filename, allData(i), publication_quality, clean_name(S{i}), cardiac_filters);

    close all;

end

