function plot_outin_data_compare(datain, dataout, voltage, freq)
fs = 19200;
duration = 10;
samples = duration * fs;
ntp = size(datain(1:samples),1)
time = (1:ntp)/fs;
subplot(2,1,1)
%index_plot = 1;
pin =plot(time, datain(1:samples), 'b')
hold on
pout =plot(time, dataout(1:samples), 'r')
title(['Input & Output Signal signal for' voltage ' and ' num2str(freq) 'Hz'])
xlabel('Frequency [Hz]')
ylabel('uVolts')
legend([pin, pout], 'Data Input', 'Data Output')
set(gca, 'fontsize', 18)
subplot(2,1,2)
p2 = plot_fft(datain, fs, 'b');
hold on
p3 = plot_fft(dataout, fs, 'r');
ax_t = axis;
axis([ax_t(1), 100, ax_t(3),ax_t(4)])
legend([p2, p3], 'Data Input', 'Data Output')
title(['Filtered signal for' voltage ' and ' num2str(freq) 'Hz'])
set(gca, 'fontsize', 18)
figureHandle = gcf;
set(findall(figureHandle,'type','text'),'fontSize',24,'fontWeight','bold', 'color', [0,0,0])
set(gcf, 'color', [1,1,1])
set(gcf,'renderer', 'zbuffer');
set(gcf, 'Position', get(0,'Screensize'));
end