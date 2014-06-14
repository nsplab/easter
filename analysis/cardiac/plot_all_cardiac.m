%


rabbit_directory = '7rabbit_apr_15_2014';

% read the comments wirtten on the experiment day
% each line correspondes to an experiment
fid = fopen(['../../../data_easter/' rabbit_directory '/cardiac/experiment_log.txt']);
allData = textscan(fid,'%s','Delimiter','\n');

% get the list of data/experiment filenames
% sorted based on the modification time
tmp = dir(['../../../data_easter/' rabbit_directory  'cardiac'] );
S = [tmp(:).datenum].';
[S,S] = sort(S);
S = {tmp(S).name};

% generate a table whose 
% first column holds the filename of the data
% columns 2 to 11 hold the name/location of the channels
% the last column holds the which channels was used as GND
a = cell(length(S)-2,2);
for i=1:length(S)-2,
    a{i,1} = S(i);
    a{i,2} = 'Disconnected';
    a{i,3} = 'Endo';
    a{i,4} = 'Mid head';
    a{i,5} = 'Nose';
    a{i,6} = 'Right Eye';
    a{i,7} = 'Right Leg';
    a{i,8} = 'Back Head';
    a{i,9} = 'Left Eye';
    a{i,10} = 'Top Precordial';
    a{i,11} = 'Bottom Precordial';
    if i>1,
        if rem(idivide(i,int32(2)),2) == 0,
            a{i,12} = 'Right Leg';
            a{i,7} = 'Disconnected';
        else
            a{i,12} = 'Nose';
            a{i,5} = 'Disconnected';
        end
    else
        a{i,12} = 'Right Leg';
        a{i,7} = 'Disconnected';
    end    
end

all_experiments_channels = cell(size(a,1), size(a,2));
all_experiments_channels(2:end+1,:) = a(1:end,:);
all_experiments_channels(1,1) = {'filename'};
all_experiments_channels(1,2:end-1) = {'channel name'};
all_experiments_channels(1,end) = {'GND'};


% iterate over the data filenames
% 
original_sampling_rate_in_Hz = 9600;
decimate_factor = 10;
decimated_sampling_rate_in_Hz = original_sampling_rate_in_Hz/decimate_factor;

for i=1:(length(S)-2),
    dontUseGUI = 1;
    pathname = '../data/cardiac_copy/';
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
    save([S{i} '_decimated.mat'], 'data', 'sampling_rate_in_Hz', 'GND','all_experiments_channels');

    run('decimated_cardiac_psd.m');
end
