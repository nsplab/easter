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
% Hardcoded variables
%///////////////////////////////////////////////
rabbit_ID = '7rabbit_apr_15_2014';			%'7rabbit_apr_15_2014' corresponds to the experiment performed 4/15/14
pathname = ['../../data/' rabbit_ID '/neuro/vep/'];	%path for the data in easter binary format
pathname_comments = ['../../data/' rabbit_ID '/neuro/vep.txt'];%file containing comments written on the experiment day to use as labels for the figure titles
							% read the comments written on the experiment day to use as labels for the figure titles
							% each line correspondes to a single run of the VEP experiment
							% this file needs to be prepared by hand
							% the total # of lines should equal the number of VEP sessions
							% the ordering of comments needs to be chronological
							% example lines:
							% 12:30 This is the comment about this particular session. g.tech Ground was nose.
							% 12:45 This was the next condition. Used Faraday cage. g.tech Ground was right leg.

original_sampling_rate_in_Hz = 9600;			% data is acquired with the g.Tech g.HiAmp at 9600 Hz. this is fixed for convenience. at higher rates, the 
							% digital input channel does not work reliably.
decimate_factor = 10;					% this code also saves a decimated trace of the data (properly downsampled using anti-aliasing, with decimate.m).

%///////////////////////////////////////////////



fid = fopen(pathname_comments);
if fid==-1						%if the vep.txt comments file doesn't exist, display an error message to the console and skip the textscan
	disp('Hey - you may want to create vep.txt to populate the titles in these figures. See plot_all_vep.m for details.');
	allData = [];
else
	allData = textscan(fid,'%s','Delimiter','\n');
end


%////////////////////////////////////////////////////////////////////////////////////////
% START BLOCK: Create Stimulus-Locked Figures, one for each data file in the directory
%////////////////////////////////////////////////////////////////////////////////////////

for i=1:(length(S)-2),				%for each data file in the directory
    filename = S{i};
    data = original_data;
    run('arduino_vep.m');
end
%///////////////////////////////////////////////
% END BLOCK
%///////////////////////////////////////////////






%///////////////////////////////////////////////
% START BLOCK:  generate a structure that documents the
% electrode positions for each channel, in every run that was recorded
%///////////////////////////////////////////////

% get the list of data filenames for this particular type of evoked potential
% sorted based on the modification time
tmp = dir(pathname);
S = [tmp(:).datenum].';
[S,S] = sort(S);
S = {tmp(S).name};

% generate a structure that documents the electrode positions for each channel, in every run that was recorded
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

for i=1:(length(S)-2),				%for each data file in the directory, decimate and save
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
    save([S{i} '.mat'], 'data', 'sampling_rate_in_Hz', 'GND','all_experiments_channels');

    data = data_decimated;
    sampling_rate_in_Hz = decimated_sampling_rate_in_Hz;
    save(['../data/neuro/matlab_data' S{i} '_decimated.mat'], 'data', 'sampling_rate_in_Hz', 'GND','all_experiments_channels');

%    data = original_data;
%    run('arduino_vep.m');
end
%///////////////////////////////////////////////
% END BLOCK
%///////////////////////////////////////////////

