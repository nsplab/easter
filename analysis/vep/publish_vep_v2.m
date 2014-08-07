% publish_vep
%
% This script runs the VEP analysis on a single file represented by 'pathname' and 'filename'
%
% Requires:
%	pathname - path for the data in easter binary format
%	filename - file name for the data in easter binary format
%	data	 - cell array contains channel labels and channel values; does not include the digitalinCh channel
%		   example: data{4,1} is the label for channel 4.
%			    data{4,2} is the vector of voltage values (microvolts) for channel 4
%////////////////////////////////// % if you want to ask the user to select a single binary data file, uncomment this block %run('../utilities/loaddata.m');		%populates the variable names pathname, filename, and data
%//////////////////////////////////

function [] = publish_vep_v2(data, cleanDigitalIn, fs, publication_quality, filters, cardiac_filters, preEventPlot_sec, postEventPlot_sec, comment, name, channelToPlot, CM, OnOff, filter_qrs)

%///// hardcoded values that you should keep unchanged
                                                                           %digital input channel convention is low is LED OFF, high is LED ON; verified for VEP aruino recording code with 5rabbit, 6rabbit, 7rabbit, etc.
LED_ON_edge = 1;                                                           %LED turns on with rising edge of digital in channel (diff = 1)
LED_OFF_edge = -1;                                                         %LED turns off with falling edge of digital in channel (diff = -1)

%////////////////////////////////////////////////////////////////////
%///// hardcoded analysis options: VEP onset and offset
%////////////////////////////////////////////////////////////////////

%//////////////////////////////////
% Look for LED ON and OFF transitions based on digital input channel (65)
%//////////////////////////////////

diff_cleanDigitalIn = diff(cleanDigitalIn);                                  %compute any edges in the digital trace
event_index_LED_ON = find(diff_cleanDigitalIn == LED_ON_edge);               %find the edges that correspond to LED turning on
event_index_LED_OFF = find(diff_cleanDigitalIn == LED_OFF_edge);             %find the edges that correspond to LED turning off
event_index_LED = find(diff_cleanDigitalIn ~= 0);
event_time_diff = median(diff(event_index_LED));

preEventPlot_samples = floor(preEventPlot_sec * fs);                         %time in # samples to extend plot prior to event time; preEventPlot_sec - see hardcoded parameters above
postEventPlot_samples = floor(postEventPlot_sec * fs) - 1;                   %time in # samples to extend plot following event time; postEventPlot_sec - see hardcoded parameters above
totalEventPlot_samples = preEventPlot_samples + postEventPlot_samples + 1;   % total # of samples to plot
time_axis = (-preEventPlot_samples:postEventPlot_samples) / fs * 1000;       %prepare the time axis for the plots based on samples to plot


% draw the figure with white background and fixed size (in pixels)
width = 275;   % width of figure (just plot itself, not labels)
height = 225;  % height of figure (just plot itself, not labels)
margins = 100; % extra space for labels

% Open invisible screen for figure
fgh = figure('Color',[1 1 1],'units','pixels','position',[0 0 (width + 2 * margins) (height + 2 * margins)], 'visible', 'off');
axes('units', 'pixel', 'position', [margins margins width height]);
hold on

plotline_handles = [];                                                  %prepare to accumulate LED ON plot line handles for the figure legend

cardiacDataRaw = data{strcmp(data, 'Bottom Precordial'), 2};
cardiacData = run_filters(cardiacDataRaw, cardiac_filters);

event_index_LED_ONOFF = eval(['event_index_LED_' upper(OnOff)]);

ylim([-26 26]);
yrange = ylim;

digitalInOffset = yrange(1) - ((abs(yrange(1)) + abs(yrange(2))) / 40);

digitalIn_all_single_trial_collection = [];

