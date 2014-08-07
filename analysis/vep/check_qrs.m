%plot_all_vep.m
%
%Authors: M. Ebrahimi, L. Srinivasan / nspl.org
%
%Date: 4/17/14
%
%Description: This script produces one VEP graph for each VEP data set recorded in experiment given by rabbit_ID
%
%Requires:  rabbit_ID - tag for the experiment, set in the hardcoded variables block below.
%
%Output:  One figure for each VEP session, with two panels, one for the 'on' response, one for the 'off' response.
%
%Notes:  The g.tech digital input, channel 65, goes high for LED ON with 5rabbit and 6rabbit, but low for LED ON with 7rabbit
%	 This is accounted for in arduino_vep.m, which checks the pathname for '7rabbit' and chooses the appropriate convention.
%	 In subsequent rabbits after 7rabbit, the arduino code in /code/easter/ should have been changed to reflect the intuitive
%	 convention used in 5rabbit and 6rabbit of channel 65 going high for LED ON.
%	
%	The analysis code assumes a fixed sampling rate of 9600 Hz and digital input channel # of 65 (both designated in arduino_vep.m)


%///////////////////////////////////////////////
% START BLOCK: Hardcoded variables
%///////////////////////////////////////////////
clear;

%rabbit_ID = '9rabbit_may_6_2014';
rabbit_ID = '10rabbit_may_15_2014';
fs = 9600;

publication_quality = 3;                                                   % generate the high quality figures with confidence intervals. this is much slower than having it set to zero
                                                                           % 0:, 1:with confidence intervals , 2:without confidence intervals, 3: use dashed lines instead of transparent ares for confidence areas
% TODO: for some reason, publication quality 1 (shaded confidence intervals) does not save properly to pdf or eps

decimate_factor = 10;                                                      % decimate the data to speed up plotting (decimate_factor = 1 is no decimation; 10 is reasonable)
                                                                           %(this Matlab function implements proper downsampling using anti-aliasing, with decimate.m).


