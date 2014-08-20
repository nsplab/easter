function plot_raw_data(data_cell, voltage)
fs = 19200;
duration = 2;
samples = duration * fs;
subplot(2,1,1)
index_plot = 7;
%index_plot = 1;
plot(data_cell(index_plot).data(10:samples))
title(['Input signal for' voltage ' and ' num2str(data_cell(7).freq) 'Hz'])
xlabel('Frequency [Hz]')
ylabel('uVolts')
set(gca, 'fontsize', 18)
subplot(2,1,2)
plot(data_cell(index_plot).dataout(10:samples))
title(['Output signal for' voltage ' and ' num2str(data_cell(7).freq) 'Hz'])
xlabel('Frequency [Hz]')
ylabel('uVolts')
set(gca, 'fontsize', 18)
figureHandle = gcf;
set(findall(figureHandle,'type','text'),'fontSize',24,'fontWeight','bold', 'color', [0,0,0])
set(gcf, 'color', [1,1,1])
set(gcf,'renderer', 'zbuffer');
set(gcf, 'Position', get(0,'Screensize'));
end