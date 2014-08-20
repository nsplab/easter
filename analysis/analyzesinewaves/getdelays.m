%This genereates the bode plots by going frequency by frequency
%it filters the fundamental frequency
%Then it fits a sinusoidal 
%Then it gets the phase difference and gain

clear phasen freq_ar data_hold gain_arr
samplfactor = 1;
cycles_to_fit = 10;
for idx = 1:length(data_cell)-1
%for idx = 16:16
    idx
    fs=19200;%set the sampling frequency
    initial_point = round(length(data_cell(idx).data)*0.1);%start at 10% of the beginning of the data
    test_data = detrend(double(data_cell(idx).data(initial_point:end-100))); %detrend and end a 100 samples before the end
    out_data = detrend(double(data_cell(idx).dataout(initial_point:end-100)));
    frequency = data_cell(idx).freq;%get te current frequency
    end_time = cycles_to_fit/frequency;%based on the cycles to use for fitting, get the number of samples
    end_samples = end_time*fs;
    test_data = test_data(1:end_samples);%cut to the required number of samples
    out_data = out_data(1:end_samples);
    ntp =size(test_data, 1);
    t = (1:ntp)/fs;%create a time array to plot raw data
    master = sin(2*pi*t*frequency);%create a master plot, that has the ideal output at the givenf requency and zero phase
    data_hold(idx).master = master;%store it in a new data structure
    data_hold(idx).time = t;%store the time
    band = 2;%number of hertz to use for the bandpass filter
    filter_in = filter_data(test_data, frequency, band, fs);%filtering the input data
    filter_out = filter_data(out_data, frequency, band, fs);%filtering the output data
    [sin_in, phase_in, gain_in, score] = fitdata(filter_in, frequency, [0,0,0], fs);
    [sin_out, phase_out, gain_out, score] = fitdata(filter_out, frequency, [0,0,0], fs);
    %apply correction of the sinusoidal
    %check if the gains have teh same sign, if they do not change them and add 90 degrees 
    gain_in
    gain_out
    phase_out
    phase_in
    if (sign(gain_in) ~= sign(gain_out))
        disp('They were different')
        gain_out = -gain_out;
        phase_out = phase_out - pi;
    end
    data_hold(idx).data_in = test_data;%store the raw data
    data_hold(idx).data_out = out_data;
    data_hold(idx).filter_in = filter_in;%store the filtered data
    data_hold(idx).filter_out = filter_out;
    data_hold(idx).sin_out = sin_out;%store the fitted data
    data_hold(idx).sin_in = sin_in;
    data_hold(idx).freq = frequency;
    data_hold(idx).phase_in = phase_in;
    data_hold(idx).phase_out = phase_out;
    data_hold(idx).gain_in = gain_in;
    data_hold(idx).gain_out = gain_out;
    freq_ar(idx) = frequency;
    phasen(idx) = (phase_out) - (phase_in);%calculate the the difference in the phase
    phasen(idx) = rad2deg(phasen(idx));%convert to degrees
    gain_arr(idx) = abs(gain_out/gain_in);%get the ratio of the gain
    
end
plotgetdelays%plot the bode