maxNumberOfChannels = 10;                                                  %# of consecutive analog input channels, starting with channel 1, to extract from the project easter binary files
                                                                           %(which contain 64 analog channels and the digital in channel (channel 65)

digitalinCh = 65;                                                          %designate the digital input channel, which is used to record
                                                                           %the LED state to align EEG data with onset or offset to generate VEP graphs 

original_sampling_rate_in_Hz = 9600;                                       % data is acquired with the g.Tech g.HiAmp at 9600 Hz. this is fixed for convenience. at higher rates, the 
                                                                           % digital input channel does not work reliably.

pathname = ['../../../../data/easter/' rabbit_ID '/neuro/binary_data/vep/'];%path for the data in easter binary format
%pathname_comments = ['../../../../data/easter/' rabbit_ID '/neuro/vep.txt'];%file containing comments written on the experiment day to use as labels for the figure titles
pathname_comments = ['../../../../data/easter/' rabbit_ID '/neuro/neuro_experiment_log.txt'];%file containing comments written on the experiment day to use as labels for the figure titles
                                                                           % read the comments written on the experiment day to use as labels for the figure titles
                                                                           % each line correspondes to a single run of the VEP experiment
                                                                           % this file needs to be prepared by hand
                                                                           % the total # of lines should equal the number of VEP sessions
                                                                           % the ordering of comments needs to be chronological
                                                                           % example lines:
                                                                           % 12:30 This is the comment about this particular session. g.tech Ground was nose.
                                                                           % 12:45 This was the next condition. Used Faraday cage. g.tech Ground was right leg.

pathname_matdata = ['../../../../data/easter/' rabbit_ID '/neuro/matlab_data/vep/'];

%Channel labels during VEP for all rabbits (5,6,7, etc.)
switch rabbit_ID
    case {'7rabbit_apr_15_2014', '8rabbit_apr_24_2014', '9rabbit_may_6_2014', '10rabbit_may_15_2014'}
        channelNames_VEP = {'Disconnected','Endo','Mid head','Disconnected','Right Eye','Right Leg','Back Head','Left Eye','Bottom Precordial','Top Precordial'};
        plot_only_neuro_and_endo_channels = 0;                             % choose to plot only neuro and endo channels, excluding disconnected or precordial channels
        gtechGND = 'Nose';
        earth = 'Left Leg';
    case '6rabbit_apr_11_2014'
        channelNames_VEP = {'Disconnected','Endo','Mid head','Disconnected','Right Eye','Right Leg','Back Head','Left Eye','Bottom Precordial','Top Precordial'};
    case '5rabbit_apr_15_2014'
%        channelNames_VEP = 
end
%///////////////////////////////////////////////
% END BLOCK: Hardcoded variables
%///////////////////////////////////////////////
CM = [hex2dec('e9'), hex2dec('00'), hex2dec('3a');
      hex2dec('ff'), hex2dec('ba'), hex2dec('00');
      hex2dec('40'), hex2dec('40'), hex2dec('ff');
      hex2dec('58'), hex2dec('e0'), hex2dec('00');
      hex2dec('b0'), hex2dec('00'), hex2dec('b0')];

CM = CM/256;

%channelToPlot = [2,3,5,7,8];
channelToPlot = [2,9,10];




tmp = dir(pathname);                                                       % get the list of data filenames for this particular type of evoked potential
S = {tmp(3:end).name};                                                     % chop out the '.' and '..' filename entries that are in every directory
%                                                                          %note from Ram, 4/18/14: do *not* sort by modification time - this may change; instead, rely on lexicographic sort of name which contains timestamp
%S = [tmp(:).datenum].';                                                   
%[S,S] = sort(S);
%S = {tmp(S).name};                                                        



fid = fopen(pathname_comments);
if fid==-1						%if the vep.txt comments file doesn't exist, display an error message to the console and skip the textscan
	disp('Hey - you may want to create vep.txt to populate the titles in these figures. See plot_all_vep.m for details.');
	allData = [];
else
	allData = textscan(fid,'%s','Delimiter','\n');
    % specific for rabbit 8
    C = strfind(allData{1}, '- VEP'); % get rows with '- VEP' in them
    rows = find(~cellfun('isempty', C));
    allData = allData{1}(rows);
end

%////////////////////////////////////////////////////////////////////////////////////////
% START BLOCK: Extract Data from Project Easter Binary Files to Prep for
% function call to arduino_vep.m
%////////////////////////////////////////////////////////////////////////////////////////

vep_data = cell(size(S));

%% Check for matching experiment log and data files
assert(length(S) == length(allData)); % check that the experiment log and data files have the same number of VEP runs
for i = 1:length(S)
  % Hard coded parsing of file name
  assert(strcmp(S{i}(1), '_'))
  S_day = S{i}(2:4);
  assert(strcmp(S{i}(5), '_'))
  S_date = S{i}(6:7);
  assert(strcmp(S{i}(8), '.'))
  S_month = S{i}(9:10);
  assert(strcmp(S{i}(11), '.'))
  S_month = S{i}(12:15);
  assert(strcmp(S{i}(16), '_'))
  S_hour = S{i}(17:18);
  assert(strcmp(S{i}(19:21), '%3A'))
  S_minute = S{i}(22:23);
  assert(strcmp(S{i}(24:26), '%3A'))
  S_second = S{i}(27:28);
  assert(strcmp(S{i}(29:33), '_vep_'))
  S_extra = S{i}(34:end);

  % Hard coded parsing of experiment log
  header = allData{i};
  if header(2) == ':'
      header = ['0' header]; % one digit hour - pad with extra 0
  end
  header_hour = header(1:2);
  assert(strcmp(header(3), ':'))
  header_minute = header(4:5);
  assert(strcmp(header(6), ':'))
  header_second = header(7:8);

  % Check for explicit match
  assert(strcmp(S_hour, header_hour));
  assert(strcmp(S_minute, header_minute));
  assert(strcmp(S_second, header_second));
end

hp = fdesign.highpass('Fst,Fp,Ast,Ap',(2.0),(10.0),90,1,fs);
hpf = design(hp, 'butter');

lp = fdesign.lowpass('Fp,Fst,Ap,Ast',(220.0),(256.0),1,90,fs);
lpf = design(lp, 'butter');

n60 = fdesign.notch('N,F0,BW,Ap',6,60,20,2,fs);
n120 = fdesign.notch('N,F0,Q,Ap',6,120,10,1,fs);
n180 = fdesign.notch('N,F0,Q,Ap',6,180,10,1,fs);
nf60 = design(n60);
nf120 = design(n120);
nf180 = design(n180);

%for i=12
%for i = [2 10 11 12 13 3] % rabbit 9
for i = [4 10 12 15 5] % rabbit 10


    close all;
    filename = S{i};
    fprintf('filename: %s\n', filename);
    fid = fopen([pathname filename], 'r');

    vep_data{i}.filename = filename;                                       %vep_data will be stored to a .mat file, a single variable containing all the essential processed VEP data from this subject
    vep_data{i}.allData = allData(i);                                   %vep_data will be stored to a .mat file, a single variable containing all the essential processed VEP data from this subject
%    vep_data{i,1} = filename;
%    vep_data{i,2} = allData{1}(i);
    
    data = cell(maxNumberOfChannels,2);
    dataDecimated = cell(maxNumberOfChannels,2);

    for j=1:maxNumberOfChannels,                                           %for the jth analog channel (excluding the digital in channel), load the signal into a vector in original_data{j,2}
        fseek(fid, 4*(j-1), 'bof');
        dataColumn = fread(fid, Inf, 'single', 4*64);
        channelName = channelNames_VEP{j};

        data(j,1) = {channelName};
        data(j,2) = {dataColumn};
        
        dataColumnDecimated = decimate(dataColumn,decimate_factor);                 %decimate the data by the requested factor for speed

        dataDecimated(j,1) = {channelName};
        dataDecimated(j,2) = {dataColumnDecimated};
    end
    
    fseek(fid, 4*(digitalinCh-1), 'bof');                                      %fseek sets the pointer to the first value read in the file. 4 represents 4 bytes.
                                                                               %we're starting to read from the digital input channel, the first value of which is
                                                                               %4*(digitalinCh-1) bytes into the file.
    dataColumnDig = fread(fid, Inf, 'single', 4*64);                           %fread iteratively reads values the file and places them into the vector 'dataColumn', 
                                                                               %representing all amplitudes from the current channel.. Inf causes fread to continue until it 
                                                                               %reaches EOF (end of file). 4*64 tells fread to skip 4*64 bytes to get the next value (assumes 65 channels recorded)
    cleanDigitalIn = (dataColumnDig>0);
    
    dataColumnDigDecimated = dataColumnDig(1:decimate_factor:end);                      %throw out intermediate samples to keep them aligned to the decimated channel data
    cleanDigitalInDecimated = (dataColumnDigDecimated>0);                                        %make sure the digital In takes on binary values: take any negative excursions to 0

    name = S{i};
    name(name == '.') = '_';
    while any(name == '%')
        index = find(name == '%', 1);
        name = [name(1:(index-1)) '_' name((index+3):end)];
    end

    plotline = [];
    for ii=1:length(channelToPlot)
    %for ii=1
        fgh = figure('Color',[1 1 1],'units','pixels','outerposition',[0 0 1366 768]);
        hold on;
    
        fprintf(['ii: ' int2str(ii) '\n']);

        %chData = data{find(strcmp(channelNames_VEP, 'Endo')), 2};
        chData = data{channelToPlot(ii),2}; 

        %chData = filtfilt(nf60.sosMatrix, nf60.ScaleValues,chData);
        %chData = filtfilt(nf120.sosMatrix, nf120.ScaleValues,chData);
        %chData = filtfilt(nf180.sosMatrix, nf180.ScaleValues,chData);

        %chData = filtfilt(hpf.sosMatrix, hpf.ScaleValues,chData);

        %chData = filtfilt(lpf.sosMatrix, lpf.ScaleValues,chData);

        plotline = [plotline plot((1:numel(chData))/original_sampling_rate_in_Hz, chData, 'color', CM(ii,:))];

        xlim([0 numel(chData)/original_sampling_rate_in_Hz]);
        xlabel('Time (seconds)');
        ylabel('$\mu V$','Interpreter','LaTex');

        title(sprintf('Unprocessed: %s, %s\n%s', name, rabbit_ID, allData{i}), 'Interpreter', 'None');

        set(findall(fgh,'type','text'),'fontSize',15,'fontWeight','normal', 'color', [0,0,0]);
        set(gca,'FontSize',15);

        saveas(fgh, ['matlab_data/' name int2str(channelToPlot(ii)) '_unprocessed'], 'fig');
        save2pdf(['matlab_data/' name int2str(channelToPlot(ii)) '_unprocessed' '.pdf'], fgh, 1200);      %save the matlab figure to file

        %switch i % rabbit 9
        %    case 2 % basilar tip
        %        xlim([84 89]);
        %    case 10 % mid-basilar
        %        xlim([73 78]);
        %    case 11 % vb junction
        %        xlim([19 24]);
        %    case 12 % cervical vertebral dens
        %        xlim([14 19]);
        %    case 13 % basilar tip
        %        xlim([20 25]);
        %    case 3 % live control
        %        xlim([20 25]);
        %end
        switch i % rabbit 9
            case 4 % basilar tip
                xlim([33 38]);
            case 10 % mid-basilar
                xlim([114 119]);
            case 12 % vb junction
                xlim([170 175]);
            case 15 % basilar tip
                xlim([40 45]);
            case 5 % live control
                xlim([83 88]);
        end
        xl = xlim;
        interval = (9600*xl(1)):(9600*xl(2));
        interval = interval(interval > 0);
        interval = interval(interval <= numel(chData));
        yl = [min(chData(interval)) max(chData(interval))];
        ylim(yl);

        saveas(fgh, ['matlab_data/' name int2str(channelToPlot(ii)) '_qrs'], 'fig');
        save2pdf(['matlab_data/' name int2str(channelToPlot(ii)) '_qrs' '.pdf'], fgh, 1200);      %save the matlab figure to file
    end

    %legend(plotline, data{channelToPlot,1})

    % Rabbit 9, i = 12, no filters
    %xlim([32, 40]);
    %ylim([-1.81 -1.795] * 1e5);





end

