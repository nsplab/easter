function [ vep_data, digital_data, pre, post ] = load_vep(filename, on_off)

if strfind(filename, 'subject1')
    subject_ID = 'subject1';
elseif strfind(filename, 'subject2')
    subject_ID = 'subject2';
end

%% Preliminary information about plotting

% Information about recording 
[ numChannels, digitalCh, fs, channelNames, GND, earth ] = subject_information(subject_ID);

% Load names of data files and experiment log
[ pathname, experiment_log ] = get_pathname(subject_ID, 'vep');
[ files, comments ] = get_information(['../' pathname], ['../' experiment_log], 'vep');

% Get list of channels to plot and colors for each channel
[ channelToPlot, CM ] = plot_settings();


% Default filt_cardiac is to remove cardiac artifacts
if (nargin < 4) || isempty(filt_cardiac)
    filt_cardiac = true;
end

% Default preEventPlot_sec is to start plot 0.05 seconds (50 ms) before event
if (nargin < 5) || isempty(preEventPlot_sec)
    %preEventPlot_sec = 0.05;
    %preEventPlot_sec = -0.05;
    preEventPlot_sec = -0.005;
    %preEventPlot_sec = 0.05;
end

% Default postEventPlot_sec is to end plot 0.1 seconds (100 ms) after event
if (nargin < 6) || isempty(postEventPlot_sec)
    %postEventPlot_sec = 0.5;
    %postEventPlot_sec = 0.1;
    %postEventPlot_sec = 0.08;
    postEventPlot_sec = 0.1;
end

pre = 1000 * preEventPlot_sec;
post = 1000 * postEventPlot_sec;

% Default filters is to only use high-pass filter
% Note: allow filters to be empty (do not enforce default)
if (nargin < 7)
    filters = get_filters(fs, true, false, false, false, false);
end

% Default cardiac filters is to only use high-pass filter
% Note: allow cardiac_filters to be empty (do not enforce default)
if (nargin < 8)
    cardiac_filters = get_filters(fs, true, false, false, false, false);
end


% Load analog channels from electrode and digital in (LED on / off)
data_all = load_data(filename, numChannels); % data from all channels
cleanDigitalIn = (data_all(digitalCh, :) > 0);          % binary digital in channel
data = data_all(channelToPlot, :);                      % data for relevant channels
cardiac_data = []; % empty array if no cardiac artifact filtering
if (filt_cardiac)
    % cardiac channel for removal of cardiac artifacts
    cardiac_data = data_all(strcmp(channelNames, 'Bottom Precordial'), :);
end

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

%% Miscellaneous preparation for figure

% filter cardiac data, if cardiac data is available
if (~isempty(cardiac_data))
    cardiac_data = run_filters(cardiac_data, cardiac_filters);
end

% select on or off events
event_index_LED_ONOFF = eval(['event_index_LED_' upper(on_off)]);

%% process each channel
vep_data = cell(size(data, 1), 1);
digital_data = cell(size(data, 1), 1);
for ii = 1:size(data, 1)

    chDataRaw = data(ii, :);                  % get unprocessed analog channel from electrode
    chData = run_filters(chDataRaw, filters); % filter electrode data
    if (~isempty(cardiac_data))               % remove cardiac artifacts, if requested
        chData = cardiac_removal(chData, cardiac_data, fs);
    end

    %% Grab all channel data around valid on/off edges
    % valid defined as having proper timing around nearby edge

    % matrix of all single trial responses for the single channel stored in chData, aligned to the on or off edge
    chData_all_single_trial_collection = [];
    digital = [];

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
        % copy relevant segment into list
        % Note: detrend may not really be needed if the data is high-passed
        chData_all_single_trial_collection(end+1, 1:totalEventPlot_samples)...
            = detrend(chData((event_index_LED_ONOFF(jj)-preEventPlot_samples):...
                            (event_index_LED_ONOFF(jj)+postEventPlot_samples)));
        digital = cleanDigitalIn((event_index_LED_ONOFF(jj)-preEventPlot_samples):...
                                 (event_index_LED_ONOFF(jj)+postEventPlot_samples));
    end
    vep_data{ii} = chData_all_single_trial_collection;
    digital_data{ii} = digital;
end

end

