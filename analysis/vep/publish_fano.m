%arduino_vep.m
%
%This script runs the VEP analysis on a single file represented by 'pathname' and 'filename'
%
%Requires:
%	pathname - path for the data in easter binary format
%	filename - file name for the data in easter binary format
%	data	 - cell array contains channel labels and channel values; does not include the digitalinCh channel
%		   example: data{4,1} is the label for channel 4.
%			    data{4,2} is the vector of voltage values (microvolts) for channel 4

%//////////////////////////////////
% if you want to ask the user to select a single binary data file, uncomment this block
%run('../utilities/loaddata.m');		%populates the variable names pathname, filename, and data
%//////////////////////////////////


%///// hardcoded values that you should keep unchanged

fs = original_sampling_rate_in_Hz;
                                                                           %digital input channel convention is low is LED OFF, high is LED ON; verified for VEP aruino recording code with 5rabbit, 6rabbit, 7rabbit, etc.
LED_ON_edge = 1;                                                           %LED turns on with rising edge of digital in channel (diff = 1)
LED_OFF_edge = -1;                                                         %LED turns off with falling edge of digital in channel (diff = -1)


%////////////////////////////////////////////////////////////////////
%///// hardcoded analysis options: VEP onset and offset
%////////////////////////////////////////////////////////////////////

% OPTION 1 /////// Choose how much time you would like to plot pre- and post- event onset                                                                            
%preEventPlot_sec = 0.1;                                                    %time in seconds to extend plot prior to event time (marked as time zero)
%postEventPlot_sec = 1/0.8942;                                               %time in seconds to extend plot following event time (marked as time zero). 0.9 Hz was frequency of light onset in VEP controlled by Arduino 
preEventPlot_sec = 0.05;                                                    %time in seconds to extend plot prior to event time (marked as time zero)
postEventPlot_sec = 0.5;


% OPTION 2 /////// Choose which filters you want to use in the analysis                                                                            
use_lpf = 1;                                                               %0 or 1; use the lowpass filter hardcoded in the lines below
use_hpf = 1;                                                               %0 or 1; use the highpass filter hardcoded in the lines below
use_nf_60_120_180 = 1;                                                     %0 or 1; use the 60, 120, and 180 Hz notch filters


% OPTION 3 /////// Choose desired properties of the lowpass, highpass, and notch filter options
%hp = fdesign.highpass('Fst,Fp,Ast,Ap',(10.0),(20.0),90,1,fs);             %highpass filter; passband 10 Hz, stopband 20 Hz, 1dB passband ripple, 90 dB stopband attenuation, sampling frequency fs, butterworth 
%hpf = design(hp, 'butter');

hp = fdesign.highpass('Fst,Fp,Ast,Ap',(2.0),(10.0),90,1,fs);             %highpass filter; passband 90 Hz, stopband 105 Hz, 1dB passband ripple, 90 dB stopband attenuation, sampling frequency fs, butterworth 
hpf = design(hp, 'butter');
%fvtool(hpf)

%lp = fdesign.lowpass('Fp,Fst,Ap,Ast',(50.0),(60.0),1,90,fs);             %lowpass filter; passband 300 Hz, stopband 350 Hz, 1dB passband ripple, 90 dB stopband attenuation, sampling frequency fs, butterworth 
%lpf = design(lp, 'butter');   

lp = fdesign.lowpass('Fp,Fst,Ap,Ast',(220.0),(256.0),1,90,fs);             %lowpass filter; passband 300 Hz, stopband 350 Hz, 1dB passband ripple, 90 dB stopband attenuation, sampling frequency fs, butterworth 
lpf = design(lp, 'butter');                                              

