function [ data, cleanDigitalIn ] = load_data(full_filename, maxNumberOfChannels, digitalInCh, channelNames)

fid = fopen(full_filename, 'r');

data = cell(maxNumberOfChannels, 2);

for j=1:maxNumberOfChannels,                                           %for the jth analog channel (excluding the digital in channel), load the signal into a vector in original_data{j,2}
    fseek(fid, 4*(j-1), 'bof');
    dataColumn = fread(fid, Inf, 'single', 4*64);
    channelName = channelNames{j};

    data(j, 1) = {channelName};
    data(j, 2) = {dataColumn};
end

fseek(fid, 4*(digitalInCh-1), 'bof');                                      %fseek sets the pointer to the first value read in the file. 4 represents 4 bytes.
                                                                           %we're starting to read from the digital input channel, the first value of which is
                                                                           %4*(digitalInCh-1) bytes into the file.
dataColumnDig = fread(fid, Inf, 'single', 4*64);                           %fread iteratively reads values the file and places them into the vector 'dataColumn', 
                                                                           %representing all amplitudes from the current channel.. Inf causes fread to continue until it 
                                                                           %reaches EOF (end of file). 4*64 tells fread to skip 4*64 bytes to get the next value (assumes 65 channels recorded)
cleanDigitalIn = (dataColumnDig>0);

fclose(fid);

end

