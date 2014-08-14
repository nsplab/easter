function [ nominal_frequency, frequency ] = get_frequency(comment, filename)
%GET_FREQUENCY  Reads the experiment log to get the frequency of an experiment.
%
% [ NOMINAL_FREQUENCY, FREQUENCY ] = GET_FREQUENCY(COMMENT, FILENAME)
%
% Parameters:
%
%   COMMENT is the string of the relevant line in the experiment log.
%
%   FILENAME is the filename of the data (not currently used).
%
% Output:
%
%   NOMINAL_FREQUENCY is the frequency written in the data log.
%
%   FREQUENCY is the true frequency of stimulus (this tends to be an unrounded
%   version of nominal_frequency)

nominal_frequency = [];
frequency = [];

% Search for the numbers in comment
if ~isempty(strfind(comment{1}(9:35), '10'))
    nominal_frequency = [nominal_frequency 10];
    frequency = [frequency 9.8000];
end
if ~isempty(strfind(comment{1}(9:35), '12'))
    nominal_frequency = [nominal_frequency 12];
    frequency = [frequency 12];
end
if ~isempty(strfind(comment{1}(9:35), '40'))
    nominal_frequency = [nominal_frequency 40];
    frequency = [frequency 40.8333];
end
if ~isempty(strfind(comment{1}(9:35), '42'))
    nominal_frequency = [nominal_frequency 42];
    frequency = [frequency 42];
end
if ~isempty(strfind(comment{1}(9:35), '50'))
    nominal_frequency = [nominal_frequency 50];
    frequency = [frequency 54.4444];
end
if ~isempty(strfind(comment{1}(9:35), '51'))
    nominal_frequency = [nominal_frequency 51];
    frequency = [frequency 51];
end
if ~isempty(strfind(comment{1}(9:35), '86'))
    nominal_frequency = [nominal_frequency 86];
    frequency = [frequency 86];
end

% Check that exactly one option was triggered
assert(numel(nominal_frequency) == 1);
assert(numel(frequency) == 1);

nominal_frequency = nominal_frequency(1);
frequency = frequency(1);

end

