clear
close all
figure
%Set a cell with the datafile names that we need
%data: has the file location for the dataset
%name: has the description of that dataset
%indicator: indicator variable to extract the limits of the data from the
%metadatafile
data{1} = '/home/leon/Data/Characterization/50mVPP';
name{1} = 'PlatBlck (0.52mm, 50mV P2P)';
data{2} = '/home/leon/Data/Characterization/100mVPP';
name{2} = 'PlatBlck (0.52mm, 100mV P2P)';
data{3} = '/home/leon/Data/Characterization/200mVPP';
name{3} = 'PlatBlck (0.52mm, 200mV P2P)';
data{4} = '/home/leon/Data/Characterization/300mVPP';
name{4} = 'PlatBlck (0.52mm, 300mV P2P)';


wind = 512;
fs = 19200;%sampling frequency
color_array = copper(length(data));
marker_array = {'.','o','d','s','x','s','d','^','v','>','<','p','h'};
for data_idx = 1:length(data)
    datafile = data{data_idx};
    readdata %This reads the data and extract channel 1 and 2, 
    ana_channel = channel_2;
    figure(1)
    subplot(length(data),1,data_idx)
    ntp =size(ana_channel, 1);
    t = (1:ntp)/fs;
    d  = fdesign.notch('N,F0,Q,Ap',6,60,10,1, fs);
    notch = design(d, 'cheby1');
    filt_channel = filtfilt(notch.sosMatrix, notch.ScaleValues, double(ana_channel));
    %plot(t, filt_channel)
    plot(t, ana_channel)
    title(name{data_idx})
    xlabel('Time(sec)')
    ylabel('uVolts')
    set(gca, 'fontsize', 18)
    figureHandle = gcf;
    set(findall(figureHandle,'type','text'),'fontSize',24,'fontWeight','bold', 'color', [0,0,0])
    set(gcf, 'color', [1,1,1])
    set(gcf,'renderer', 'zbuffer');
    set(gcf, 'Position', get(0,'Screensize'));
    
    figure(2)
    subplot(length(data),1,data_idx)
    plot_psd(ana_channel, fs, 'b')
    ax=axis
    axis([0 5 ax(3) ax(4)])
    title(name{data_idx})
    set(gca, 'fontsize', 18)
    figureHandle = gcf;
    set(findall(figureHandle,'type','text'),'fontSize',24,'fontWeight','bold', 'color', [0,0,0])
    set(gcf, 'color', [1,1,1])
    set(gcf,'renderer', 'zbuffer');
    set(gcf, 'Position', get(0,'Screensize'));
    
    
end
    