function [ nominal_frequency, frequency ] = get_frequency(comment, filename)

nominal_frequency = [];
frequency = [];
if ~isempty(strfind(comment{1}(9:35), '10'))
    nominal_frequency = [nominal_frequency 10];
    frequency = [frequency 9.8000];
end
if ~isempty(strfind(comment{1}(9:35), '12'))
    nominal_frequency = [nominal_frequency 12];
    frequency = [frequency 12]; % TODO: check if this is exact
end
if ~isempty(strfind(comment{1}(9:35), '40'))
    nominal_frequency = [nominal_frequency 40];
    frequency = [frequency 40.8333];
end
if ~isempty(strfind(comment{1}(9:35), '42'))
    nominal_frequency = [nominal_frequency 42];
    frequency = [frequency 42]; % TODO: check if this is exact
end
if ~isempty(strfind(comment{1}(9:35), '50'))
    nominal_frequency = [nominal_frequency 50];
    frequency = [frequency 54.4444];
end
if ~isempty(strfind(comment{1}(9:35), '51'))
    nominal_frequency = [nominal_frequency 51];
    frequency = [frequency 51]; % TODO: check if this is exact
end

assert(numel(nominal_frequency) == 1);
assert(numel(frequency) == 1);

nominal_frequency = nominal_frequency(1);
frequency = frequency(1);

end

