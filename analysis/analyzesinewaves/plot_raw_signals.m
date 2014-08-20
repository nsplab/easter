ntp = length(chan_1_unshield); %get time
t = (1:ntp)/fs;
figure
subplot(2,1,1)
plot(t, chan_1_unshield)
title('Sensing Platinum')
xlabel('Time(sec)')
ylabel('uVolts')
subplot(2,1,2)
plot(t, chan_2_unshield)
title('Side Arm')
xlabel('Time(sec)')
ylabel('uVolts')
figureHandle = gcf;
set(findall(figureHandle,'type','text'),'fontSize',24,'fontWeight','bold', 'color', [0,0,0])
set(gcf, 'color', [1,1,1])
set(gcf,'renderer', 'zbuffer');
set(gcf, 'Position', get(0,'Screensize'));
myaa([4 2],'rawsignalunshielded.png')

figure
p1 = plot_psd(chan_1_unshield, 19200, 'b');
hold on
p2 = plot_psd(chan_2_unshield, 19200, 'k');
legend([p1,p2], 'Sensing','Sidearm')
ax = axis
axis([0,100,ax(3), ax(4)])
figureHandle = gcf;
set(findall(figureHandle,'type','text'),'fontSize',24,'fontWeight','bold', 'color', [0,0,0])
set(gcf, 'color', [1,1,1])
set(gcf,'renderer', 'zbuffer');
set(gcf, 'Position', get(0,'Screensize'));
myaa([4 2],'psdsignalunshielded.png')