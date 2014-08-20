clear
close all
figure
%Set a cell with the datafile names that we need
%data: has the file location for the dataset
%name: has the description of that dataset
%indicator: indicator variable to extract the limits of the data from the
%metadatafile
%AgagCl Electrode set
material = {'1KResistor' '10KResistor' '1MResistor' '10MResistor' '20MResistor' '30MResistor' '40MResistor'};
resistor_values = [10^4, 10^3, 10^6 10^7 2*10^7 3*10^7 4*10^7];%Values of the resistors
catheter = {'NoCatheter'};
folder = '/home/leon/Data/Characterization/PublicationData/GoodData/';
cidx = 1;
for material_idx = material
    data{cidx} = cell2mat([folder material_idx catheter]);
    name{cidx} = cell2mat([material_idx ' ' catheter]);
    indicator{cidx} = cell2mat([material_idx catheter]);
    cidx = cidx + 1;
end

% for catheter_idx = catheter
%     data{cidx} = cell2mat([folder material catheter_idx]);
%     name{cidx} = cell2mat([material ' ' catheter_idx]);
%     indicator{cidx} = cell2mat([material catheter_idx]);
%     cidx = cidx + 1;
% end

wind = 512;
fs = 19200;%sampling frequency
color_array = distinguishable_colors(length(data));
color_array = pink(length(data));
color_array = flipud(color_array);
%color_array = [255,13, 0; 255,184, 0; 23, 41, 176; 0, 198, 24; 166, 120, 0; 0, 0, 0];
%color_array = color_array/255;
marker_array = {'.','o','d','s','x','s','d','^','v','>','<','p','h'};
for data_idx = 1:length(data)
%for data_idx = 1:1
    datafile = data{data_idx};
    readdata %This reads the data and extract channel 1 and 2, 
    %1 is connected to the box channel 1 and 2 is in the box channel 42
    [lim1, lim2, limit] = extract_limits('/home/leon/Data/Characterization/PublicationData/GoodData/metadata_files', indicator{data_idx});
    datain = channel_1(lim1:lim2);
    dataout = channel_2(lim1:lim2);
    %datareference = channel_3(lim1:lim2);%Only for marking the separation in frequencies
    limit =-1.5e5;
    data_cell = extract_frequencies_double(datain, dataout, datain, limit); %extract a data cell that has all the ifnormation
    %data_cell.in: Array with input raw data
    %data_cell.out: Array with output raw data
    %data_cell.freq: Array with frequency value
    %Now we fit each of the datasets
    clear phasen freq_ar data_hold gain_arr
    fs = 19200;
    cycles_to_fit = 10;
    for idx = 1:length(data_cell)-1
        initial_point = round(length(data_cell(idx).data)*0.1);
        test_data = detrend(double(data_cell(idx).data(initial_point:end-100)));
        out_data = detrend(double(data_cell(idx).dataout(initial_point:end-100)));
        %test_data = zscore(test_data);
        %out_data = zscore(out_data);
        frequency = data_cell(idx).freq;
        end_time = cycles_to_fit/frequency;
        end_samples = end_time*fs;
        test_data = test_data(1:end_samples);
        out_data = out_data(1:end_samples);
        ntp =size(test_data, 1);
        t = (1:ntp)/fs;
        master = sin(2*pi*t*frequency);
        data_hold(idx).master = master;
        data_hold(idx).time = t;
        band = 2;
        filter_in = filter_data(test_data, frequency, band, fs);%filtering the data
        filter_out = filter_data(out_data, frequency, band, fs);%filtering the data
        [sin_in, phase_in, gain_in, score] = fitdata(filter_in, frequency, [0,0,0], fs);
        [sin_out, phase_out, gain_out, score] = fitdata(filter_out, frequency, [0,0,0], fs);
        if (sign(gain_in) ~= sign(gain_out))
            disp('They were different')
            gain_out = -gain_out;
            phase_out = phase_out - pi;
        end
        data_hold(idx).data_in = test_data;
        data_hold(idx).data_out = out_data;
        data_hold(idx).filter_in = filter_in;
        data_hold(idx).filter_out = filter_out;
        data_hold(idx).sin_out = sin_out;
        data_hold(idx).sin_in = sin_in;
        data_hold(idx).freq = frequency;
        data_hold(idx).phase_in = phase_in;
        data_hold(idx).phase_out = phase_out;
        data_hold(idx).gain_in = gain_in;
        data_hold(idx).gain_out = gain_out;
        freq_ar(idx) = frequency;
        phasen(idx) = (phase_out) - (phase_in);
        phasen(idx) = rad2deg(phasen(idx));
        gain_arr(idx) = abs(gain_out/gain_in);

    end
    data_plot(data_idx).value = material{data_idx};
    data_plot(data_idx).phase = phasen;
    data_plot(data_idx).phase_in = [data_hold(:).phase_in];
    data_plot(data_idx).phase_out = [data_hold(:).phase_out];
    data_plot(data_idx).gain = gain_arr;
    data_plot(data_idx).gain_in = [data_hold(:).gain_in];
    data_plot(data_idx).gain_out = [data_hold(:).gain_out];
    marker = marker_array{mod(data_idx,numel(marker_array))+1};
    color = color_array(data_idx, :);
    subplot(3,1,2)
    %phase_pl(data_idx) = semilogx(freq_ar, phasen,'color', color*0.6, 'LineWidth', 4,...
    %'Marker', marker, 'MarkerFaceColor', color, 'MarkerEdgeColor',color*0.6, 'MarkerSize', 12);
    phase_pl(data_idx) = semilogx(freq_ar, phasen,'color', color*0.6, 'LineWidth', 4)
    hold on
    title('Phase difference of the input vs the output signals (Ph_{out}-Ph_{in})')
    ylabel('Phase (degrees)')
    xlabel('Frequency (Hz)')
    set(gca, 'fontsize', 18)
    set(gca, 'box', 'off');
    subplot(3,1,1)
    %gain_plt(data_idx) = semilogx(freq_ar, gain_arr,'color', color*0.6, 'LineWidth', 4,...
    %    'Marker', marker, 'MarkerFaceColor', color, 'MarkerEdgeColor',color*0.6, 'MarkerSize', 12);
    gain_plt(data_idx) = semilogx(freq_ar, gain_arr,'color', color*0.6, 'LineWidth', 4)
    hold on
    set(gca, 'fontsize', 18)
    set(gca, 'box', 'off');
    title('Gain Ratio of the Signals (Vo/Vin)')
    ax=axis;
    axis([ax(1) ax(2) 0 1])
    ylabel('Gain (unitless)')
    xlabel('Frequency (Hz)')
    subplot(3,1,3)
    impedance = (gain_arr./(1-gain_arr))*resistor_values(data_idx);
    impedance = impedance/(10^9);
    %impedance_plt(data_idx) = semilogx(freq_ar, impedance,'color', color*0.6, 'LineWidth', 4,...
    %    'Marker', marker, 'MarkerFaceColor', color, 'MarkerEdgeColor',color*0.6, 'MarkerSize', 12);
    impedance_plt(data_idx) = loglog(freq_ar, impedance,'color', color*0.6, 'LineWidth', 4)
    hold on
    set(gca, 'fontsize', 18)
    set(gca, 'box', 'off');
    title('Impedance values (Gain/(1/Gain)*Resistance)')
    ax=axis;
    ylabel('Impedance (GOhm)')
    xlabel('Frequency (Hz)')
    
    
    
end
figureHandle = gcf;
set(findall(figureHandle,'type','text'),'fontSize',24,'fontWeight','bold', 'color', [0,0,0])
set(gcf, 'color', [1,1,1])
set(gcf,'renderer', 'zbuffer');
%set(gcf, 'Position', get(0,'Screensize'));
legend(phase_pl, name, 'location', 'EastOutside')
legend(gain_plt, name, 'location', 'EastOutside')
legend(impedance_plt, name, 'location', 'EastOutside')
plot_title = cell2mat(name); %get a single string
plot_title(plot_title==' ')=[]; %remove spaces
plot_title(plot_title=='.')=[]; %remove points
plot_title = [plot_title '.png'];
myaa([4 2],plot_title)
