function [ a, b, c, d, e, f ] = compute_snr(filename, subject_ID)

% Information about recording 
[ numChannels, digitalCh, fs, channelNames, GND, earth ] = subject_information(subject_ID);

% Get list of channels to plot and colors for each channel
[ channelToPlot, CM ] = plot_settings();


ratio_harmonic = load(filename);
ratio_harmonic = ratio_harmonic.ratio_harmonic;

channelNames = channelNames(channelToPlot);
endo = strcmp(channelNames, 'Endo');
scalp = ratio_harmonic(~endo);
endo = ratio_harmonic(endo);

scalp = [scalp{:}];
endo = [endo{:}];

scalp = scalp(~isnan(scalp));
endo = endo(~isnan(endo));

a = max(endo);
b = median(endo);
c = min(endo);

d = max(scalp);
e = median(scalp);
f = min(scalp);

end

