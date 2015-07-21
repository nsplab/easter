function [ data ] = filter_cardiac(start_file, end_file)

if (strfind(start_file, '/subject1/'))
  subject_ID = 'subject1';
elseif (strfind(start_file, '/subject2/'))
  subject_ID = 'subject2';
else
  assert(false);
end

% Information about recording 
[ numChannels, digitalCh, fs, channelNames, GND, earth ] = subject_information(subject_ID);

% Get list of channels to plot and colors for each channel
[ channelToPlot, CM ] = plot_settings();

% Default filters is to only use high-pass filter
filters = get_filters(fs, true, false, false, false, false);

% Default cardiac filters is to only use high-pass filter
cardiac_filters = get_filters(fs, true, false, false, false, false);

% Load analog channels from electrode and digital in
data_all = load_data(start_file, numChannels); % data from all channels
cleanDigitalIn = (data_all(digitalCh, :) > 0);          % binary digital in channel
data = data_all(channelToPlot, :);                      % data for relevant channels

% cardiac channel for removal of cardiac artifacts
cardiac_data = data_all(strcmp(channelNames, 'Bottom Precordial'), :);
cardiac_data = run_filters(cardiac_data, cardiac_filters);

%% For each channel
filtered_data = nan(size(data));
for ii = 1:size(data, 1)
  chDataRaw = data(ii, :);                  % get unprocessed analog channel from electrode
  chData = run_filters(chDataRaw, filters); % filter electrode data
  chData = cardiac_removal(chData, cardiac_data, fs);
  filtered_data(ii, :) = chData;
end

if (strfind(start_file, '/vep/'))
  VEP = 1
  output = struct;
  output.data = filtered_data;
  output.channelNames = channelNames(channelToPlot);
  output.vep = cleanDigitalIn;

  % digital input channel convention is low is LED OFF, high is LED ON
  LED_ON_edge = 1;   % LED turns on with rising edge of digital in channel (diff = 1)
  LED_OFF_edge = -1; % LED turns off with falling edge of digital in channel (diff = -1)
  
  % compute any edges in the digital trace (1 = on edge, 0 = not edge, -1 = off edge)
  diff_cleanDigitalIn = diff(cleanDigitalIn);
  
  % find the edges that correspond to LED turning on
  output.vep_on = find(diff_cleanDigitalIn == LED_ON_edge);
  
  % find the edges that correspond to LED turning off
  output.vep_off = find(diff_cleanDigitalIn == LED_OFF_edge);

  for ii = 1:size(data, 1)
    output.(char(strrep(channelNames(channelToPlot(ii)), ' ', '_'))) = filtered_data(ii, :);
  end

  save([end_file '.mat'], 'output');
