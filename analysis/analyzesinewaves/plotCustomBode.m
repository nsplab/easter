function plotCustomBode(frequencies, HWresponse, color)
%PLOTCUSTOMBODE plots a primitive Bode diagram based on the frequencies
%captured without any interpolation.
ac_volt = 100;
phase_arr = rad2deg(angle(HWresponse));
magnitud = abs(HWresponse);
subplot(2,1,1)
semilogx(frequencies, phase_arr, '-' ,'color', color, 'LineWidth', 4);
xlabel('Frequency(Hz)')
ylabel('Phase (Degrees)')
set(gca, 'fontsize', 18)
set(gca, 'box', 'off');
hold on
title('gTech Impedance Phase Plot', 'color','k','FontSize',24)
subplot(2,1,2)
semilogx(frequencies, magnitud, '-' ,'color', color, 'LineWidth', 4);
set(gca, 'box', 'off');
hold on
xlabel('Frequency(Hz)')
ylabel('Magnitude')
set(gca, 'fontsize', 18)
title('gTech Impedance Module Plot', 'color','k','FontSize',24)
main_title = ['Bode diagram with ' num2str(ac_volt) ' mVolts P2P'];
main_title = [main_title];
axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.5, 1,main_title, 'HorizontalAlignment','center','VerticalAlignment', 'top')
figureHandle = gcf;
set(findall(figureHandle,'type','text'),'fontSize',24,'fontWeight','bold', 'color', [0,0,0])
set(gcf, 'color', [1,1,1])
set(gcf,'renderer', 'zbuffer');
set(gcf, 'Position', get(0,'Screensize'));
