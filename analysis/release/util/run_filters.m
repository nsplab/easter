% run_filters.m
%
% This function processes a signal with the requested filters.
%
% Arguments:
%   data: signal to run the filters on
%   filters: array of requested filters
%
% Output:
%   data: filtered version of signal

function [ data ] = run_filters(data, filters)

for filter = filters
    data = filtfilt(filter{1}.sosMatrix, filter{1}.ScaleValues, data);
end

end

