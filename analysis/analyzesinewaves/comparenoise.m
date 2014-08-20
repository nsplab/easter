clear
close all
%datafile = '/home/leon/Data/Characterization/raw_data_platblck_1_100';
%datafile = '/home/leon/Data/Characterization/PublicationData/Echelon10PlatinumBlack';
%datafile = '/home/leon/Data/Characterization/raw_data_plat_2_100';
datafile = '/home/leon/Data/Characterization/05HzAgAgShielded';
%datafile = '/home/leon/Data/Characterization/raw_data_100uV';
readdata
chan_1_shield = channel_1;
chan_2_shield = channel_2;
datafile = '/home/leon/Data/Characterization/05HzAgAgUnshielded';
readdata
chan_1_unshield = channel_1;
chan_2_unshield = channel_2;