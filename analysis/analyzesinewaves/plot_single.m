%close all
%Plot Single takes a variable called data file that indicates both the position and name of a particular dataset to work with, 
%it also uses the metadata_files to extract the information about the lower limit and the indexes.
clear
material = 'Xped10';
catheter = 'Echelon10b';
folder = '/home/leon/Data/Characterization/PublicationData/GoodData/';
datafile = [folder material catheter]; %We can build the filename setting a material and catheter
%datafile = '/home/leon/Data/Characterization/PublicationData/GoodData/10KResistorNoCatheter';
%Or we can use the filename directly
indicator = [material catheter];
%If we use the filename directly, indicator has to be the filename without the path:
%indicator:10KResistorNoCatheter
readdata %reads the rawdata from the datafile
fs = 19200;%define sampling frequency
[lim1, lim2, limit] = extract_limits('/home/leon/Data/Characterization/PublicationData/GoodData/metadata_files', indicator);
%extracts limits extracts the information form the metadata_files, given
%the indicator, which is the datafile name.
limit = -1.5e5;
%datain = channel_1(lim1:lim2);%chops the data from readdata
%dataout = channel_2(lim1:lim2);
datain = channel_2(lim1:lim2);%chops the data from readdata
dataout = channel_1(lim1:lim2);
datareference = channel_3(lim1:lim2);%Only for marking the separation in frequencies
data_cell = extract_frequencies_double(datain, dataout, datareference,limit);
%creates the data_cell structure, that contains input and output data for
%each frequency as well as a value freeq that inficates the frequency.

