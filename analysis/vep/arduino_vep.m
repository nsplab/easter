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
fs = 9600;                                                                 %sampling rate is hardcoded at 9600 Hz; determined by recording code
                                                                           %that controls g.hiamp (see /code/easter/recording/

digitalinCh = 65;                                                          %designate the digital input channel, which is used to record
                                                                           %the LED state to align EEG data with onset or offset to generate VEP graphs 

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
use_lpf = 1;                                                               %0 or 1; use the lowpass filter hardcoded in the lines below
use_hpf = 1;                                                               %0 or 1; use the highpass filter hardcoded in the lines below
use_nf_60_120 = 1;                                                         %0 or 1; use the 60 and 120 Hz notch filters


% OPTION 3 /////// Choose desired properties of the lowpass, highpass, and notch filter options
hp = fdesign.highpass('Fst,Fp,Ast,Ap',(90.0),(105.0),90,1,fs);             %highpass filter; passband 90 Hz, stopband 105 Hz, 1dB passband ripple, 90 dB stopband attenuation, sampling frequency fs, butterworth 
hpf = design(hp, 'butter');

lp = fdesign.lowpass('Fp,Fst,Ap,Ast',(300.0),(350.0),1,90,fs);             %lowpass filter; passband 300 Hz, stopband 350 Hz, 1dB passband ripple, 90 dB stopband attenuation, sampling frequency fs, butterworth 
lpf = design(lp2, 'butter');                                              

n60 = fdesign.notch('N,F0,Q,Ap',6,60,10,1,fs);                             %set parameters for 60 Hz notch filter  (N - filter order, F0 - center frequency, Q - quality factor, Ap - passband ripple (decibels)
n120 = fdesign.notch('N,F0,Q,Ap',6,120,10,1,fs);                           %set parameters for 120 Hz notch filter (N - filter order, F0 - center frequency, Q - quality factor, Ap - passband ripple (decibels)
nf60 = design(n60);                                                        %implement 60 Hz notch filter
nf120 = design(n120);                                                      %implement 120 Hz notch filter
                        
%////////////////////////////////////////////////////////////////////
%////////////////////////////////////////////////////////////////////



%//////////////////////////////////
% read the digital input channel, which contains the LED state
% (in 7rabbit, this channel is low when LED is on, and high when LED is off;
% in 6rabbit and 5rabbit, this channel is low when LED is off, and high when LED is on;
% this convention is set by the arduino code in /code/easter/recording.
% for experiments subsequent to 7rabbit, the arduino code was set back to the
% intuitivfe convention of low when LED is off, and high when LED is on.
fid = fopen([pathname filename], 'r');                                     %open the binary data file written in our easter binary format
fseek(fid, 4*(digitalinCh-1), 'bof');                                      %fseek sets the pointer to the first value read in the file. 4 represents 4 bytes.
                                                                           %we're starting to read from the digital input channel, the first value of which is
                                                                           %4*(digitalinCh-1) bytes into the file.
dataColumnDig = fread(fid, Inf, 'single', 4*64);                           %fread iteratively reads values the file and places them into the vector 'dataColumn', 
                                                                           %representing all amplitudes from the current channel.. Inf causes fread to continue until it 
                                                                           %reaches EOF (end of file). 4*64 tells fread to skip 4*64 bytes to get the next value.
%time_axis = (0:length(dataColumnDig)-1)*1.0/fs;                           %define a time axis, based on sampling rate (fs) and the length of the recording
%figure;plot(time_axis,dataColumnDig);                                     %plot and visualize the digital input channel

cleanDigitalIn = (dataColumnDig>0);                                        %make sure the digital In takes on binary values: take any negative excursions to 0
diff_cleanDigitalIn = diff(cleanDigitalIn);                                %compute any edges in the digital trace
event_index_LED_ON = find(diff_cleanDigitalIn==LED_ON_edge);               %find the edges that correspond to LED turning on
event_index_LED_OFF = find(diff_cleanDigitalIn==LED_OFF_edge);             %find the edges that correspond to LED turning off


preEventPlot_samples = floor(preEventPlot_sec*fs);                         %time in # samples to extend plot prior to event time; preEventPlot_sec - see hardcoded parameters above
postEventPlot_samples = floor(postEventPlot_sec*fs)-1;                     %time in # samples to extend plot following event time; postEventPlot_sec - see hardcoded parameters above
totalEventPlot_samples = preEventPlot_samples + postEventPlot_samples+1;     % total # of samples to plot
time_axis = (-preEventPlot_samples:postEventPlot_samples)/fs*1000;          %prepare the time axis for the plots based on samples to plot

% choose the colormap for the plots
CM = colorcube(size(data,1)+1);
%CM = distinguishable_colors(size(data,1)+1);

% draw the figure with white background and full screen
fgh = figure('Color',[1 1 1],'units','normalized','outerposition',[0 0 1 1]);
hold on

plotline_handles = [];                                                      %prepare to accumulate plot line handles for the figure legend

    
for ii=1:size(data,1)
    ii
    
    chData = data{ii,2};

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
    

    chData_all_single_trial_collection_ON = [];                            %matrix of all single trial responses for the single channel stored in chData, aligned to ON (rising edges of digital input signal)
    for jj=2:length(event_index_LED_ON)-1,                                 %for each LED ON event, snip out that segment and append it as a row in chData_all_single_trial_responses_ON
        chData_all_single_trial_collection_ON(end+1, 1:totalEventPlot_samples)...
            = detrend(chData((event_index_LED_ON(jj)-preEventPlot_samples):...
                            (event_index_LED_ON(jj)+postEventPlot_samples)));
    end
    chData_trial_averaged_ON = mean(chData_all_single_trial_collection_ON);%record the trial-averaged response aligned to LED ON (rising edges of digital input signal)
    


    plotline_handles(end+1) = plot(time_axis, am,'color',CM(ii,:),'linewidth',2);
end

% add the legend
legend(plotline_handles, data{:,1})

tmp = title([ 'VEP: ' filename ' | GND: nose |  # samples =' int2str(length(t2)) ]);
set(tmp,'interpreter','none');

xlabel('time (ms)');
ylabel('$\mu V$','Interpreter','LaTex');

hold on
plot([0 0], ylim, 'linewidth',3)

grid on
grid minor

axis tight

hold off

tmp = title(['VEP: '  allData{1}(i)]);
set(tmp,'interpreter','none');

%saveas(fgh, ['matlab_data/' S{i} '.fig']);		%save the matlab figure to file

