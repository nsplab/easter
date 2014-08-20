N = length(test_data);
x=test_data;
xfft = fft(x);
xfft = xfft(1:N/2+1);
N = length(out_data);
y = out_data;
yfft = fft(y);
yfft = yfft(1:N/2+1);
freqs = 0:fs/length(x):fs/2;
voltage = '100mV'
freq = 1
subplot(3,1,1)
plot(freqs, log(xfft), 'k');
title(['Input signal for' voltage ' and ' num2str(freq) 'Hz'])
set(gca, 'fontsize', 18)
ax_t = axis;
axis([ax_t(1), 10, ax_t(3),ax_t(4)])
subplot(3,1,2)
plot(freqs, log(yfft), 'b');
ax_t2 = axis;
axis([ax_t2(1), 10, ax_t2(3),ax_t2(4)])
title(['Output signal for' voltage ' and ' num2str(freq) 'Hz'])
set(gca, 'fontsize', 18)
subplot(3,1,3)
axis([ax_t2(1), 10, ax_t2(3),ax_t2(4)])
subplot(3,1,3)
plot(freqs, yfft./xfft, 'k');
ax_t2 = axis;
axis([ax_t2(1), 10, ax_t2(3),ax_t2(4)])
title(['Ratio of the signal (Vo/Vin)' voltage ' and ' num2str(freq) 'Hz'])
set(gca, 'fontsize', 18)

figureHandle = gcf;
set(findall(figureHandle,'type','text'),'fontSize',24,'fontWeight','bold', 'color', [0,0,0])
set(gcf, 'color', [1,1,1])
set(gcf,'renderer', 'zbuffer');
set(gcf, 'Position', get(0,'Screensize'));

