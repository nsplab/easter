clear
array_Hw = [];
figure
for files = 1:5
    indicator  = num2str(files);
    datafile = ['/home/leon/Data/Characterization/raw_data_test_' indicator];
    readdata
    wind = 512;
    fs = 19200;
    [lim1, lim2] = extract_limits('/home/leon/Data/Characterization/metadata_files', ['test_' indicator]);
    datain = channel_1(lim1:lim2);
    dataout = channel_2(lim1:lim2);
    data_cell = extract_frequencies_double(datain, dataout);
    for freqs = 1:size(data_cell,2)
        F = data_cell(freqs).freq;
        data_sigs = [data_cell(freqs).data'; data_cell(freqs).dataout'];
        AddToSavedTransFxn(data_sigs, F, fs, 'Transfer', ' ')
    end

    transferfun = ' Transfer.mat';
    load(transferfun)
    plotCustomBode(HwFreqs, Hw, [0.678, 0.674, 0.725])
    array_Hw = [array_Hw; Hw];
    hold on

end
Hw = mean(array_Hw);
plotCustomBode(HwFreqs, Hw, 'k')