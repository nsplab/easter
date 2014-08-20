%Matlab script that generates Gain and Phase plots for different materials
%and different Catheters.
%The script reads a file called: metadata, that you can specify in the call
%for extract limits.
%The metadata file has the filenames of all the experiments, which use the
%convention MaterialCatheter for its naming (i.e. An experiment with
%Platinum using the Terumo catheter would have as its filename
%PlatinumTerumo)
%In the metadatafile there is information of the dataranges to use as well
%as the parameters for selecting the cutoff frequencies.

%The scripts iterates firs over catheters and then over materials
clear

%close all
fig=figure;
%Set a cell with the datafile names that we need
%data: has the file location for the dataset
%name: has the description of that dataset
%indicator: indicator variable to extract the limits of the data from the
%metadatafile
%AgagCl Electrode set
%material = {'AgAgCl' 'Platinum' 'PlatinumBlack'}
%catheter = {'Magic' 'Echelon10' 'Echelon14' 'Terumo' 'ProximalBathShort' 'ProximalBathLong'};
%catheter = {'Close' 'Middle'};
catheter = {'Echelon10'}
%catheter = catheter_idx;
material = 'PlatinumBlack';
folder = '/home/leon/Data/Characterization/PublicationData/GoodData/';
cidx = 1;
% for material_idx = material
%     data{cidx} = cell2mat([folder material_idx catheter]);
%     name{cidx} = cell2mat([material_idx ' ' catheter]);
%     indicator{cidx} = cell2mat([material_idx catheter]);
%     cidx = cidx + 1;
% end

for catheter_idx = catheter
    data{cidx} = cell2mat([folder material catheter_idx]);
    name{cidx} = cell2mat([material ' ' catheter_idx]);
    indicator{cidx} = cell2mat([material catheter_idx]);
    cidx = cidx + 1;
end
clear data indicator name
data ={}
name= {}
indicator = {}
data{1} = ([folder 'MirageEchelon10a']);
%data{2} = ([folder 'Xped10Echelon10a']);
data{end+1} = ([folder 'Xped10Echelon10b']);
name{1} = (['Mirage Echelon10a']);
%name{2} = (['Xped10 Echelon10a']);
name{end+1} = (['Xped10 Echelon10b']);

indicator{1} = (['MirageEchelon10a']);
%indicator{2} = (['Xped10Echelon10a']);
indicator{end+1} = (['Xped10Echelon10b']);


wind = 512;
fs = 19200;%sampling frequency
%color_array = distinguishable_colors(length(data));
color_array = [255,13, 0; 255,184, 0; 23, 41, 176; 0, 198, 24; 166, 120, 0; 0, 0, 0];
color_array = color_array/255;
marker_array = {'.','o','d','s','x','s','d','^','v','>','<','p','h'};
for data_idx = 1:length(data)
%for data_idx = 1:1
    datafile = data{data_idx};
    readdata %This reads the data and extract channel 1 and 2, 
    %1 is connected to the box channel 1 and 2 is in the box channel 42
    [lim1, lim2, limit] = extract_limits('/home/leon/Data/Characterization/PublicationData/GoodData/metadata_files', indicator{data_idx});
    limit = -1.5e5;
    datain = channel_3(lim1:lim2);
    dataout = channel_2(lim1:lim2);
    datareference = channel_3(lim1:lim2);%Only for marking the separation in frequencies
    data_cell = extract_frequencies_double(datain, dataout, datareference,limit); %extract a data cell that has all the ifnormation
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
        [sin_in, phase_in, gain_in, score] = fitdata(filter_in, frequency, [0,0,1], fs);
        [sin_out, phase_out, gain_out, score] = fitdata(filter_out, frequency, [0,0,1], fs);
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
    data_plot(data_idx).phase = phasen;
    data_plot(data_idx).phase_in = [data_hold(:).phase_in];
    data_plot(data_idx).phase_out = [data_hold(:).phase_out];
    data_plot(data_idx).gain = gain_arr;
    data_plot(data_idx).gain_in = [data_hold(:).gain_in];
    data_plot(data_idx).gain_out = [data_hold(:).gain_out];
    marker = marker_array{mod(data_idx,numel(marker_array))+1};
    color = color_array(data_idx, :);
    subplot(2,1,2)
    phase_pl(data_idx) = semilogx(freq_ar, phasen,'color', color*0.6, 'LineWidth', 4,...
    'Marker', marker, 'MarkerFaceColor', color, 'MarkerEdgeColor',color*0.6, 'MarkerSize', 12);
    hold on
    title('Phase difference of the input vs the output signals (Ph_{out}-Ph_{in})')
    ylabel('Phase (degrees)')
    xlabel('Frequency (Hz)')
    ax = axis;
    axis([0.5 ax(2) ax(3) ax(4)]);
    set(gca, 'fontsize', 18)
    set(gca, 'box', 'off');
    subplot(2,1,1)
    gain_plt(data_idx) = semilogx(freq_ar, gain_arr,'color', color*0.6, 'LineWidth', 4,...
        'Marker', marker, 'MarkerFaceColor', color, 'MarkerEdgeColor',color*0.6, 'MarkerSize', 12);
    hold on
    set(gca, 'fontsize', 18)
    set(gca, 'box', 'off');
    title('Gain Ratio of the Signals (Vo/Vin)')
    ax=axis
    axis([0.5 ax(2) 0 1])
    ylabel('Gain (unitless)')
    xlabel('Frequency (Hz)')


end
figureHandle = gcf;
set(findall(figureHandle,'type','text'),'fontSize',24,'fontWeight','bold', 'color', [0,0,0])
set(gcf, 'color', [1,1,1])
set(gcf,'renderer', 'zbuffer');
set(gcf, 'Position', get(0,'Screensize'));
legend(phase_pl, name, 'location', 'EastOutside')
legend(gain_plt, name, 'location', 'EastOutside')
plot_title = cell2mat(name); %get a single string
plot_title(plot_title==' ')=[]; %remove spaces
plot_title(plot_title=='.')=[]; %remove points
%myaa([4 2],[plot_title '.png'])
%saveas(fig,plot_title,'fig')
%print(fig, '-dpsc2', plot_title);