function [ data, samples ] = load_data(filename, num_channels)
%LOAD_DATA  Loads data from binary data files.
%
%   [ DATA, SAMPLES ] = LOAD_DATA(FILENAME, NUM_CHANNELS) reads binary data
%   from the file FILENAME with NUM_CHANNELS channels recorded.
% 
% Parameters:
%
%   FILENAME is a string that can be either a relative or absolute path.
%
%   NUM_CHANNELS is the number of channels recorded in the binary file.
%
% Output:
%
%   DATA is a matrix of single values. Each of the NUM_CHANNELS rows
%   corresponds to one of the channels. Each of the SAMPLES columns
%   corresponds to a sample from one of the timesteps.
%
%   SAMPLES is an integer that is the number of samples for each channel in
%   the binary file.

%% Constants
sample_size = 4;      % number of bytes in each sample
precision = 'single'; % type of variable to read as

%% Check that data is complete
F = dir(filename);                                     % get file information
bytes = F.bytes;                                       % file size in bytes
assert(mod(bytes, (num_channels * sample_size)) == 0); % check same number of samples in each channel
samples = bytes / (num_channels * sample_size);        % number of samples in each channel

%% Load data
fid = fopen(filename, 'r');                  % Open data file
file = fread(fid, Inf, precision);           % Load all channels
fclose(fid);                                 % Close data file
data = reshape(file, num_channels, samples); % Split into channels

end

