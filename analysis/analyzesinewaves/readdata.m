%readdata.m reads the data from file, given that there is a variable called
%datafile in the workspace. 
%It generates three outputs:
%Channel_2 is the input of the data (read in the distal bath)
%Channel_1 is the output of the data (read in the proximal bath)
%Channel_3 contains the original signal from the gamry.
fid = fopen(datafile,'r');%opens the file
fseek(fid, 0, 'bof');%goes to the start of the file
c = fread(fid, Inf, '*single');%reads the file
m = vec2mat(c,65);%converts the read data into a matrix of Nx65, where N is the number of samples
%Use this setting to use the input in the distal bath as reference
channel_2 = m(:,1);%input
channel_1 = m(:,4);%output

%Use this setting to use the input in the gamry as reference
%channel_1 = m(:,36);%Input
%channel_2 = m(:,1);

channel_3 = m(:,36); %This is the reference for the cutpoints, and the direct output from the Gamry
fclose(fid)

