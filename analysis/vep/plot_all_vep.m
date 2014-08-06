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

function plot_all_vep(rabbit_ID, publication_quality, trials_list)

addpath('../config');
addpath('../utilities');

%///////////////////////////////////////////////
% START BLOCK: Hardcoded variables
%///////////////////////////////////////////////
%rabbit_ID = '1rabbit_dec_10_2012';
%rabbit_ID = '2rabbit_jan_23_2013';
%rabbit_ID = '4rabbit_feb_5_2014';
%rabbit_ID = '5rabbit_mar_4_2014';
%rabbit_ID = '6rabbit_apr_11_2014';                                         %'7rabbit_apr_15_2014' corresponds to the experiment performed 4/15/14
%rabbit_ID = '7rabbit_apr_15_2014';                                         %'7rabbit_apr_15_2014' corresponds to the experiment performed 4/15/14
%rabbit_ID = '8rabbit_apr_24_2014';
%rabbit_ID = '9rabbit_may_6_2014';
%rabbit_ID = '10rabbit_may_15_2014';

%publication_quality = 3;                                                   % generate the high quality figures with confidence intervals. this is much slower than having it set to zero
                                                                           % 0:, 1:with confidence intervals , 2:without confidence intervals, 3: use dashed lines instead of transparent ares for confidence areas
% TODO: for some reason, publication quality 1 (shaded confidence intervals) does not save properly to pdf or eps

decimate_factor = 10;                                                      % decimate the data to speed up plotting (decimate_factor = 1 is no decimation; 10 is reasonable)
                                                                           %(this Matlab function implements proper downsampling using anti-aliasing, with decimate.m).


maxNumberOfChannels = 10;                                                  %# of consecutive analog input channels, starting with channel 1, to extract from the project easter binary files
                                                                           %(which contain 64 analog channels and the digital in channel (channel 65)

digitalInCh = 65;                                                          %designate the digital input channel, which is used to record
                                                                           %the LED state to align EEG data with onset or offset to generate VEP graphs 

original_sampling_rate_in_Hz = 9600;                                       % data is acquired with the g.Tech g.HiAmp at 9600 Hz. this is fixed for convenience. at higher rates, the 
                                                                           % digital input channel does not work reliably.

pathname = ['../../../../data/easter/' rabbit_ID '/neuro/binary_data/vep/'];%path for the data in easter binary format
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

pathname_matdata = ['../../../../data/easter/' rabbit_ID '/neuro/matlab_data/vep/'];

[ channelNames, gtechGND, earth ] = rabbit_information(rabbit_ID);
%///////////////////////////////////////////////
% END BLOCK: Hardcoded variables
%///////////////////////////////////////////////



[ S, allData ] = get_information(pathname, pathname_comments, 'VEP')

%////////////////////////////////////////////////////////////////////////////////////////
% START BLOCK: Extract Data from Project Easter Binary Files to Prep for
% function call to arduino_vep.m
%////////////////////////////////////////////////////////////////////////////////////////


if (nargin < 2)
    publication_quality = 2;
end

if (nargin < 3)
    trials_list = 1:numel(S);
end


% rabbit10
%for i=1:length(S),				%for each data file in the directory
%for i=1:length(S),				%for each data file in the directory

%for i = [2 10 11 13 3] % rabbit 9
%for i = [12] % rabbit 9
%for i = [2 10 11 12 13 3] % rabbit 9
%for i = [2 10 11] % rabbit 9
%for i = [12 13 3] % rabbit 9
%for i = [4 10 12 15 5] % rabbit 10
%for i = [10]
%for i = [1] % rabbit 9/10 baseline
%for i = length(S)
%for i = 10 % mid-basilar (happens to be same for rabbit 9 and 10
%for i = 11
for i = trials_list
    filename = S{i};
    fprintf('filename: %s,\t%d / %d\n', filename, i, length(S));

    [ data, cleanDigitalIn ] = load_data([pathname filename], maxNumberOfChannels, digitalInCh, channelNames)

    if publication_quality > 0
        run('publish_vep_v2.m');
        %run('publish_vep_off_v2.m');
        %run('publish_vep_all.m');
        %run('publish_fano.m');
    else
       run('arduino_vep.m');
    end
    
    close all;
end

end
