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
preEventPlot_sec = 0.1;                                                    %time in seconds to extend plot prior to event time (marked as time zero)
postEventPlot_sec = 1/0.9/2;                                               %time in seconds to extend plot following event time (marked as time zero). 0.9 Hz was frequency of light onset in VEP controlled by Arduino 


% OPTION 2 /////// Choose which filters you want to use in the analysis                                                                            
use_lpf = 0;                                                               %0 or 1; use the lowpass filter hardcoded in the lines below
use_hpf = 0;                                                               %0 or 1; use the highpass filter hardcoded in the lines below
use_nf_60_120 = 0;                                                         %0 or 1; use the 60 and 120 Hz notch filters


% OPTION 3 /////// Choose desired properties of the lowpass, highpass, and notch filter options
hp = fdesign.highpass('Fst,Fp,Ast,Ap',(90.0),(105.0),90,1,fs);             %highpass filter; passband 90 Hz, stopband 105 Hz, 1dB passband ripple, 90 dB stopband attenuation, sampling frequency fs, butterworth 
hpf = design(hp, 'butter');

lp = fdesign.lowpass('Fp,Fst,Ap,Ast',(300.0),(350.0),1,90,fs);             %lowpass filter; passband 300 Hz, stopband 350 Hz, 1dB passband ripple, 90 dB stopband attenuation, sampling frequency fs, butterworth 
lpf = design(lp, 'butter');                                              

