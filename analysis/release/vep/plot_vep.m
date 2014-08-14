function [ fgh ] = plot_vep(data, cleanDigitalIn, name, fs, publication_quality, cardiac_data, on_off, preEventPlot_sec, postEventPlot_sec, filters, cardiac_filters, CM, channelNames, comment)
%PLOT_VEP  Plots the VEP response for a single run.
%
% FGH = PLOT_VEP(DATA, CLEANDIGITALIN, NAME, FS, PUBLICATION_QUALITY, ...
%                CARDIAC_DATA, ON_OFF, PREEVENTPLOT_SEC, POSTEVENTPLOT_SEC, ...
%                FILTERS, CARDIAC_FILTERS, CM, CHANNELNAMES, COMMENT)
%
% Parameters:
%
%   DATA is a matrix of values from the analog channels connected to the
%   electrodes. Each of the rows corresponds to one of the channels. Each of
%   the columns corresponds to a sample from one of the timesteps.
%
%   CLEANDIGITALIN is a binary vector of the digital in channel (whether or not
%   the LED is on at each time step).
%
%   NAME is a string of the filename to save to (should not include suffix).
%
%   FS is the sampling frequency in Hz.
%
%   PUBLICATION_QUALITY is an integer specifying the style of the plots.
%     - 1: shaded confidence intervals
%         WARNING: MATLAB appears to have a bug that causes figures with
%                  shading to be saved improperly as PDF and EPS files.
%                  PLOT2SVG is an alternative method of saving, which
%                  avoids the problem.
%     - 2: no confidence intervals
%     - 3: dashed line for confidence intervals
%     - 4: all trials rather than confidence intervals
%
%   CARDIAC_DATA is a vector of the values from the analog channel connected
%   to the cardiac electrode. This vector should be empty if removal of
%   cardiac artifacts is not desired.
%
%   ON_OFF is a string that determines whether the on response or the off
%   response is plotted ('On' or 'Off').
%
%   PREEVENTPLOT_SEC is the number of seconds before the event to start plot.
%
%   POSTEVENTPLOT_SEC is the number of seconds after the event to stop plot.
%
%   FILTERS is a list of filters to apply to all analog channels other than
%   the cardiac channel.
%
%   CARDIAC_FILTERS is a list of filters to apply to the cardiac channel.
%
%   CM is a matrix of the colors for each of the channels in the plot. Each
%   row corresponds to one of the channels, and the three columns are the RGB
%   values for the color.
%
%   CHANNELSNAMES is a list of strings for the names of the channels. This is not
%   currently used, but is available to use in the legend.
%
%   COMMENT is a string that is the line from the experiment log corresponding
%   to this run. This is not currently used, but is available to use as the
%   title.
%
% Output:
%
%   FGH is the figure handle of the generated figure.
%
% In general, if the data is in the same format as the example data, it is
% easier to use PLOT_ALL_VEP.
%
% See also PLOT_ALL_VEP.


%% Constants

% Figure window size
width = 275;   % width of figure (just plot itself, not labels)
height = 225;  % height of figure (just plot itself, not labels)
margins = 100; % extra space for labels

% Axes for figure
xrange = [-preEventPlot_sec, postEventPlot_sec] * 1000; % x-axis limits for figure
yrange = [-26 26];                                      % y-axis limits for figure
xticks = [-50, 0, 50, 100];                             % tick marks on x-axis
yticks = [-26, -13, 0, 13, 26];                         % tick marks on y-axis

% Figure formatting
font_size = 20; % font size of figure labels
dig_height = 0.7;   % fraction of vertical space for digital in to occupy


%% Look for LED ON and OFF transitions based on digital input channel

% digital input channel convention is low is LED OFF, high is LED ON
LED_ON_edge = 1;   % LED turns on with rising edge of digital in channel (diff = 1)
LED_OFF_edge = -1; % LED turns off with falling edge of digital in channel (diff = -1)

% compute any edges in the digital trace (1 = on edge, 0 = not edge, -1 = off edge)
diff_cleanDigitalIn = diff(cleanDigitalIn);

% find the edges that correspond to LED turning on
event_index_LED_ON = find(diff_cleanDigitalIn == LED_ON_edge);

% find the edges that correspond to LED turning off
event_index_LED_OFF = find(diff_cleanDigitalIn == LED_OFF_edge);

% find both types (on and off) of edges
event_index_LED = find(diff_cleanDigitalIn ~= 0);

% median time between on and off (assumes 50% duty cycle on LED)
event_time_diff = median(diff(event_index_LED));


%% Compute number of samples for plotting

% # of samples to extend plot prior to event time
preEventPlot_samples = floor(preEventPlot_sec * fs);
% # of samples to extend plot following event time
postEventPlot_samples = floor(postEventPlot_sec * fs) - 1;
% total # of samples to plot
totalEventPlot_samples = preEventPlot_samples + postEventPlot_samples + 1;
% prepare the time axis (in milliseconds) for the plots based on samples to plot
time_axis = (-preEventPlot_samples:postEventPlot_samples) / fs * 1000;


%% Create the figure

% make the figure with white background, with fixed size (in pixels) and invisible
fgh = figure('Color',[1 1 1],'units','pixels','position',[0 0 (width + 2 * margins) (height + 2 * margins)], 'visible', 'off');
% make axes with correct margins
axes('units', 'pixel', 'position', [margins margins width height]);
hold on; % Allow all channels to be shown
pause


%% Miscellaneous preparation for figure

% prepare to accumulate plot line handles for the figure legend
plotline_handles = zeros(size(channelNames));

