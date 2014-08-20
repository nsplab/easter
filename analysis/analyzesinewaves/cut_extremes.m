function out_signal = cut_extremes(signal, percentage)
ntp = size(signal,1);
samples_to_cut = round(percentage*ntp);
out_signal = signal(samples_to_cut:end-samples_to_cut);
end