n60 = fdesign.notch('N,F0,BW,Ap',6,60,20,2,fs); % wider notch filter at 60 (from about 51 to 71 Hz)
%n60 = fdesign.notch('N,F0,BW,Ap',6,60,10,1,fs);
%n60 = fdesign.notch('N,F0,Q,Ap',6,60,10,1,fs);                             %set parameters for 60 Hz notch filter  (N - filter order, F0 - center frequency, Q - quality factor, Ap - passband ripple (decibels)
n120 = fdesign.notch('N,F0,Q,Ap',6,120,10,1,fs);                           %set parameters for 120 Hz notch filter (N - filter order, F0 - center frequency, Q - quality factor, Ap - passband ripple (decibels)
n180 = fdesign.notch('N,F0,Q,Ap',6,180,10,1,fs);                           %set parameters for 180 Hz notch filter (N - filter order, F0 - center frequency, Q - quality factor, Ap - passband ripple (decibels)
nf60 = design(n60);                                                        %implement 60 Hz notch filter
nf120 = design(n120);                                                      %implement 120 Hz notch filter
nf180 = design(n180);                                                      %implement 180 Hz notch filter
                        
%////////////////////////////////////////////////////////////////////
%////////////////////////////////////////////////////////////////////





%//////////////////////////////////
% Look for LED ON and OFF transitions based on digital input channel (65)
%//////////////////////////////////

diff_cleanDigitalIn = diff(cleanDigitalIn);                                %compute any edges in the digital trace
event_index_LED_ON = find(diff_cleanDigitalIn==LED_ON_edge);               %find the edges that correspond to LED turning on
event_index_LED_OFF = find(diff_cleanDigitalIn==LED_OFF_edge);             %find the edges that correspond to LED turning off
event_index_LED = find(diff_cleanDigitalIn ~= 0);
event_time_diff = median(diff(event_index_LED));

preEventPlot_samples = floor(preEventPlot_sec*fs);                         %time in # samples to extend plot prior to event time; preEventPlot_sec - see hardcoded parameters above
postEventPlot_samples = floor(postEventPlot_sec*fs)-1;                     %time in # samples to extend plot following event time; postEventPlot_sec - see hardcoded parameters above
totalEventPlot_samples = preEventPlot_samples + postEventPlot_samples+1;   % total # of samples to plot
time_axis = (-preEventPlot_samples:postEventPlot_samples)/fs*1000;         %prepare the time axis for the plots based on samples to plot


%fgh = figure('Color',[1 1 1],'units','normalized',...                      %get the figure handle, and draw the figure with white background and full screen
%                                                'outerposition',[0 0 1 1]);
fgh = figure('Color',[1 1 1],'units','pixels',...                      %get the figure handle, and draw the figure with white background and full screen
                                                'outerposition',[0 0 1366 768]);
%CM = colorcube(size(data,1)+1);                                            % choose the colormap for the plots
hold on;

plotline_handles_ON = [];                                                  %prepare to accumulate LED ON plot line handles for the figure legend
plotline_handles_OFF = [];                                                 %prepare to accumulate LED OFF plot line handles for the figure legend
channels_plotted = [];                                                     %keep track of which channels were actually plotted - some are skipped if plot_disconnected_channels = 0 (set in plot_all_vep)
                                                                           %used for the figure legends

channelToPlot = [2,3,5,7,8];
%CM = [hex2dec('e9'), hex2dec('00'), hex2dec('3a'); hex2dec('ff'), hex2dec('ba'),hex2dec('00'); hex2dec('18'),hex2dec('26'),hex2dec('b0'); hex2dec('58'),hex2dec('e0'), hex2dec('00'); hex2dec('00'),hex2dec('00'),hex2dec('00')];
CM = [hex2dec('e9'), hex2dec('00'), hex2dec('3a');
      hex2dec('ff'), hex2dec('ba'), hex2dec('00');
      hex2dec('40'), hex2dec('40'), hex2dec('ff');
      hex2dec('58'), hex2dec('e0'), hex2dec('00');
      hex2dec('b0'), hex2dec('00'), hex2dec('b0')];

CM = CM/256;
                                                                           
                                                                           
for ii=1:length(channelToPlot)                                                      %for each channel

    fprintf(['ii: ' int2str(ii) '\n']);
                                                                           %plot_only_neuro_and_endo_channels - set in plot_all_vep.m
    channels_plotted = [channels_plotted channelToPlot(ii)];
      
    
    chData = data{channelToPlot(ii),2};                                                   %load the timeseries recording for that channel
    
    %//////////////////////////////////////////////////////////////////////
    %/// filter the data if it's been requested in hardcoded block above
    %//////////////////////////////////////////////////////////////////////
    tic
    if use_nf_60_120_180
        chData = filtfilt(nf60.sosMatrix, nf60.ScaleValues,chData);
        chData = filtfilt(nf120.sosMatrix, nf120.ScaleValues,chData);
        chData = filtfilt(nf180.sosMatrix, nf180.ScaleValues,chData);
    end
    if use_hpf
        chData = filtfilt(hpf.sosMatrix, hpf.ScaleValues,chData);
    end
    if use_lpf
        chData = filtfilt(lpf.sosMatrix, lpf.ScaleValues,chData);
    end    
    chData = qrs_removal(chData, data{find(strcmp(data, 'Bottom Precordial')), 2});
    toc
    %fig = gcf;
    %figure;
    %hold on;
    %plot((1:numel(chData))/fs, chData)
    %yl = ylim;
    %plot((1:numel(chData))/fs, (0.8 * cleanDigitalIn + 0.1) * (yl(2) - yl(1)) + yl(1), 'Color', 'red')
    %xlabel('Time (seconds)');
    %ylabel('Measurement');
    %title(data{channelToPlot(ii),1});
    %figure(gcf);
    %continue;
    %//////////////////////////////////////////////////////////////////////
    

    %//////////////////////////////////////////////////////////////////////
    %/// compute and plot the average event-aligned LED ON response for
    %this channel
    %//////////////////////////////////////////////////////////////////////

    chData_all_single_trial_collection_ON = [];                            %matrix of all single trial responses for the single channel stored in chData, aligned to ON (rising edges of digital input signal)
    for jj=2:length(event_index_LED_ON)-1,                                 %for each LED ON event, snip out that segment and append it as a row in chData_all_single_trial_responses_ON
        %offset = mean(chData((event_index_LED_ON(jj)-preEventPlot_samples):(event_index_LED_ON(jj))));
        
        index = find(event_index_LED == event_index_LED_ON(jj));
        prev = event_index_LED(index - 1);
        curr = event_index_LED(index);
        next = event_index_LED(index + 1);
        nex2 = event_index_LED(index + 2);
        e1 = abs((curr - prev - event_time_diff) / event_time_diff);
        e2 = abs((next - curr - event_time_diff) / event_time_diff);
        e3 = abs((nex2 - next - event_time_diff) / event_time_diff);
        if (e1 > 0.001 || e2 > 0.001 || e3 > 0.001)
            continue;
        end
        %if (event_index_LED_OFF(jj) > event_index_LED_ON(jj)) 

        %    if (event_index_LED_ON(jj) < (event_index_LED_OFF(jj-1) + postEventPlot_samples/2))
        %        continue;
        %    end

        %    if (event_index_LED_ON(jj) > (event_index_LED_OFF(jj) - postEventPlot_samples/2))
        %        continue;
        %    end
        %    
        %else
        %    
        %    if (event_index_LED_ON(jj) < (event_index_LED_OFF(jj) + postEventPlot_samples/2))
        %        continue;
        %    end
        %    
        %    if (event_index_LED_ON(jj) > (event_index_LED_OFF(jj+1) - postEventPlot_samples/2))
        %        continue;
        %    end
        %    
        %end
        
        chData_all_single_trial_collection_ON(end+1, 1:totalEventPlot_samples)...
            = detrend(chData((event_index_LED_ON(jj)-preEventPlot_samples):...
                            (event_index_LED_ON(jj)+postEventPlot_samples)));
    end
    %sorted = sort(max(abs(chData_all_single_trial_collection_ON),[],2));
    %thresh = sorted(ceil(0.95 * numel(sorted))); % TODO: use selection algorithm, rather than sort
    %valid = ~any(abs(chData_all_single_trial_collection_ON) > thresh, 2);
    %chData_all_single_trial_collection_ON = chData_all_single_trial_collection_ON(valid, :);
    %fprintf('thresh: %f\nsize: %d %d\n\n', thresh, size(chData_all_single_trial_collection_ON, 1), size(chData_all_single_trial_collection_ON, 2));
    %if ((strcmp(S{i}, '_Tue_06.05.2014_14%3A04%3A18_vep_') || strcmp(S{i}, '_Thu_15.05.2014_14%3A13%3A26_vep_')) && (channelToPlot(ii) == 2)) % remove for mid-basilar experiment rabbit 9 and 10 endo
    %    % remove qrs mean
    %    fprintf('remove qrs mean\n');
    %    amount = round(0.4* 9600);
    %    time_steps = size(chData_all_single_trial_collection_ON, 2);
    %    trials = size(chData_all_single_trial_collection_ON, 1);
    %    [~, index] = max(chData_all_single_trial_collection_ON(:, 1:amount),[],2);
    %    %plot(time_axis, chData_all_single_trial_collection_ON,'color',CM(ii,:),'linewidth',1);
    %    padded = nan(trials, time_steps + amount);
    %    for count = 1:trials
    %        padded(count, amount - index(count) + (1:time_steps)) = chData_all_single_trial_collection_ON(count, :);
    %    end
    %    qrs = nanmean(padded, 1);
    %    for count = 1:trials
    %        chData_all_single_trial_collection_ON(count, :) = padded(count, amount - index(count) + (1:time_steps)) - qrs(amount - index(count) + (1:time_steps));
    %    end
    %end


    %fano = @(data) std(data).^2 ./ mean(data .^ 2); % square of fano
    snr = @(data) mean(data .^ 2) ./ var(data); % square of fano
    %chData_trial_averaged_ON = std(chData_all_single_trial_collection_ON);%record the trial-averaged response aligned to LED ON (rising edges of digital input signal)
    chData_trial_averaged_ON = snr(chData_all_single_trial_collection_ON);%record the trial-averaged response aligned to LED ON (rising edges of digital input signal)
    %size(chData_all_single_trial_collection_ON)
    
    if publication_quality == 1 || publication_quality == 3
        %confMean = bootci(100, @std, chData_all_single_trial_collection_ON);
        confMean = bootci(100, snr, chData_all_single_trial_collection_ON);
        %size(chData_all_single_trial_collection_ON)
        %size(chData_trial_averaged_ON)
        %size(std(chData_all_single_trial_collection_ON))
        %confMean = repmat(chData_trial_averaged_ON, [2, 1]) + [-1;1] * std(chData_all_single_trial_collection_ON) / sqrt(size(chData_all_single_trial_collection_ON, 1));
        if publication_quality == 1
%            subplot(2,1,1);hold on;
            px = [time_axis, fliplr(time_axis)];
            py = [confMean(1,:), fliplr(confMean(2,:))];
            patch(px,py,1,'FaceColor',CM(ii,:),'EdgeColor','none');
            alpha(.2);
        end
        if publication_quality == 3
%            subplot(2,1,1);hold on;
            plot(time_axis, confMean(1,:),'--','color',CM(ii,:),'linewidth',2);
            plot(time_axis, confMean(2,:),'--','color',CM(ii,:),'linewidth',2);
        end

    end

    %}
    
%    subplot(2,1,1);hold on;
    hold on;
    %plotline_handles_ON(end+1) = plot(time_axis, chData_trial_averaged_ON,'color',CM(ii,:),'linewidth',2);
    plot(time_axis, chData_trial_averaged_ON,'color',CM(ii,:),'linewidth',2);
       
    %//////////////////////////////////////////////////////////////////////
    %/// compute and plot the average event-aligned LED OFF response for this
    %channel
    %//////////////////////////////////////////////////////////////////////

    
    chData_all_single_trial_collection_OFF = [];                            %matrix of all single trial responses for the single channel stored in chData, aligned to OFF (rising edges of digital input signal)
    for jj=2:length(event_index_LED_OFF)-1,                                 %for each LED OFF event, snip out that segment and append it as a row in chData_all_single_trial_responses_OFF

        index = find(event_index_LED == event_index_LED_OFF(jj));
        prev = event_index_LED(index - 1);
        curr = event_index_LED(index);
        next = event_index_LED(index + 1);
        nex2 = event_index_LED(index + 2);
        e1 = abs((curr - prev - event_time_diff) / event_time_diff);
        e2 = abs((next - curr - event_time_diff) / event_time_diff);
        e3 = abs((nex2 - next - event_time_diff) / event_time_diff);
        if (e1 > 0.001 || e2 > 0.001 || e3 > 0.001)
            continue;
        end
        %if (event_index_LED_OFF(jj) > event_index_LED_ON(jj)) 

        %    if (event_index_LED_OFF(jj) < (event_index_LED_ON(jj) + postEventPlot_samples/2))
        %        continue;
        %    end

        %    if (event_index_LED_OFF(jj) > (event_index_LED_ON(jj+1) - postEventPlot_samples/2))
        %        continue;
        %    end
        %    
        %else
        %    
        %    if (event_index_LED_OFF(jj) < (event_index_LED_ON(jj-1) + postEventPlot_samples/2))
        %        continue;
        %    end

        %    if (event_index_LED_OFF(jj) > (event_index_LED_ON(jj) - postEventPlot_samples/2))
        %        continue;
        %    end
        %    
        %end
        
        
        %offset = mean(chData((event_index_LED_OFF(jj)-preEventPlot_samples):(event_index_LED_OFF(jj))));
        chData_all_single_trial_collection_OFF(end+1, 1:totalEventPlot_samples)...
            = detrend(chData((event_index_LED_OFF(jj)-preEventPlot_samples):...%segment and detrend signal from this individual trial and channel
                            (event_index_LED_OFF(jj)+postEventPlot_samples)));
    end
    chData_trial_averaged_OFF = mean(chData_all_single_trial_collection_OFF);%record the trial-averaged response aligned to LED ON (rising edges of digital input signal)

    %{
    if publication_quality == 1
        confMean = bootci(800, @mean, chData_all_single_trial_collection_OFF);
    end
    if publication_quality == 3
        confMean = bootci(800, @mean, chData_all_single_trial_collection_OFF);
    end
    
    if publication_quality == 1
        subplot(2,1,2);hold on;
        px=[time_axis, fliplr(time_axis)];
        py = [ confMean(1,:),  fliplr(confMean(2,:))];
        patch(px,py,1,'FaceColor',CM(ii,:),'EdgeColor','none');
        alpha(.2);
    end
    if publication_quality == 3
        subplot(2,1,2);hold on;
        plot(time_axis, confMean(1,:),'--','color',CM(ii,:),'linewidth',2);
        plot(time_axis, confMean(2,:),'--','color',CM(ii,:),'linewidth',2);
    end

    subplot(2,1,2);hold on;
    plotline_handles_OFF(end+1) = plot(time_axis, chData_trial_averaged_OFF,'color',CM(ii,:),'linewidth',2);
    %}
end
%return

%subplot(2,1,1);
hold on;
%ylim([-15 15]);
%ylim([0 30]);
yrange = ylim;
%yrange
digitalInOffset = yrange(1) - ((abs(yrange(1)) + abs(yrange(2))) / 40);

digitalIn_all_single_trial_collection_ON = [];

for jj=2:length(event_index_LED_ON)-1,

    index = find(event_index_LED == event_index_LED_ON(jj));
    prev = event_index_LED(index - 1);
    curr = event_index_LED(index);
    next = event_index_LED(index + 1);
    nex2 = event_index_LED(index + 2);
    e1 = abs((curr - prev - event_time_diff) / event_time_diff);
    e2 = abs((next - curr - event_time_diff) / event_time_diff);
    e3 = abs((nex2 - next - event_time_diff) / event_time_diff);
    if (e1 > 0.001 || e2 > 0.001 || e3 > 0.001)
        continue;
    end
    %if (event_index_LED_ON(jj) < (event_index_LED_OFF(jj-1) + postEventPlot_samples/2))        %checking for a minority of trials (typically in Rabbit 8) where VEP trigger unexpectedly stayed low or high for longer than the expected time
    %    continue;                                                           %discard that anomaly trial from the average (code added by Mosalam on 5/9/14)
    %end

    %if (event_index_LED_ON(jj) > (event_index_LED_OFF(jj) - postEventPlot_samples/2))
    %    continue;
    %end

    digitalInDataPlot = cleanDigitalIn((event_index_LED_ON(jj)-preEventPlot_samples):(event_index_LED_ON(jj)+postEventPlot_samples));
    %digitalInDataPlot = digitalInDataPlot * ((abs(yrange(1)) + abs(yrange(2))));
    %digitalInDataPlot = digitalInDataPlot + digitalInOffset;
    %digitalIn_all_single_trial_collection_ON(end+1,:) = digitalInDataPlot;
    digitalInDataPlot = 0.9 * digitalInDataPlot * abs(yrange(2) - yrange(1));
    digitalInDataPlot = digitalInDataPlot + yrange(1) + 0.05 * abs(yrange(2) - yrange(1));

    plot(time_axis, digitalInDataPlot, 'k', 'linewidth', 2);
end

%subplot(2,1,2);hold on;
digitalIn_all_single_trial_collection_OFF = [];

for jj=2:length(event_index_LED_OFF)-1,

    if (event_index_LED_OFF(jj) < (event_index_LED_ON(jj) + postEventPlot_samples/2))
        continue;
    end

    if (event_index_LED_OFF(jj) > (event_index_LED_ON(jj+1) - postEventPlot_samples/2))
        continue;
    end
    
    digitalInDataPlot = cleanDigitalIn((event_index_LED_OFF(jj)-preEventPlot_samples):(event_index_LED_OFF(jj)+postEventPlot_samples));
    digitalInDataPlot = digitalInDataPlot * ((abs(yrange(1)) + abs(yrange(2))));
    digitalInDataPlot = digitalInDataPlot + digitalInOffset;
    digitalIn_all_single_trial_collection_OFF(end+1,:) = digitalInDataPlot;

%    plot(time_axis, digitalInDataPlot, 'k', 'linewidth', 2);
end
    %}

vep_data{i}.chData_all_single_trial_collection_ON = chData_all_single_trial_collection_ON;  %vep_data will be stored to a .mat file, a single variable containing all the essential processed VEP data from this subject
vep_data{i}.chData_all_single_trial_collection_OFF = chData_all_single_trial_collection_OFF;
vep_data{i}.time_axis = time_axis;
vep_data{i}.channel_labels = data(channels_plotted,1);
vep_data{i}.digitalIn_all_single_trial_collection_ON = digitalIn_all_single_trial_collection_ON;%each row is trial #. column # is sample # into trial
vep_data{i}.digitalIn_all_single_trial_collection_OFF = digitalIn_all_single_trial_collection_OFF;%each row is trial #. column # is sample # into trial


%vep_data{i,3} = chData_all_single_trial_collection_ON;
%vep_data{i,4} = chData_all_single_trial_collection_OFF;
%vep_data{i,5} = time_axis;                                                 %time axis in milliseconds
%vep_data{i,6} = {data{channels_plotted,1}};                                %channel names
%vep_data{i,7} = digitalIn_all_single_trial_collection_ON;
%vep_data{i,8} = digitalIn_all_single_trial_collection_OFF;


% add the legend and labels
%subplot(2,1,1);
%legend(plotline_handles_ON, data{channels_plotted,1});
hold on
%plot([0 0], ylim, 'linewidth',4)
%tmp = title([ 'VEP ON Response: ' filename ' | GND: nose |  # samples =' int2str(length(t2)) ]);
if ~isempty(allData)
    %tmp = title({['VEP ON Response: ' int2str(size(chData_all_single_trial_collection_ON, 1)) ' trials'];allData{i}});
else
    %tmp = title(['VEP ON Response: ' int2str(size(chData_all_single_trial_collection_ON, 1)) ' trials']);
end
%set(tmp,'interpreter','none');
xlabel('Time (ms) relative to LED ON at time zero');
ylabel('SNR');
%ylabel('$\mu V$','Interpreter','LaTex');
%grid on
%grid minor
%axis tight

%subplot(2,1,2);
%{
legend(plotline_handles_OFF, data{channels_plotted,1})
hold on
%plot([0 0], ylim,'b--','linewidth',4)
%tmp = title([ 'VEP OFF Response: ' filename ' | GND: nose |  # samples =' int2str(length(t2)) ]);
if length(allData) == 1
    tmp = title(['VEP OFF Response: '  allData{1}(i)]);
else
    tmp = title(['VEP OFF Response']);
end
set(tmp,'interpreter','none');
xlabel('time (ms) relative to LED OFF at time zero');
ylabel('$\mu V$','Interpreter','LaTex');
%grid on
%grid minor
%axis tight
%}

set(findall(fgh,'type','text'),'fontSize',40,'fontWeight','normal', 'color', [0,0,0]);
set(gca,'FontSize',40);

name = [S{i} '_fano'];
%name = [S{i} '_std'];
name(name == '.') = '_';
while any(name == '%')
    index = find(name == '%', 1);
    name = [name(1:(index-1)) '_' name((index+3):end)];
end
%xlim([-50, 100])
%pause(3)
%save2pdf(pdf_name, f, 300);

saveas(fgh, ['matlab_data/' name '.fig']);      %save the matlab figure to file

xlim([100, 500]);
save2pdf(['matlab_data/' name '_late.pdf'], fgh, 1200);      %save the matlab figure to file

xlim([-50, 100]);
saveas(fgh, ['matlab_data/' name '.epsc']);     %save the matlab figure to file
%saveas(fgh, ['matlab_data/' name '.pdf']);      %save the matlab figure to file
save2pdf(['matlab_data/' name '.pdf'], fgh, 1200);      %save the matlab figure to file

