cycles_to_show = 10;
start_time = 1;
time_in_secs = 10;
frequency = 1000;
fs = 19200;
end_time = cycles_to_show/frequency+start_time;
end_samples = end_time*fs;
samples = time_in_secs*fs;
phase = pi/2.16;
t=(1:samples)/fs;
%test_data = 1*sin(2*pi*frequency*t+phase);
test_data = data_hold(13).filter_in(1:end_samples)';
t = data_hold(13).time(1:end_samples);
[sin_in1, phase_in1, gain_in1, score1] = fitdata(test_data', frequency, [0,0,0], fs);
[sin_in2, phase_in2, gain_in2, score2, phase_arr] = fitdataevolved(test_data', frequency, [max(test_data),0,0], fs);
pin = plot(t, test_data,'-sk','LineWidth', 1, 'MarkerSize',1);
hold on
pout = plot(t, sin_in1,'-*b' , 'LineWidth', 1, 'MarkerSize',1);
pfilt = plot(t, sin_in2,'-+r', 'LineWidth', 1, 'MarkerSize',1);
ax = axis;
axis([start_time, end_time, ax(3), ax(4)])
xlabel('Time[s]')
ylabel('uVolt[s]')
title(['Fitted Data for ' num2str(frequency) ' Hz'])
legend([pin, pout, pfilt], 'Original', 'Fitted Normal', 'Fitted Grid')
set(gca, 'fontsize', 18)
figureHandle = gcf;
set(findall(figureHandle,'type','text'),'fontSize',24,'fontWeight','bold', 'color', [0,0,0])
set(gcf, 'color', [1,1,1])
set(gcf,'renderer', 'zbuffer');
set(gcf, 'Position', get(0,'Screensize'));

figure
plot(rad2deg(phase_arr), score2)
xlabel('Phase[deg]')
ylabel('Score')
title(['Score for the grid Fitting ' num2str(frequency) ' Hz'])
set(gca, 'fontsize', 18)
figureHandle = gcf;
set(findall(figureHandle,'type','text'),'fontSize',24,'fontWeight','bold', 'color', [0,0,0])
set(gcf, 'color', [1,1,1])
set(gcf,'renderer', 'zbuffer');
set(gcf, 'Position', get(0,'Screensize'));
