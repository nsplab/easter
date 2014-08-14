function [ data ] = run_filters(data, filters)
%RUN_FILTERS  Processes a signal with the requested filters.
%
% DATA = RUN_FILTERS(DATA, FILTERS)
%
% Parameters:
%
%   DATA is a vector representing the signal to run the filters on.
%
%   FILTERS is a cell array of requested filters.
%
% Output:
%
%   DATA is the filtered version of signal.

for filter = filters
    data = filtfilt(filter{1}.sosMatrix, filter{1}.ScaleValues, data);
end

end

