function [ maxNumberOfChannels, digitalInCh, original_sampling_rate_in_Hz ] = constants()

% # of consecutive analog input channels, starting with channel 1, to extract from the project easter binary files
% (which contain 64 analog channels and the digital in channel (channel 65)
maxNumberOfChannels = 10;
digitalInCh = 65;                                                          %designate the digital input channel, which is used to record
                                                                           %the LED state to align EEG data with onset or offset to generate VEP graphs 

original_sampling_rate_in_Hz = 9600;                                       % data is acquired with the g.Tech g.HiAmp at 9600 Hz. this is fixed for convenience. at higher rates, the 

end

