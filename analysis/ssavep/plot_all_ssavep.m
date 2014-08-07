%plot_all_vep.m
%
%Authors: M. Ebrahimi, L. Srinivasan / nspl.org
%
%Date: 4/17/14
%
%Description: This script produces one VEP graph for each VEP data set recorded in experiment given by rabbit_ID
%
%Requires:  rabbit_ID - tag for the experiment, set in the hardcoded variables block below.
%
%Output:  One figure for each VEP session, with two panels, one for the 'on' response, one for the 'off' response.
%
%Notes:  The g.tech digital input, channel 65, goes high for LED ON with 5rabbit and 6rabbit, but low for LED ON with 7rabbit
%	 This is accounted for in arduino_vep.m, which checks the pathname for '7rabbit' and chooses the appropriate convention.
%	 In subsequent rabbits after 7rabbit, the arduino code in /code/easter/ should have been changed to reflect the intuitive
%	 convention used in 5rabbit and 6rabbit of channel 65 going high for LED ON.
%	
%	The analysis code assumes a fixed sampling rate of 9600 Hz and digital input channel # of 65 (both designated in arduino_vep.m)

function plot_all_ssavep(ssavep, rabbit_ID, publication_quality, trials_list)
%clear;
%close all;
addpath('../config')
addpath('../utilities')

%% Parameters

% rabbit_ID choices - which rabbit to plot
% rabbit_ID = '1rabbit_dec_10_2012';
% rabbit_ID = '2rabbit_jan_23_2013';
% rabbit_ID = '4rabbit_feb_5_2014';
% rabbit_ID = '5rabbit_mar_4_2014';
% rabbit_ID = '6rabbit_apr_11_2014';
% rabbit_ID = '7rabbit_apr_15_2014';
% rabbit_ID = '8rabbit_apr_24_2014';
% rabbit_ID = '9rabbit_may_6_2014';
% rabbit_ID = '10rabbit_may_15_2014';

% decimate the data to speed up plotting (decimate_factor = 1 is no decimation; 10 is reasonable)
% Not actually used right now (7/31/14)
% decimate_factor = 10;

%(this Matlab function implements proper downsampling using anti-aliasing, with decimate.m).
% generate the high quality figures with confidence intervals. this is much slower than having it set to zero
% 0:, 1:with confidence intervals , 2:without confidence intervals
%publication_quality = 2;

maxNumberOfChannels = 10;                                                  %# of consecutive analog input channels, starting with channel 1, to extract from the project easter binary files
                                                                           %(which contain 64 analog channels and the digital in channel (channel 65)

digitalInCh = 65;                                                          %designate the digital input channel, which is used to record
                                                                           %the LED state to align EEG data with onset or offset to generate VEP graphs 

original_sampling_rate_in_Hz = 9600;                                       % data is acquired with the g.Tech g.HiAmp at 9600 Hz. this is fixed for convenience. at higher rates, the 
                                                                           % digital input channel does not work reliably.

pathname = ['../../../../data/easter/' rabbit_ID '/neuro/binary_data/' ssavep '/'];%path for the data in easter binary format
%pathname_comments = ['../../../../data/easter/' rabbit_ID '/neuro/vep.txt'];%file containing comments written on the experiment day to use as labels for the figure titles
pathname_comments = ['../../../../data/easter/' rabbit_ID '/neuro/neuro_experiment_log.txt'];%file containing comments written on the experiment day to use as labels for the figure titles
                                                                           % read the comments written on the experiment day to use as labels for the figure titles
                                                                           % each line correspondes to a single run of the VEP experiment
                                                                           % this file needs to be prepared by hand
                                                                           % the total # of lines should equal the number of VEP sessions
                                                                           % the ordering of comments needs to be chronological
                                                                           % example lines:
                                                                           % 12:30 This is the comment about this particular session. g.tech Ground was nose.
                                                                           % 12:45 This was the next condition. Used Faraday cage. g.tech Ground was right leg.

pathname_matdata = ['../../../../data/easter/' rabbit_ID '/neuro/matlab_data/' ssavep '/'];

[ channelNames, gtechGND, earth ] = rabbit_information(rabbit_ID);

[ S, allData ] = get_information(pathname, pathname_comments, upper(ssavep));

if (nargin < 3)
    publication_quality = 2;
end

if (nargin < 4)
    trials_list = 1:numel(S);
end

%////////////////////////////////////////////////////////////////////////////////////////
% START BLOCK: Extract Data from Project Easter Binary Files to Prep for
% function call to arduino_vep.m
%////////////////////////////////////////////////////////////////////////////////////////
windlengthSeconds = 2;
noverlapPercent = 0.25;%windlength * 0.25; % number overlap percent

[ channelToPlot, CM ] = plot_settings();

filters = get_filters(original_sampling_rate_in_Hz, true, false, false, false, false);


for i = trials_list
    close all;
    filename = S{i};
    fprintf('filename: %s,\t%d / %d\n', filename, i, length(S));

    [ data, cleanDigitalIn ] = load_data([pathname filename], maxNumberOfChannels, digitalInCh, channelNames);

    %figure;
    %hold on;
    %chData = data{2, 2};
    %%chData = run_filters(chData, filters);
    %plot((1:numel(chData))/9600, chData);
    %yl = ylim;
    %plot((1:numel(chData))/9600, (cleanDigitalIn * 0.8 + 0.1) * (yl(2) - yl(1)) + yl(1));

    publish_ssavep(data, original_sampling_rate_in_Hz, windlengthSeconds, noverlapPercent, cleanDigitalIn, channelToPlot, filters, CM, ssavep, filename, allData(i), publication_quality, clean_name(S{i}));
end

