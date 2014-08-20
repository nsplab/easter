%compare sin waves
cycles_to_show = 1;
fs = 19200;
start_time = 0; %start time in seconds
for index=20:20
    figure
    f = data_hold(index).freq;
    hold on
    t = data_hold(index).time;
    %pin = plot(t, data_hold(index).sin_out, 'k');
    master = data_hold(index).gain_int*sin(data_hold(index).time*2*pi*f+data_hold(index).phase_in);
    pin = plot(t, data_hold(index).data_in,'--*b' , 'LineWidth', 4, 'MarkerSize',1);
    pout = plot(t, data_hold(index).data_out,'--*r' , 'LineWidth', 4, 'MarkerSize',1);
    %masterpl = plot(t, master,'--*k' , 'LineWidth', 4, 'MarkerSize',1);
    end_time = cycles_to_show/f+start_time;
    ax = axis;
    axis([start_time, end_time, ax(3), ax(4)])
    xlabel('Time[s]')
    ylabel('uVolt[s]')
    title(['Fitted Data for ' num2str(f) ' Hz'])
    %legend([pin, pout, masterpl], 'Input', 'Output', 'Master')
    legend([pin, pout], 'Input', 'Output')
    set(gca, 'fontsize', 18)
    figureHandle = gcf;
    set(findall(figureHandle,'type','text'),'fontSize',24,'fontWeight','bold', 'color', [0,0,0])
    set(gcf, 'color', [1,1,1])
    set(gcf,'renderer', 'zbuffer');
    set(gcf, 'Position', get(0,'Screensize'));

end