function [ numChannels, digitalCh, fs, channelNames, GND, earth ] = subject_information(subject_ID)
%SUBJECT_INFORMATION  Returns information about the data for the subject.
%
% [ NUMCHANNELS, DIGITALCH, FS, CHANNELNAMES, GND, EARTH ] = SUBJECT_INFORMATION(SUBJECT_ID)
%
% Arguments:
%
%   SUBJECT_ID is a string containing the name of the subject. This is not
%   currently used due to the fact that all example subjects have the same
%   information.
%
% Output:
%
%   NUMCHANNELS is an integer specifying how many channels in total are
%   available for the subject.
%
%   DIGITALCH is the index of the digital channel for this subject.
%
%   FS is the sampling frequency for this subject.
%
%   CHANNELNAMES is a list of strings recording which electrode each channel
%   was connected to.
%
%   GND is a string recording where the ground electrode on the recording
%   device was connected to.
%
%   EARTH is a string recording which part of the subject was connected to
%   earth.

numChannels = 11;
digitalCh = 11;
fs = 9600;
channelNames = {'Disconnected','Endo','Mid head','Disconnected','Right Eye','Right Leg','Back Head','Left Eye','Bottom Precordial','Top Precordial'};
GND = 'Nose';
earth = 'Left Leg';

end

