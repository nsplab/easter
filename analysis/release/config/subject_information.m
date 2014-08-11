% subject_information.m
%
% This function gives information about the recordings.
%
% Arguments:
%   subject_ID: not currently used
%
% Output:
%   maxNumberOfChannels: # of consecutive analog input channels, starting with
%                        channel 1, to extract from the binary files (which
%                        contain 64 analog channels and the digital in channel
%                        (channel 65)
%   digitalInCh: digital in channel number
%   original_sampling_rate_in_Hz: sampling rate for the data
%   channelNames: list of strings for where the channels record from
%   gtechGND: where the ground is connected to
%   earth: which electrode is used as earth

function [ maxNumberOfChannels, digitalInCh, original_sampling_rate_in_Hz, channelNames, gtechGND, earth ] = subject_information(subject_ID)

maxNumberOfChannels = 10
digitalInCh = 65;
original_sampling_rate_in_Hz = 9600;
channelNames = {'Disconnected','Endo','Mid head','Disconnected','Right Eye','Right Leg','Back Head','Left Eye','Bottom Precordial','Top Precordial'};
gtechGND = 'Nose';
earth = 'Left Leg';

end

