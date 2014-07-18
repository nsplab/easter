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


%///////////////////////////////////////////////
% START BLOCK: Hardcoded variables
%///////////////////////////////////////////////
%rabbit_ID = '6rabbit_apr_11_2014';                                         %'7rabbit_apr_15_2014' corresponds to the experiment performed 4/15/14
%rabbit_ID = '7rabbit_apr_15_2014';                                         %'7rabbit_apr_15_2014' corresponds to the experiment performed 4/15/14
%rabbit_ID = '8rabbit_apr_24_2014';
%rabbit_ID = '9rabbit_may_6_2014';
rabbit_ID = '10rabbit_may_15_2014';

publication_quality = 3;                                                   % generate the high quality figures with confidence intervals. this is much slower than having it set to zero
                                                                           % 0:, 1:with confidence intervals , 2:without confidence intervals, 3: use dashed lines instead of transparent ares for confidence areas

decimate_factor = 10;                                                      % decimate the data to speed up plotting (decimate_factor = 1 is no decimation; 10 is reasonable)
                                                                           %(this Matlab function implements proper downsampling using anti-aliasing, with decimate.m).


maxNumberOfChannels = 10;                                                  %# of consecutive analog input channels, starting with channel 1, to extract from the project easter binary files
                                                                           %(which contain 64 analog channels and the digital in channel (channel 65)

digitalinCh = 65;                                                          %designate the digital input channel, which is used to record
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

%Channel labels during VEP for all rabbits (5,6,7, etc.)
switch rabbit_ID
    case {'7rabbit_apr_15_2014', '8rabbit_apr_24_2014', '9rabbit_may_6_2014', '10rabbit_may_15_2014'}
        channelNames_VEP = {'Disconnected','Endo','Mid head','Disconnected','Right Eye','Right Leg','Back Head','Left Eye','Bottom Precordial','Top Precordial'};
        plot_only_neuro_and_endo_channels = 0;                             % choose to plot only neuro and endo channels, excluding disconnected or precordial channels
        gtechGND = 'Nose';
        earth = 'Left Leg';
    case '6rabbit_apr_11_2014'
        channelNames_VEP = {'Disconnected','Endo','Mid head','Disconnected','Right Eye','Right Leg','Back Head','Left Eye','Bottom Precordial','Top Precordial'};
    case '5rabbit_apr_15_2014'
%        channelNames_VEP = 
end
%///////////////////////////////////////////////
% END BLOCK: Hardcoded variables
%///////////////////////////////////////////////



tmp = dir(pathname);                                                       % get the list of data filenames for this particular type of evoked potential
S = {tmp(3:end).name};                                                     % chop out the '.' and '..' filename entries that are in every directory
%                                                                          %note from Ram, 4/18/14: do *not* sort by modification time - this may change; instead, rely on lexicographic sort of name which contains timestamp
%S = [tmp(:).datenum].';                                                   
%[S,S] = sort(S);
%S = {tmp(S).name};                                                        



fid = fopen(pathname_comments);
if fid==-1						%if the vep.txt comments file doesn't exist, display an error message to the console and skip the textscan
	disp('Hey - you may want to create vep.txt to populate the titles in these figures. See plot_all_vep.m for details.');
	allData = [];
else
	allData = textscan(fid,'%s','Delimiter','\n');
    % specific for rabbit 8
    C = strfind(allData{1}, '- VEP'); % get rows with '- VEP' in them
    rows = find(~cellfun('isempty', C));
    allData = allData{1}(rows);
end

%////////////////////////////////////////////////////////////////////////////////////////
% START BLOCK: Extract Data from Project Easter Binary Files to Prep for
% function call to arduino_vep.m
%////////////////////////////////////////////////////////////////////////////////////////

vep_data = cell(size(S));

for i=1:length(S),				%for each data file in the directory
    filename = S{i};
    filename
    fid = fopen([pathname filename], 'r');

    vep_data{i}.filename = filename;                                       %vep_data will be stored to a .mat file, a single variable containing all the essential processed VEP data from this subject
    vep_data{i}.allData = allData(i);                                   %vep_data will be stored to a .mat file, a single variable containing all the essential processed VEP data from this subject
%    vep_data{i,1} = filename;
%    vep_data{i,2} = allData{1}(i);
    
    data = cell(maxNumberOfChannels,2);
    dataDecimated = cell(maxNumberOfChannels,2);

    for j=1:maxNumberOfChannels,                                           %for the jth analog channel (excluding the digital in channel), load the signal into a vector in original_data{j,2}
        fseek(fid, 4*(j-1), 'bof');
        dataColumn = fread(fid, Inf, 'single', 4*64);
        channelName = channelNames_VEP{j};

        data(j,1) = {channelName};
        data(j,2) = {dataColumn};
        
        dataColumnDecimated = decimate(dataColumn,decimate_factor);                 %decimate the data by the requested factor for speed

        dataDecimated(j,1) = {channelName};
        dataDecimated(j,2) = {dataColumnDecimated};
    end
    
    fseek(fid, 4*(digitalinCh-1), 'bof');                                      %fseek sets the pointer to the first value read in the file. 4 represents 4 bytes.
                                                                               %we're starting to read from the digital input channel, the first value of which is
                                                                               %4*(digitalinCh-1) bytes into the file.
    dataColumnDig = fread(fid, Inf, 'single', 4*64);                           %fread iteratively reads values the file and places them into the vector 'dataColumn', 
                                                                               %representing all amplitudes from the current channel.. Inf causes fread to continue until it 
                                                                               %reaches EOF (end of file). 4*64 tells fread to skip 4*64 bytes to get the next value (assumes 65 channels recorded)
    cleanDigitalIn = (dataColumnDig>0);
    
    dataColumnDigDecimated = dataColumnDig(1:decimate_factor:end);                      %throw out intermediate samples to keep them aligned to the decimated channel data
    cleanDigitalInDecimated = (dataColumnDigDecimated>0);                                        %make sure the digital In takes on binary values: take any negative excursions to 0
    
    if publication_quality > 0
       run('publish_vep_v2.m');
    else
       run('arduino_vep.m');
    end
    
    sampling_rate_in_Hz = original_sampling_rate_in_Hz;
    save([pathname_matdata S{i} '.mat'], 'data', 'sampling_rate_in_Hz', 'gtechGND','channelNames_VEP','cleanDigitalIn');
    sampling_rate_in_Hz = original_sampling_rate_in_Hz / decimate_factor;
    save([pathname_matdata S{i} '_decimated.mat'], 'dataDecimated', 'sampling_rate_in_Hz', 'gtechGND','channelNames_VEP','cleanDigitalInDecimated');
    
    if publication_quality == 1
        saveas(fgh, [pathname_matdata S{i} '_pub.fig']);
    elseif publication_quality == 3
        saveas(fgh, [pathname_matdata S{i} '_pub_dashedCI.fig']);
    else
        saveas(fgh, [pathname_matdata S{i} '.fig']);
    end
end

save([pathname_matdata 'vep_data.mat'], 'vep_data');

GND = gtechGND;                                                            %label indicating position of gtech ground (differential input to the g.HiAmp)
fs = original_sampling_rate_in_Hz/decimate_factor;                         %variable name 'fs' is used by arduino_vep.m


%//////////////////////////////////
% Load the Digital Input Channel (65)
%//////////////////////////////////
% read the digital input channel, which contains the LED state
% (in 7rabbit, this channel is low when LED is on, and high when LED is off;
% in 6rabbit and 5rabbit, this channel is low when LED is off, and high when LED is on;
% this convention is set by the arduino code in /code/easter/recording.
% for experiments subsequent to 7rabbit, the arduino code was set back to the
% intuitive convention of low when LED is off, and high when LED is on.
%time_axis = (0:length(dataColumnDig)-1)*1.0/fs;                           %define a time axis, based on sampling rate (fs) and the length of the recording
%figure;plot(time_axis,dataColumnDig);                                     %plot and visualize the digital input channel
%//////////////////////////////////
%//////////////////////////////////////////////////////////
% END BLOCK: Extract Data from Project Easter Binary Files
%//////////////////////////////////////////////////////////


return;



%////////////////////////////////////////////////////////////////////////////////////////
% START BLOCK: Create Stimulus-Locked Figures, one for each data file in the directory
%////////////////////////////////////////////////////////////////////////////////////////

%for i=1:length(S)				%for each data file in the directory (sorted by name which contains timestamp and listed in variable S)
%    run('arduino_vep.m');
%end
%///////////////////////////////////////////////
% END BLOCK
%///////////////////////////////////////////////



%{




%///////////////////////////////////////////////
% START BLOCK:  generate a structure that documents the
% electrode positions for each channel, in every run that was recorded
%///////////////////////////////////////////////



% generate a structure that documents the electrode positions for each channel, in every run that was recorded
% row index:   filename index
% column 1:	   filename of the data
% columns 2 to 11: name/position of the channels (example: 'Mid head')
% last column: 	   which channels was used as GND
a = cell(length(S)-2,2);
for i=1:length(S)-2,
    a{i,1} = S(i);
    a{i,2} = 'Disconnected';
    a{i,3} = 'Endo';
    a{i,4} = 'Mid head';
    a{i,5} = 'Disconnected';
    a{i,6} = 'Right Eye';
    a{i,7} = 'Right Leg';
    a{i,8} = 'Back Head';
    a{i,9} = 'Left Eye';
    a{i,10} = 'Top Precordial';
    a{i,11} = 'Bottom Precordial';
    a{i,12} = 'Nose';
end

all_experiments_channels = cell(size(a,1), size(a,2));
all_experiments_channels(2:end+1,:) = a(1:end,:);
all_experiments_channels(1,1) = {'filename'};
all_experiments_channels(1,2:end-1) = {'channel name'};
all_experiments_channels(1,end) = {'GND'};
%///////////////////////////////////////////////
% END BLOCK
%///////////////////////////////////////////////


%////////////////////////////////////////////////////////////////////////////////////////
% START BLOCK: Compute and store a decimated version of the data for easy subsequent access in Matlab
%////////////////////////////////////////////////////////////////////////////////////////

decimated_sampling_rate_in_Hz = original_sampling_rate_in_Hz/decimate_factor;

for i=1:length(S),				%for each data file in the directory, decimate and save
    dontUseGUI = 1;
    S{i}
    filename = S{i};
    pwd
    fid = fopen([pathname filename], 'r');
    
    original_data = cell(0,2);
    data_decimated = cell(0,2);
    
    maxNumberOfChannels = 10;
    for j=1:maxNumberOfChannels,
        fseek(fid, 4*(j-1), 'bof');
        dataColumn = fread(fid, Inf, 'single', 4*64);
        channelName = a{i,j+1};
        
        original_data(end+1,1) = {channelName};
        original_data(end,2) = {dataColumn};
        
        dataColumn_decimated = decimate(dataColumn, decimate_factor);
        data_decimated(end+1,1) = {channelName};
        data_decimated(end,2) = {dataColumn_decimated};

    end
    
    GND = a{i,12};
    data = original_data;
    sampling_rate_in_Hz = original_sampling_rate_in_Hz;
%    save([S{i} '.mat'], 'data', 'sampling_rate_in_Hz', 'GND','all_experiments_channels');

    data = data_decimated;
    sampling_rate_in_Hz = decimated_sampling_rate_in_Hz;
%    save(['../data/neuro/matlab_data' S{i} '_decimated.mat'], 'data', 'sampling_rate_in_Hz', 'GND','all_experiments_channels');

%    data = original_data;
%    run('arduino_vep.m');
end
%///////////////////////////////////////////////
% END BLOCK
%///////////////////////////////////////////////


%}
