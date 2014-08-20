%Get Transfer Function
data_folder = '/home/leon/Data/Characterization';
[file_list, frequency_list] = get_files_frequencies(data_folder);
fs = 19200;
for file_idx = 1:length(file_list)
    fid = fopen([data_folder '/' file_list{file_idx}],'r');%open the file
    fseek(fid, 0, 'bof');%go to the beginning of the file
    c = fread(fid, Inf, '*single');%read the file
    m = vec2mat(c,65);%convert it into a matrix
    channel_1 = m(:,1);
    channel_2 = m(:,42);
    fclose(fid);
    F = frequency_list(file_idx);
    data_sigs = [channel_1';channel_2'];
    AddToSavedTransFxn(data_sigs, F, fs, 'Transfer', ' ')
end
transferfun = ' Transfer.mat';
load(transferfun)
plotCustomBode(HwFreqs, Hw, 'k')