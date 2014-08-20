function data_cell = extract_frequencies(data)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
freqs = load('freqs.leondf')
frequencies_list = freqs;
maximum_value = 1e5;
data_labels = zeros(size(data));
data_labels(find(data>maximum_value))=1;
indicator = diff(data_labels);
end_indexes = find(indicator == 1);
start_indexes = find(indicator == -1);
counter = 1;
for end_idx = end_indexes'
    data_cell(counter).freq = frequencies_list(counter);
    end_idx
    if counter == 1
        data_cell(counter).data = data(1:end_idx);
    else
        data_cell(counter).data = data(start_indexes(counter-1):end_idx);
    end
    counter = counter + 1;
end
    
end

