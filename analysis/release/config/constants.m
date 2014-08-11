% constants.m
%
% This function gives information about the recordings.
%
% Arguments:
%   None
%
% Output:
%   maxNumberOfChannels: # of consecutive analog input channels, starting with
%                        channel 1, to extract from the binary files (which
%                        contain 64 analog channels and the digital in channel
%                        (channel 65)
%   digitalInCh: digital in channel number
%   original_sampling_rate_in_Hz: sampling rate for the data
function [ maxNumberOfChannels, digitalInCh, original_sampling_rate_in_Hz ] = constants()

% 
maxNumberOfChannels = 10;
digitalInCh = 65;
original_sampling_rate_in_Hz = 9600;

end

