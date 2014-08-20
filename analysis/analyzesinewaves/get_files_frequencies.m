function [files, freq_list] = get_files_frequencies(directory)
%GET_FILES_FREQUENCIES obtains the list of files in the target directory,
%and obtain the list of frequencies that they represent
%File format has to be raw_data_frequencyHz 
%If the frequency is less than 1, it need a zero in front, for example, 
%raw_data_05Hz is a 0.5Hz frequency
freq_list = []; %Initialize the list
listing = dir([directory '/raw_*']);%find all the files that start with raw
files = {listing.name}; %convert the output in a cell
expre = '\d*'; %Regular expression that looks for numbers in the filename
for file_idx = 1:length(files) %iterate over all the files
    %now we extract the frequency from the file name
    str = files{file_idx};
    freq = regexp(str, expre, 'match'); %match the expression and get the frequency
    %check if the first character is zero, so we put decimals in the
    %frequencies
    if freq{1}(1) == '0'
        disp 'This is a decimal'
        freq_num = str2num(freq{1})/10;%convert the frequency string to a number and divide by ten to add the decimal
    else
        freq_num = str2num(freq{1});%convert the frequency string to a number
    end
    freq_list = [freq_list freq_num];
end
end

    
    


