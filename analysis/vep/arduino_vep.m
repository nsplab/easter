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


%///// check if this is 7rabbit specifically, where the digital input channel convention is flipped (low is LED on)
is7rabbit = ~isnan(strfind(pathname,'7rabbit'));
if is7rabbit					
	LED_ON_edge = -1;			%7rabbit - LED turns on with falling edge of digital in channel
else
	LED_ON_edge = 1;				%5rabbit and 6rabbit - LED turns on with rising edge of digital in channel
end



%///// hardcoded values
fs = 9600;                                                                  %sampling rate is hardcoded at 9600 Hz; determined by recording code
                                                                            %that controls g.hiamp (see /code/easter/recording/

digitalinCh = 65;                                                           %designate the digital input channel, which is used to record
                                                                            %the LED state to align EEG data with onset or offset to generate VEP graphs 

use_lpf = 1;                                                               %0 or 1; use the lowpass filter hardcoded in the lines below
use_hpf = 1;                                                               %0 or 1; use the highpass filter hardcoded in the lines below
use_nf_60_120 = 1;                                                         %0 or 1; use the 60 and 120 Hz notch filters
                                                                           % construct various possible filters to be used on the EEG channels
hp = fdesign.highpass('Fst,Fp,Ast,Ap',(90.0),(105.0),90,1,fs);             %highpass filter; passband 90 Hz, stopband 105 Hz, sampling freqency fs
hpf = design(hp, 'butter');

lp2 = fdesign.lowpass('Fp,Fst,Ap,Ast',(300.0),(350.0),1,90,fs);             %lowpass filter; passband 300 Hz, stopband 350 Hz, butterworth; uses 
lpf2 = design(lp2, 'butter');                                               %default stopband attenuation 90 dB and passband ripple of 1 dB.

n60 = fdesign.notch('N,F0,Q,Ap',6,60,10,1,fs);                             %set parameters for 60 Hz notch filter  (N - filter order, F0 - center frequency, Q - quality factor, Ap - passband ripple (decibels)
n120 = fdesign.notch('N,F0,Q,Ap',6,120,10,1,fs);                           %set parameters for 120 Hz notch filter (N - filter order, F0 - center frequency, Q - quality factor, Ap - passband ripple (decibels)
nf60 = design(n60);                                                        %implement 60 Hz notch filter
nf120nf120 = design(n120);                                                 %implement 120 Hz notch filter
                        
%//////////////////////////////////




%//////////////////////////////////
% read the digital input channel, which contains the LED state
% (in 7rabbit, this channel is low when LED is on, and high when LED is off;
% in 6rabbit and 5rabbit, this channel is low when LED is off, and high when LED is on;
% this convention is set by the arduino code in /code/easter/recording.
% for experiments subsequent to 7rabbit, the arduino code was set back to the
% intuitivfe convention of low when LED is off, and high when LED is on.
fid = fopen([pathname filename], 'r');		%open the binary data file written in our easter binary format
fseek(fid, 4*(digitalinCh-1), 'bof');		%fseek sets the pointer to the first value read in the file. 4 represents 4 bytes.
						%we're starting to read from the digital input channel, the first value of which is
						%4*(digitalinCh-1) bytes into the file.
dataColumnDig = fread(fid, Inf, 'single', 4*64); 	%fread iteratively reads values the file and places them into the vector 'dataColumn', 
					      	%representing all amplitudes from the current channel.. Inf causes fread to continue until it 
					      	%reaches EOF (end of file). 4*64 tells fread to skip 4*64 bytes to get the next value.
time_axis = (0:length(dataColumnDig)-1)*1.0/fs;  	%define a time axis, based on sampling rate (fs) and the length of the recording
figure;plot(time_axis,dataColumnDig);		%plot and visualize the digital input channel

tmp = (dataColumnDig>0);			%make sure the digital In takes on binary values: take any negative excursions to 0
t1 = diff(tmp);					%compute any edges in the digital trace
t2 = find(t1==LED_ON_edge);				%find the edges that correspond to LED turning on





positive = floor(0.6 * fs);						%
negative = floor(0.1 * fs) - 1;
total = positive + negative + 1;

% choose the colormap for the plots
CM = colorcube(size(data,1)+1);
%CM = distinguishable_colors(size(data,1)+1);

% draw the figure with white background and full screen
fgh = figure('Color',[1 1 1],'units','normalized','outerposition',[0 0 1 1]);
hold on

% the titles in the legend
legends = [];

for ii=1:size(data,1)
    ii
    
    chData = data{ii,2};

    %highPassed = filtfilt(hpf.sosMatrix,hpf.ScaleValues,chData);
    %bandPassed = filtfilt(lpf.sosMatrix,lpf.ScaleValues,chData);
    bandPassed = filtfilt(lpf2.sosMatrix,lpf2.ScaleValues,chData);

    m = [];

    for jj=2:length(t2)-1,
         %m(end+1, 1:total) = bandPassed((t2(i)-negative):(t2(i)+positive)) - bandPassedEar((t2(i)-negative):(t2(i)+positive));
        %m(end+1, 1:total) = detrend(chData((t2(j)-negative):(t2(j)+positive)));
        m(end+1, 1:total) = detrend(bandPassed((t2(jj)-negative):(t2(jj)+positive)));
    end
     
    t = (-negative:positive)/fs*1000;
    am = mean(m);
    legends(end+1) = plot(t, am,'color',CM(ii,:),'linewidth',2);
end

% add the legend
legend(legends, data{:,1})

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