% filter cardiac data, if cardiac data is available
if (~isempty(cardiac_data))
    cardiac_data = run_filters(cardiac_data, cardiac_filters);
end

% select on or off events
event_index_LED_ONOFF = eval(['event_index_LED_' upper(on_off)]);


%% Plot for each channel
for ii = 1:size(data, 1)

    % Print progress
    fprintf('ii: %d / %d\n', ii, size(data, 1));

    chDataRaw = data(ii, :);                  % get unprocessed analog channel from electrode
    chData = run_filters(chDataRaw, filters); % filter electrode data
    if (~isempty(cardiac_data))               % remove cardiac artifacts, if requested
        chData = cardiac_removal(chData, cardiac_data, fs);
    end

    %% Grab all channel data around valid on/off edges
    % valid defined as having proper timing around nearby edge

    % matrix of all single trial responses for the single channel stored in chData, aligned to the on or off edge
    chData_all_single_trial_collection = [];

    %for each LED on/off event, snip out that segment and append it as a row in chData_all_single_trial_responses
    for jj=2:length(event_index_LED_ONOFF)-1,

        %% Verify that this event has valid timing around it
        % find this ON/OFF event in complete event list
        index = find(event_index_LED == event_index_LED_ONOFF(jj));

        % find nearby event times
        event_time = event_index_LED(index + (-1:2));
        % compute relative error to median time between events
        err = (diff(event_time) - event_time_diff) / event_time_diff;
        % check that the surrounding times are approximately correct
        if any(err > 0.001)
            % skip event if timing is off
            continue;
        end

        %% plot digital in channel

        % Select correct interval of digital in, and scale/shift it appropriately
        digitalInDataPlot = cleanDigitalIn((event_index_LED_ONOFF(jj)-preEventPlot_samples):(event_index_LED_ONOFF(jj)+postEventPlot_samples));
        digitalInDataPlot = dig_height * digitalInDataPlot * abs(yrange(2) - yrange(1));
        digitalInDataPlot = digitalInDataPlot + yrange(1) + (1 - dig_height) / 2 * abs(yrange(2) - yrange(1));

        % digital in plotted in black
        plot(time_axis, digitalInDataPlot, 'k', 'linewidth', 2);

        % copy relevant segment into list
        % Note: detrend may not really be needed if the data is high-passed
        chData_all_single_trial_collection(end+1, 1:totalEventPlot_samples)...
            = detrend(chData((event_index_LED_ONOFF(jj)-preEventPlot_samples):...
                            (event_index_LED_ONOFF(jj)+postEventPlot_samples)));

    end


    %% compute and plot the average event-aligned LED ON response for this channel
    if (publication_quality == 4)
        % Version of figure showing all trials
        plotline_handles(end+1) = plot(time_axis, chData_all_single_trial_collection, 'color', CM(ii, :), 'linewidth', 1);
    else
        % Version of figure showing mean (and possibly confidence intervals)

        % plot the trial-averaged response aligned to LED on/off
        chData_trial_averaged = mean(chData_all_single_trial_collection);
        plotline_handles(end+1) = plot(time_axis, chData_trial_averaged,'color',CM(ii,:),'linewidth',2);

        % versions that include a confidence interval
        if (publication_quality == 1) || (publication_quality == 3)
            % compute bootstrapped confidence intervals
            confMean = bootci(100, @mean, chData_all_single_trial_collection);
            if publication_quality == 1
                % shaded confidence intervals
                px = [time_axis, fliplr(time_axis)];
                py = [confMean(1,:), fliplr(confMean(2,:))];
                patch(px, py, 1, 'FaceColor', CM(ii, :), 'EdgeColor', 'none');
                alpha(0.2);
            end
            if publication_quality == 3
                % dashed lines for confidence intervals
                plot(time_axis, confMean(1,:), '--', 'color', CM(ii, :), 'linewidth', 2);
                plot(time_axis, confMean(2,:), '--', 'color', CM(ii, :), 'linewidth', 2);
            end
        end
    end
end

% Print the number of trials used
fprintf('Number of Trials: %d\n', size(chData_all_single_trial_collection, 1));

%% Special cases to change name of image
if (strcmp(on_off, 'Off'))  % off response
    name = [name, '_off'];
end

if (isempty(cardiac_data)) % cardiac artifacts still remain
    name = [name, '_cardiac'];
end


%% Figure formatting

% Use fixed axes and ticks for axes
xlim(xrange);
ylim(yrange);

% Display full box around figures
box on;


%% Figure with labels
% set ticks on axes
set(gca, 'XTick', xticks);
set(gca, 'YTick', yticks);
% label axes
xlabel('Time (ms)');
ylabel('$\mu V$','Interpreter','LaTex');
% set size of tick labels
set(gca,'FontSize',font_size);
%set size of labels
set(findall(fgh,'type','text'),'fontSize',font_size,'fontWeight','normal', 'color', [0 0 0]);
% fake white title to keep size of figures same when using pdfcrop (with ylabel vs. without y label)
title('|', 'color', 'white', 'fontsize', font_size);

% Save labelled version of figure
saveas(fgh, ['figures/' name '_labelled.fig']);
plot2svg(['figures/' name '_labelled.svg'], fgh, 'png');

%% Figure with no labels
% Remove labels on ticks for y axis
set(gca, 'YTickLabel', {});
% Set text color to white
set(findall(fgh,'type','text'),'fontSize',font_size,'fontWeight','normal', 'color', [1 1 1]);
% remove label for y axis
ylabel('');

% Save unlabelled version of figure
saveas(fgh, ['figures/' name '.fig']);
plot2svg(['figures/' name '.svg'], fgh, 'png');

end