else
  VEP = 0

  % Information about how to compute power spectral density
  windlengthSeconds = 2;  % window length in seconds
  noverlapPercent = 0.25; % number overlap percent

  % constants for computing power spectral density (psd)
  windlength = windlengthSeconds * fs;     % window length
  noverlap = windlength * noverlapPercent; % number of overlap timesteps
  
  % Thresholds for being considered close to a harmonic
  threshold_60 = 3;        % Threshold for 60 Hz harmonics
  threshold_harmonics = 3; % Threshold to be considered a harmonic

  if (strfind(start_file, '/ssaep/'))
    ssavep = 'ssaep';
  elseif (strfind(start_file, '/ssvep/'))
    ssavep = 'ssvep';
  else
    assert(false);
  end

  % Load names of data files and experiment log
  [ pathname, experiment_log ] = get_pathname(subject_ID, ssavep);
  [ files, comments ] = get_information(['../' pathname], ['../' experiment_log], ssavep);

  %% Information about plots
  
  t1 = diff(cleanDigitalIn); % -1: experiment turns off, 0: no change, 1: experiment turns on
  t2 = find(t1 == 1);        % times when digital in turns on (experiment starts)
  t3 = find(t1 == -1);       % times when digital in turns off (experiment ends)
  
  if isempty(t3) % digital in never turns off
      % experiment ends when data stops
      t3 = length(cleanDigitalIn);
  end
  
  cutLengthB = t2; % time steps to cut from beginning
  cutLengthE = t3; % time steps to cut from end
  
  assert(numel(cutLengthB) == 1); % bad data with multiple experiment starts
  assert(numel(cutLengthE) == 1); % bad data with multiple experiment ends
  
  assert(cutLengthB < cutLengthE); % bad data with experiment ending before starting

  % get frequency of stimulus based on experiment log
  index = strfind(start_file, '/');
  name = start_file(index(end)+1:end);
  index = strfind(start_file, '_');
  time = strrep(start_file(index(end-2)+1:end), '_', ':');
  comment = '';
  for k = 1:size(comments, 1)
    if (strfind(comments{k}, time))
      comment = comments(k);
      break;
    end
  end
  [ nominal_frequency, frequency ] = get_frequency(comment, name);

  % frequencies / ratio at the harmonics for each channel
  f_harmonic = cell(1, size(data, 1));
  ratio_harmonic = cell(1, size(data, 1));

  output = struct;
  output.channelNames = channelNames(channelToPlot);
  ratio_harmonic_mat = [];

  for ii=1:size(data, 1)
    chData = filtered_data(ii, :);

    % blackmanharris is a windowing function - selected somewhat arbitrarily
    % pwelch - Welch's method
    % Experiment power spectral density
    start = (1*fs+cutLengthB);
    finish = (-1*fs+cutLengthE);
    if (strcmp(name, 'Thu_15_05_2014_14_20_24'))
        % special case (large dc shift at ~5 seconds after cutLengthB)
        start = (6*fs+cutLengthB);
    end
    [lpxx, f, lpxxc] = pwelch(chData(start:finish), blackmanharris(windlength), noverlap, windlength, fs, 'ConfidenceLevel', 0.95);
    %fprintf('Experiment: %d %d\n', start, finish); % print timestamps for experiment
    fprintf('Experiment: %f\n', (finish - start) / fs); % print timestamps for experiment

    % power spectral density during experiment
    expPSDs = lpxx;
    confMeanExp = lpxxc';

    % use the longer of the beginning/ending as the resting state
    % Resting state power spectral density
    if (cutLengthB > length(cleanDigitalIn) - cutLengthE)
        resting = (1*fs):(cutLengthB - 1 * fs);
    else
        resting = (cutLengthE + 1 * fs):(-1*fs+length(cleanDigitalIn));
    end
    %fprintf('Baseline: %d %d\n', resting(1), resting(end)); % print timestep during resting state
    fprintf('Baseline: %f\n', (resting(end) - resting(1)) / fs); % print timestep during resting state
    [lpxx, f, lpxxc] = pwelch(chData(resting), blackmanharris(windlength), noverlap, windlength, fs, 'ConfidenceLevel', 0.95);
    % power spectral density during resting state
    ctrPSDs = lpxx;
    confMeanCtr = lpxxc';


    % ratio of experimental psd to resting psd
    ratio = expPSDs ./ ctrPSDs;

    % get harmonics of stimulus
    num_harmonics = floor(f(end)/frequency);      % highest harmonic that is relevant
    f_harmonic{ii} = zeros(1, num_harmonics);     % list of harmonic frequencies
    ratio_harmonic{ii} = zeros(1, num_harmonics); % list of ratios at harmonics
    near_harmonic = false(size(f));               % boolean of whether or not each frequency is close to any harmonic
    for count = 1:num_harmonics                                     % loop through all harmonics
        h = count * frequency;                                      % frequency of this harmonic
        [~, index] = min(abs(f - h));                               % closest frequency returned by psd
        f_harmonic{ii}(count) = h;                                  % store harmonic
        near_this_harmonic = (abs(f - h) <= threshold_harmonics);   % boolean array for being close to this harmonic
        ratio_harmonic{ii}(count) = max(ratio(near_this_harmonic)); % tip of the ratio at this harmonic
        near_harmonic = (near_harmonic | near_this_harmonic);       % update complete list of near harmonic
    end

    % set 60 Hz harmonics to nan
    valid = ~any(abs(mod(repmat(f, 1, 2), 60) + repmat([0 -60], numel(f), 1)) <= threshold_60, 2);
    ratio(~valid) = nan;

    % set stimulus harmonics to nan
    ratio(near_harmonic) = nan;

    % set 60 Hz harmonics to nan
    valid = ~any(abs(mod(repmat(f_harmonic{ii}, 2, 1), 60) + repmat([0;-60], 1, numel(f_harmonic{ii}))) <= threshold_60, 1);
    ratio_harmonic{ii}(~valid) = nan;

    output.(char(strrep(channelNames(channelToPlot(ii)), ' ', '_'))) = ratio_harmonic{ii}(valid);
    output.frequency = f_harmonic{ii}(valid);
    ratio_harmonic_mat = [ratio_harmonic_mat;
                          ratio_harmonic{ii}(valid)];
  end
  output.data = ratio_harmonic_mat;
  output
  save([end_file '.mat'], 'output');

end

end

