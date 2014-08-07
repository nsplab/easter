function [] = artifact(rabbit_ID, ssavep, index1, index2)

addpath('../config')
addpath('../utilities')

maxNumberOfChannels = 10;                                                  %# of consecutive analog input channels, starting with channel 1, to extract from the project easter binary files
                                                                           %(which contain 64 analog channels and the digital in channel (channel 65)

digitalInCh = 65;                                                          %designate the digital input channel, which is used to record
                                                                           %the LED state to align EEG data with onset or offset to generate VEP graphs 

original_sampling_rate_in_Hz = 9600;                                       % data is acquired with the g.Tech g.HiAmp at 9600 Hz. this is fixed for convenience. at higher rates, the 
                                                                           % digital input channel does not work reliably.

pathname = ['../../../../data/easter/' rabbit_ID '/neuro/binary_data/' ssavep '/'];%path for the data in easter binary format
%pathname_comments = ['../../../../data/easter/' rabbit_ID '/neuro/vep.txt'];%file containing comments written on the experiment day to use as labels for the figure titles
pathname_comments = ['../../../../data/easter/' rabbit_ID '/neuro/neuro_experiment_log.txt'];%file containing comments written on the experiment day to use as labels for the figure titles

pathname_matdata = ['../../../../data/easter/' rabbit_ID '/neuro/matlab_data/' ssavep '/'];

[ channelNames, gtechGND, earth ] = rabbit_information(rabbit_ID);

[ S, allData ] = get_information(pathname, pathname_comments, upper(ssavep));

publication_quality = 2;

windlengthSeconds = 2;
noverlapPercent = 0.25;%windlength * 0.25; % number overlap percent
%channelToPlot = [2,3,5,7,8];
channelToPlot = [2,3,5,8];
CM = [hex2dec('e9'), hex2dec('00'), hex2dec('3a');
      hex2dec('ff'), hex2dec('ba'), hex2dec('00');
      hex2dec('40'), hex2dec('40'), hex2dec('ff');
      %hex2dec('58'), hex2dec('e0'), hex2dec('00');
      hex2dec('b0'), hex2dec('00'), hex2dec('b0')];
CM = CM/256;

fs = 9600;
windlength = windlengthSeconds * fs;
%noverlapPercent = 0.25;%windlength * 0.25; % number overlap percent
noverlap = windlength * noverlapPercent; % number overlap (timesteps)

hp = fdesign.highpass('Fst,Fp,Ast,Ap',(2.0),(10.0),90,1,original_sampling_rate_in_Hz);             %highpass filter; passband 90 Hz, stopband 105 Hz, 1dB passband ripple, 90 dB stopband attenuation, sampling frequency fs, butterworth 
hpf = design(hp, 'butter');

filters = {hpf};

fprintf('%s: %s\n', S{index1}, allData{index1});
fprintf('%s: %s\n', S{index2}, allData{index2});

[ data1, cleanDigitalIn1 ] = load_data([pathname S{index1}], maxNumberOfChannels, digitalInCh, channelNames);
[ data2, cleanDigitalIn2 ] = load_data([pathname S{index2}], maxNumberOfChannels, digitalInCh, channelNames);

fgh = figure('Color',[1 1 1],'units','pixels','outerposition',[0 0 1366 768], 'visible', 'off');
%fgh = figure('Color',[1 1 1],'units','pixels','outerposition',[0 0 1366 768]);
hold on

comment1 = allData(index1);
comment2 = allData(index2);

[ nominal_frequency, frequency ] = get_frequency(comment1, S{index1});


[ nominal_frequency1, frequency1 ] = get_frequency(comment1, S{index1});
[ nominal_frequency2, frequency2 ] = get_frequency(comment2, S{index2});

assert(all(nominal_frequency1 == nominal_frequency2));
assert(all(frequency1 == frequency2));

% compute PSD of all channels and plot the PSD + 95% confidence intervals
f_plot = cell(size(channelToPlot));
temp_plot = cell(size(channelToPlot));

cardiacData1 = run_filters(data1{find(strcmp(data1, 'Bottom Precordial')), 2}, filters);
cardiacData2 = run_filters(data2{find(strcmp(data2, 'Bottom Precordial')), 2}, filters);

t1 = diff(cleanDigitalIn1); % -1: experiment turns off, 0: no change, 1: experiment turns on
t2 = find(t1 == 1); % first time when led turns on (experiment starts)
t3 = find(t1 == -1); % last time when led turns off (experiment ends)

if isempty(t2)
    t2 = fs * 30; % TODO: this should not really be needed
end

if isempty(t3)
    t3 = length(cleanDigitalIn1);
end

cutLengthB1 = t2; %fs * cutSecondsBegining;
cutLengthE1 = t3; %fs * cutSecondsEnd;

assert(numel(cutLengthB1) == 1);
assert(numel(cutLengthE1) == 1);

assert(cutLengthB1 < cutLengthE1);


t1 = diff(cleanDigitalIn2); % -1: experiment turns off, 0: no change, 1: experiment turns on
t2 = find(t1 == 1); % first time when led turns on (experiment starts)
t3 = find(t1 == -1); % last time when led turns off (experiment ends)

if isempty(t3)
    t3 = length(cleanDigitalIn2);
end

cutLengthB2 = t2; %fs * cutSecondsBegining;
cutLengthE2 = t3; %fs * cutSecondsEnd;

assert(numel(cutLengthB2) == 1);
assert(numel(cutLengthE2) == 1);

assert(cutLengthB2 < cutLengthE2);

cutLengthB1
cutLengthE1
length(cleanDigitalIn1)
cutLengthB2
cutLengthE2
length(cleanDigitalIn2)

channels_plotted = [];

for ii=1:numel(channelToPlot)
    fprintf('ii: %d / %d\n', ii, numel(channelToPlot));

    channels_plotted = [channels_plotted channelToPlot(ii)];

    chData1 = run_filters(data1{channelToPlot(ii),2}, filters);
    chData1 = qrs_removal(chData1, cardiacData1);

    %[lpxx, f, lpxxc] = pwelch(chData1(1+cutLengthB1:cutLengthE1), blackmanharris(windlength), noverlap, windlength, fs, 'ConfidenceLevel', 0.95);
    assert(30 * fs < cutLengthB1);
    [lpxx, f, lpxxc] = pwelch(chData1(1:30*fs), blackmanharris(windlength), noverlap, windlength, fs, 'ConfidenceLevel', 0.95);
    %[lpxx, f, lpxxc] = pwelch(chData1((cutLengthB1+1):cutLengthE1), blackmanharris(windlength), noverlap, windlength, fs, 'ConfidenceLevel', 0.95);

    PSDs1 = lpxx;
    confMean1 = lpxxc';

    chData2 = run_filters(data2{channelToPlot(ii),2}, filters);
    chData2 = qrs_removal(chData2, cardiacData2);

    %[lpxx, f, lpxxc] = pwelch(chData2(1+cutLengthB2:cutLengthE2), blackmanharris(windlength), noverlap, windlength, fs, 'ConfidenceLevel', 0.95);
    assert(30 * fs < cutLengthB2);
    [lpxx, f, lpxxc] = pwelch(chData2(1:30*fs), blackmanharris(windlength), noverlap, windlength, fs, 'ConfidenceLevel', 0.95);
    %[lpxx, f, lpxxc] = pwelch(chData2((cutLengthB2+1):cutLengthE2), blackmanharris(windlength), noverlap, windlength, fs, 'ConfidenceLevel', 0.95);

    PSDs2 = lpxx;
    confMean2 = lpxxc';

    %temp = (PSDs1 - PSDs2)' ./ (confMean1(2, :) - confMean1(1, :));
    %temp = (PSDs1 - PSDs2)';
    %temp = (log10(PSDs1) - log10(PSDs2))';
    temp = log10(PSDs1);
    %temp = log10(PSDs2);
    %temp = PSDs1 - PSDs2;

    num_harmonics = floor(f(end)/frequency1);
    f_plot{ii} = zeros(1, num_harmonics);
    temp_plot{ii} = zeros(1, num_harmonics);
    for count = 1:num_harmonics
        h = count * frequency1;
        [~, index] = min(abs(f - h));
        f_plot{ii}(count) = h;
        index = index + (-2:2);
        index = index(index > 0 & index <= numel(temp));
        temp_plot{ii}(count) = max(temp(index));
    end

    threshold = 1;
    for j = 1:numel(f)
        if any(abs(mod(f(j), 60) + [0 -60]) <= threshold)
            temp(j) = nan;
        end
    end

    if strcmp(data1{channelToPlot(ii), 1}, 'Endo')
        %plot(f, temp,'color',CM(ii,:),'linewidth',5);
        plot(f, temp,'color',CM(ii,:) + 0.6 * (1 - CM(ii,:)),'linewidth',2);
    else
        %plot(f, temp,'color',CM(ii,:),'linewidth',3);
        plot(f, temp,'color', 0.65 * [1 1 1],'linewidth',2);
    end


end

for ii=1:length(channelToPlot)
    threshold = 5;
    for count = 1:num_harmonics
        h = count * frequency;
        if any(abs(mod(h, 60) + [0 -60]) <= threshold)
            temp_plot{ii}(count) = nan;
        end
    end

        valid = ~isnan(temp_plot{ii});
        plot(f_plot{ii}(valid), temp_plot{ii}(valid),'color',CM(ii,:),'linewidth',7);
    %if strcmp(data{channelToPlot(ii), 1}, 'Endo')
    %    %plot(f, temp,'color',CM(ii,:),'linewidth',5);
    %    plot(f_plot{ii}, temp_plot{ii},'color',CM(ii,:),'linewidth',3);
    %else
    %    %plot(f, temp,'color',CM(ii,:),'linewidth',3);
    %    plot(f_plot{ii}, temp_plot{ii},'color',[0.5 0.5 0.5],'linewidth',3);
    %end
end

for ii=1:length(channelToPlot)
    %scatter(f_plot{ii}, temp_plot{ii},100,[0 0 0], 'fill');
    %scatter(f_plot{ii}, temp_plot{ii},36,CM(ii,:), 'fill');
    %scatter(f_plot{ii}, temp_plot{ii},144,[0 0 0], 'fill');
    %scatter(f_plot{ii}, temp_plot{ii},81,CM(ii,:), 'fill');
    scatter(f_plot{ii}, temp_plot{ii},26^2,[0 0 0], 'fill');
    scatter(f_plot{ii}, temp_plot{ii},22^2,CM(ii,:), 'fill');
end

threshold = 5;
baseColor = [0 0 0] + 0.6;
mergedColor = [0.4 0 0] + 0.6;
color60 = [1 0 0];
%for sp = 1:3
    %subplot(3,1,sp);hold on;
    %ylim([0 6]);
    %ylim([-2 7]);
    %ylim([-10 5]); % TODO
    %ylim([-0.5 3]);
    %ylim([-1 4]);
    %ylim([-0.01 0.03]);
    %ylim([-2 4]);
    %ylim([-1 2]);
    ylim([-4 1]);
    yl = ylim;
    for h=1:floor(f(end)/frequency1)
        color = baseColor;
        if any(abs(mod((h*frequency1), 60) + [0 -60]) < threshold)
            color = mergedColor;
            continue
        end
        %plot([(h*frequency1) (h*frequency1)], ylim,'Color',color,'linewidth',1)
    end

    for h=1:floor(f(end)/60)
        %plot([(h*60) (h*60)], ylim,'Color',color60,'linewidth',1)
        %scatter(h*60, yl(2), 'fill', 'red');
    end
    ylim(yl);
%end

%xlabel('Frequency (Hz)');
%ylabel('${log}_{10} (p_{exp} / p_{base})$', 'Interpreter', 'LaTeX');
%ylabel('log_{10} (p_{exp} / p_{base})'); % TODO
%ylabel('log_{10} p_{base}');
%ylabel('Difference');
%ylabel('Difference of Logs');
set(gca, 'TickDir', 'out')
%set(gca, 'XTick', roundn([0 harmonics], -1));
if nominal_frequency1 == 40
    set(gca, 'XTick', roundn([0:2 3:2:num_harmonics] * frequency1, 0));
    set(gca, 'XTick', roundn((1:15:num_harmonics) * frequency1, 0));
else
    set(gca, 'XTick', roundn((0:num_harmonics) * frequency1, 0));
    set(gca, 'XTick', roundn((1:7:num_harmonics) * frequency1, 0));
end
set(gca, 'XTick', []);
set(gca, 'YTick', []);


%tmp = title(sprintf('%s: %.1f to %.f seconds', upper(ssavep), cutLengthB1 / fs, cutLengthE1 / fs), 'Interpreter', 'None');


set(findall(fgh,'type','text'),'fontSize',40,'fontWeight','normal', 'color', [0,0,0]);
set(gca,'FontSize',40);
box on;

savename = sprintf('%s_%s_%d_%d', rabbit_ID, ssavep, index1, index2);
savename = sprintf('%s_%s_%d_%d_not_subtracted', rabbit_ID, ssavep, index1, index2);

saveas(fgh, ['matlab_data/' savename '.fig']);      %save the matlab figure to file

xlim([0 f(end)]);
saveas(fgh, ['matlab_data/' savename '.epsc']);     %save the matlab figure to file
save2pdf(['matlab_data/' savename '.pdf'], fgh, 150);      %save the matlab figure to file



close all

end

