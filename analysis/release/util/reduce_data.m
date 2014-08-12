function [ data ] = reduce_data(start_file, end_file, num_channels, channels_to_keep)

% Constants
element_size = 4;
precision = 'single';

% Check that data is complete
s = dir(start_file);
bytes = s.bytes;
assert(mod(bytes, (num_channels * element_size)) == 0);

% Number of samples from each channel
samples = (bytes / (num_channels * element_size));

% Open data file
fid = fopen(start_file, 'r');

data = zeros(numel(channels_to_keep), samples, 'single');

for i = 1:numel(channels_to_keep)

    % move to first timestamp of this sample
    fseek(fid, element_size * (channels_to_keep(i) - 1), 'bof');

    % read all data from this channel
    data(i, :) = fread(fid, Inf, precision, element_size * (num_channels - 1));

end

% Close data file
fclose(fid);


% Open output file
fid = fopen(end_file, 'w');

% Write output file
fwrite(fid, data, precision);

% Close output file
fclose(fid);

end

