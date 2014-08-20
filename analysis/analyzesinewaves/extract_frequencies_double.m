function data_cell = extract_frequencies_double(data, data_out, data_reference, limit_val)
%EXTRACT_FREQUENCIES_double extract the frequencies from a dataset and
%organizes them in a file structure with input, output and frequency value
%information.
%It uses the freqs.leondf to set the values of the frequencies.
%---
%input
%---
%data: Input Data
%data_out: Output data
%data_reference: data to be used as reference to make the divisions,
%usually is the direct output from the gamry
%limit_val: lower limit value to do the segmentation
%---
%output
%---
%data_cell(n).freq: value of the nth frequency
%data_cell(n).data: data for the nth frequency
%data_cell(n).dataout: Out data for the nth frequency

freqs = load('/home/leon/Data/Characterization/PublicationData/freqs.leondf');%loads the frequencies
frequencies_list = freqs;%creates a list
minimum_value = limit_val;
%script to create the indexes for the divisions
data_labels = zeros(size(data_reference));%create labels
data_labels(find(data_reference<minimum_value))=1;%if the value is lower than the limit, set a one
counter_1 = 0;
counter_0 = 0;
start_indexes =[];
end_indexes = [];
for idx=1:length(data_labels)
    if(data_labels(idx)==1)%if there is a detection
        counter_1 = counter_1 +1;
        counter_0 = 0;
        if counter_1 == 20 %and the detection has been done for more than 20 samples
            end_indexes(end+1) = idx;%crate a new index
        end
    else
        counter_0 = counter_0 + 1;
        counter_1 = 0;
        if counter_0 == 200
            start_indexes(end+1) = idx;
        end
    end
    
end
counter = 1;
%create the data structure
for end_idx = end_indexes
    data_cell(counter).freq = frequencies_list(counter);
    if counter == 1
        data_cell(counter).data = data(1:end_idx);
        data_cell(counter).dataout = data_out(1:end_idx);
    else
        data_cell(counter).data = data(start_indexes(counter):end_idx);
        data_cell(counter).dataout = data_out(start_indexes(counter):end_idx);
    end
    counter = counter + 1;
end
    
end

