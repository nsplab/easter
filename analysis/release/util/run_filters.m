function [ data ] = run_filters(data, filters)

for filter = filters
    data = filtfilt(filter{1}.sosMatrix, filter{1}.ScaleValues, data);
end

end

