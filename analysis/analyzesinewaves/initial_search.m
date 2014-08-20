%script to search over initial parameters
clear phasen freq_ar data_hold data_search
fs = 19200;
idx = 1;
index = 1;
test_data = detrend(double(data_cell(index).data(1000:end-1000)));
ntp =size(test_data, 1);
t = (1:ntp)/fs;
test_data = zscore(test_data);
frequency = data_cell(index).freq;
band = 2;
filter_in = filter_data(test_data, frequency, band);%filtering the data            
for a = 1:1:10;
    for b = 1:1:10
        for c = 1:1:10
            %Fiiting to a*sin(2*pi*f+c)+b
            [sin_in, phase_in, gain_in, score] = fitdata(filter_in, frequency, [a,b,c]);
            score
            data_search(idx).freq = frequency;
            data_search(idx).score = score;
            data_search(idx).amplitude = a;
            data_search(idx).offset = b;
            data_search(idx).phase = c;
            freq_ar(idx) = frequency;
            idx  = idx + 1; 
        end
    end   
end