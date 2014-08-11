% load_data.m
%
% This function loads the requested number of analog channels and the digital in channel.
%
% Arguments:
%   full_filename: file to be loaded
%   maxNumberOfChannels: number of analog channels to load
%   digitalInCh: index of the digital in channel
%   channelNames: list of the names of the channels
%
% Output:
%   data: cell array (maxNumberOfChannels x 2) of analog channels
%         each row corresponds to one of the channels
%         first column is a string of the channel name
%         second column is an array of the data
%   cleanDigitalIn: boolean array of digital in channel

function [ data, cleanDigitalIn ] = load_data(full_filename, maxNumberOfChannels, digitalInCh, channelNames)

% Open data file
fid = fopen(full_filename, 'r');

% Create cell array for data
data = cell(maxNumberOfChannels, 2);

% Load each of the channels
for j=1:maxNumberOfChannels
    fseek(fid, 4*(j-1), 'bof');                   % move to first timestamp
    dataColumn = fread(fid, Inf, 'single', 4*64); % read only this channel
    channelName = channelNames{j};

    % record data to output
    data(j, 1) = {channelName};
    data(j, 2) = {dataColumn};
end

fseek(fid, 4*(digitalInCh-1), 'bof');            % fseek sets the pointer to the first value read in the file. 4 represents 4 bytes.
                                                 % we're starting to read from the digital input channel, the first value of which is
                                                 % 4*(digitalInCh-1) bytes into the file.
dataColumnDig = fread(fid, Inf, 'single', 4*64); % fread iteratively reads values the file and places them into the vector 'dataColumn', 
                                                 % representing all amplitudes from the current channel.. Inf causes fread to continue until it 
                                                 % reaches EOF (end of file). 4*64 tells fread to skip 4*64 bytes to get the next value (assumes 65 channels recorded)
cleanDigitalIn = (dataColumnDig>0);

fclose(fid);

end