n60 = fdesign.notch('N,F0,Q,Ap',6,60,10,1,fs);                             %set parameters for 60 Hz notch filter  (N - filter order, F0 - center frequency, Q - quality factor, Ap - passband ripple (decibels)
n120 = fdesign.notch('N,F0,Q,Ap',6,120,10,1,fs);                           %set parameters for 120 Hz notch filter (N - filter order, F0 - center frequency, Q - quality factor, Ap - passband ripple (decibels)
nf60 = design(n60);                                                        %implement 60 Hz notch filter
nf120 = design(n120);                                                      %implement 120 Hz notch filter
                        
%////////////////////////////////////////////////////////////////////
%////////////////////////////////////////////////////////////////////





%//////////////////////////////////
% Look for LED ON and OFF transitions based on digital input channel (65)
%//////////////////////////////////

diff_cleanDigitalIn = diff(cleanDigitalIn);                                %compute any edges in the digital trace
event_index_LED_ON = find(diff_cleanDigitalIn==LED_ON_edge);               %find the edges that correspond to LED turning on
event_index_LED_OFF = find(diff_cleanDigitalIn==LED_OFF_edge);             %find the edges that correspond to LED turning off


preEventPlot_samples = floor(preEventPlot_sec*fs);                         %time in # samples to extend plot prior to event time; preEventPlot_sec - see hardcoded parameters above
postEventPlot_samples = floor(postEventPlot_sec*fs)-1;                     %time in # samples to extend plot following event time; postEventPlot_sec - see hardcoded parameters above
totalEventPlot_samples = preEventPlot_samples + postEventPlot_samples+1;   % total # of samples to plot
time_axis = (-preEventPlot_samples:postEventPlot_samples)/fs*1000;         %prepare the time axis for the plots based on samples to plot


fgh = figure('Color',[1 1 1],'units','normalized',...                      %get the figure handle, and draw the figure with white background and full screen
                                                'outerposition',[0 0 1 1]);
CM = colorcube(size(data,1)+1);                                            % choose the colormap for the plots
hold on;

plotline_handles_ON = [];                                                  %prepare to accumulate LED ON plot line handles for the figure legend
plotline_handles_OFF = [];                                                 %prepare to accumulate LED OFF plot line handles for the figure legend
channels_plotted = [];                                                     %keep track of which channels were actually plotted - some are skipped if plot_disconnected_channels = 0 (set in plot_all_vep)
                                                                           %used for the figure legends
    
for ii=1:size(data,1)                                                      %for each channel

                                                                           %plot_only_neuro_and_endo_channels - set in plot_all_vep.m
    if (plot_only_neuro_and_endo_channels) && ((strcmp(data{ii,1},'Disconnected') || strcmp(data{ii,1},'Top Precordial') || strcmp(data{ii,1},'Bottom Precordial') || strcmp(data{ii,1},'Right Leg') ))
        disp(['Channel Skipped: ' int2str(ii)]);
        continue;                                                          %tells Matlab to skip the rest of this for loop iteration and go to the next iteration
    else
        channels_plotted = [channels_plotted ii];
    end
        
    
    chData = data{ii,2};                                                   %load the timeseries recording for that channel
    
    %//////////////////////////////////////////////////////////////////////
    %/// filter the data if it's been requested in hardcoded block above
    %//////////////////////////////////////////////////////////////////////
    if use_nf_60_120
        chData = filtfilt(nf60.sosMatrix, nf60.ScaleValues,chData);
        chData = filtfilt(nf60.sosMatrix, nf120.ScaleValues,chData);
    end
    if use_hpf
        chData = filtfilt(hpf.sosMatrix, hpf.ScaleValues,chData);
    end
    if use_lpf
        chData = filtfilt(lpf.sosMatrix, lpf.ScaleValues,chData);
    end    
    %//////////////////////////////////////////////////////////////////////
    

    %//////////////////////////////////////////////////////////////////////
    %/// compute and plot the average event-aligned LED ON response for
    %this channel
    %//////////////////////////////////////////////////////////////////////

    chData_all_single_trial_collection_ON = [];                            %matrix of all single trial responses for the single channel stored in chData, aligned to ON (rising edges of digital input signal)
    for jj=2:length(event_index_LED_ON)-1,                                 %for each LED ON event, snip out that segment and append it as a row in chData_all_single_trial_responses_ON
        chData_all_single_trial_collection_ON(end+1, 1:totalEventPlot_samples)...
            = detrend(chData((event_index_LED_ON(jj)-preEventPlot_samples):...
                            (event_index_LED_ON(jj)+postEventPlot_samples)));
    end
    chData_trial_averaged_ON = mean(chData_all_single_trial_collection_ON);%record the trial-averaged response aligned to LED ON (rising edges of digital input signal)

    subplot(2,1,1);hold on;
    plotline_handles_ON(end+1) = plot(time_axis, chData_trial_averaged_ON,'color',CM(ii,:),'linewidth',2);
    
       
    %//////////////////////////////////////////////////////////////////////
    %/// compute and plot the average event-aligned LED OFF response for this
    %channel
    %//////////////////////////////////////////////////////////////////////

    chData_all_single_trial_collection_OFF = [];                            %matrix of all single trial responses for the single channel stored in chData, aligned to OFF (rising edges of digital input signal)
    for jj=2:length(event_index_LED_OFF)-1,                                 %for each LED OFF event, snip out that segment and append it as a row in chData_all_single_trial_responses_OFF
        chData_all_single_trial_collection_OFF(end+1, 1:totalEventPlot_samples)...
            = detrend(chData((event_index_LED_OFF(jj)-preEventPlot_samples):...%segment and detrend signal from this individual trial and channel
                            (event_index_LED_OFF(jj)+postEventPlot_samples)));
    end
    chData_trial_averaged_OFF = mean(chData_all_single_trial_collection_OFF);%record the trial-averaged response aligned to LED ON (rising edges of digital input signal)
    
    subplot(2,1,2);hold on;
    plotline_handles_OFF(end+1) = plot(time_axis, chData_trial_averaged_OFF,'color',CM(ii,:),'linewidth',2);
end






% add the legend and labels
subplot(2,1,1);
legend(plotline_handles_ON, data{channels_plotted,1})
hold on
plot([0 0], ylim, 'linewidth',4)
%tmp = title([ 'VEP ON Response: ' filename ' | GND: nose |  # samples =' int2str(length(t2)) ]);
if length(allData) == 1
    tmp = title(['VEP ON Response: '  allData{1}(i)]);
else
    tmp = title(['VEP ON Response']);
end
set(tmp,'interpreter','none');
xlabel('time (ms) relative to LED ON at time zero');
ylabel('$\mu V$','Interpreter','LaTex');
%grid on
%grid minor
%axis tight

subplot(2,1,2);
legend(plotline_handles_OFF, data{channels_plotted,1})
hold on
plot([0 0], ylim,'b--','linewidth',4)
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




%saveas(fgh, ['matlab_data/' S{i} '.fig']);		%save the matlab figure to file