for ii=1:length(channelToPlot)                                                      %for each channel

    fprintf(['ii: ' int2str(ii) '\n']);

    chDataRaw = data{channelToPlot(ii),2};                                                   %load the timeseries recording for that channel
    chData = run_filters(chDataRaw, filters);
    if (filter_qrs)
        chData = qrs_removal(chData, cardiacData);
    end

    %//////////////////////////////////////////////////////////////////////
    %/// compute and plot the average event-aligned LED ON response for
    %this channel
    %//////////////////////////////////////////////////////////////////////

    chData_all_single_trial_collection = [];                            %matrix of all single trial responses for the single channel stored in chData, aligned to ON (rising edges of digital input signal)
    for jj=2:length(event_index_LED_ONOFF)-1,                                 %for each LED ON event, snip out that segment and append it as a row in chData_all_single_trial_responses

        index = find(event_index_LED == event_index_LED_ONOFF(jj)); % find this ON/OFF event in complete event list
        prev = event_index_LED(index - 1);
        curr = event_index_LED(index);
        next = event_index_LED(index + 1);
        nex2 = event_index_LED(index + 2);
        e1 = abs((curr - prev - event_time_diff) / event_time_diff);
        e2 = abs((next - curr - event_time_diff) / event_time_diff);
        e3 = abs((nex2 - next - event_time_diff) / event_time_diff);
        if (e1 > 0.001 || e2 > 0.001 || e3 > 0.001) % check that the surrounding times are approximately correct
            continue;
        end

        % plot digital in channel
        height = 0.7;

        digitalInDataPlot = cleanDigitalIn((event_index_LED_ONOFF(jj)-preEventPlot_samples):(event_index_LED_ONOFF(jj)+postEventPlot_samples));
        digitalInDataPlot = height * digitalInDataPlot * abs(yrange(2) - yrange(1));
        digitalInDataPlot = digitalInDataPlot + yrange(1) + (1 - height) / 2 * abs(yrange(2) - yrange(1));

        plot(time_axis, digitalInDataPlot, 'k', 'linewidth', 2);

        % copy segment
        % TODO: is detrend needed (after high-pass)
        chData_all_single_trial_collection(end+1, 1:totalEventPlot_samples)...
            = detrend(chData((event_index_LED_ONOFF(jj)-preEventPlot_samples):...
                            (event_index_LED_ONOFF(jj)+postEventPlot_samples)));

    end

    chData_trial_averaged = mean(chData_all_single_trial_collection);%record the trial-averaged response aligned to LED ON (rising edges of digital input signal)

    if publication_quality == 1 || publication_quality == 3
        confMean = bootci(100, @mean, chData_all_single_trial_collection);
        if publication_quality == 1
            px = [time_axis, fliplr(time_axis)];
            py = [confMean(1,:), fliplr(confMean(2,:))];
            patch(px,py,1,'FaceColor',CM(ii,:),'EdgeColor','none');
            alpha(0.2);
        end
        if publication_quality == 3
            plot(time_axis, confMean(1,:),'--','color',CM(ii,:),'linewidth',2);
            plot(time_axis, confMean(2,:),'--','color',CM(ii,:),'linewidth',2);
        end
    end

    if (publication_quality == 4)
        plotline_handles(end+1) = plot(time_axis, chData_all_single_trial_collection,'color',CM(ii,:),'linewidth',1);
    else
        plotline_handles(end+1) = plot(time_axis, chData_trial_averaged,'color',CM(ii,:),'linewidth',2);
    end
end
fprintf('Number of Trials: %d\n', size(chData_all_single_trial_collection, 1));



%tmp = title([ 'VEP ON Response: ' filename ' | GND: nose |  # samples =' int2str(length(t2)) ]);
%if ~isempty(allData)
%    %tmp = title({['VEP ON Response: ' int2str(size(chData_all_single_trial_collection_ON, 1)) ' trials'];allData{i}});
%else
%    %tmp = title(['VEP ON Response: ' int2str(size(chData_all_single_trial_collection_ON, 1)) ' trials']);
%end
%title(sprintf('VEP On Response: %d trials', size(chData_all_single_trial_collection_ON, 1)));
%set(tmp,'interpreter','none');
%xlabel('Time (ms) relative to LED On at time zero');
%ylabel('$\mu V$','Interpreter','LaTex');
set(gca, 'XTick', []);
set(gca, 'YTick', []);
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

%set(findall(fgh,'type','text'),'fontSize',40,'fontWeight','normal', 'color', [0,0,0]);
xlim([-preEventPlot_sec, postEventPlot_sec] * 1000);
box on;

if (strcmp(OnOff, 'Off'))
    name = [name, '_off'];
end

if (~filter_qrs)
    name = [name, '_cardiac'];
end

font_size = 20;
xlabel('Time (ms)');

%xticks = round(linspace([-preEventPlot_sec, 0, postEventPlot_sec] * 1000);
xticks = [-50, 0, 50, 100];

yticks = [-26, -13, 0, 13, 26];

%% Figure with labels
set(gca, 'XTick', xticks);
set(gca, 'YTick', yticks);
ylabel('$\mu V$','Interpreter','LaTex');
set(findall(fgh,'type','text'),'fontSize',font_size,'fontWeight','normal', 'color', [0 0 0]);
set(gca,'FontSize',font_size);
title('|', 'color', 'white', 'fontsize', font_size);

saveas(fgh, ['matlab_data/' name '.fig']);      %save the matlab figure to file
plot2svg(['matlab_data/' name '_labelled.svg'], fgh, 'png')

%% Figure with no labels
set(gca, 'XTick', xticks);
set(gca, 'YTick', yticks);
set(gca, 'YTickLabel', {});
set(findall(fgh,'type','text'),'fontSize',font_size,'fontWeight','normal', 'color', [1 1 1]);
ylabel('');

plot2svg(['matlab_data/' name '.svg'], fgh, 'png')

end

