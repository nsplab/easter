function plot_outin_data_gain(datain, dataout, voltage, freq)
fs = 19200;
duration = 10;
samples = duration * fs
ntp = size(datain(1:samples),1)
time = (1:ntp)/fs;
subplot(2,1,1)
%index_plot = 1;
pin =plot(time, datain(1:samples), 'b')
hold on
pout =plot(time, dataout(1:samples), 'r')
title(['Input & Output Signal signal for' voltage ' and ' num2str(freq) 'Hz(Filtered)'])
xlabel('Time [s]')
ylabel('uVolts')
legend([pin, pout], 'Data Input', 'Data Output')
set(gca, 'fontsize', 18)
subplot(2,1,2)
gain = dataout./datain;
size(gain)
plot(time, gain(1:samples))
xlabel('Time[s]')
ylabel('Gain')
set(gca, 'fontsize', 18)
title(['Gain (Vout/Vin)'])
figureHandle = gcf;
set(findall(figureHandle,'type','text'),'fontSize',24,'fontWeight','bold', 'color', [0,0,0])
set(gcf, 'color', [1,1,1])
set(gcf,'renderer', 'zbuffer');
set(gcf, 'Position', get(0,'Screensize'));
end