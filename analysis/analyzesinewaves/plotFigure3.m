%script to plot the resistances, given that the script
%plotmultiplephase_resistance  has been already run. 
figure
color_array = pink(length(data)+3);
color_array = flipud(color_array);
color_array = color_array(3:end,:);
line_width = 4
name_new = {}; %Holds the shown values for the reistor in the legend
for plot_idx = 1:length(data_plot)
    name_new{plot_idx} = data_plot(plot_idx).value(1:end-8)
    name_new{plot_idx} = cell2mat([name_new(plot_idx) '\Omega'])
    color = color_array(plot_idx, :);
    subplot(3,1,1)
    ideal_plt(plot_idx) = semilogx(freq_ar, abs(data_plot(plot_idx).gain_out)/50000,'color', color, 'LineWidth', line_width);
    hold on
    title('Gain Ratio against the ideal (V_{out}/50mV ideal input corresponding to 100 mVpeak-to-peak)')
    ylabel('Gain (unitless)')
    xlabel('Frequency (Hz)')
    set(gca, 'fontsize', 18)
    set(gca, 'box', 'off');
%     
    subplot(3,1,3)
    phase_pl(plot_idx) = semilogx(freq_ar, data_plot(plot_idx).phase,'color', color, 'LineWidth', line_width);
    hold on
    title('Phase difference of the input vs the output signals (Ph_{out}-Ph_{in})')
    ylabel('Phase (degrees)')
    xlabel('Frequency (Hz)')
    set(gca, 'fontsize', 18)
    set(gca, 'box', 'off');
    %rouundiong the gian to correct for decimal point errors
    gain_plot=floor(data_plot(plot_idx).gain*100)/100;
    subplot(3,1,2)
    gain_plt(plot_idx) = semilogx(freq_ar, gain_plot,'color', color, 'LineWidth', line_width);
    hold on
    set(gca, 'fontsize', 18)
    set(gca, 'box', 'off');
    title('Gain Ratio of the Signals (Vo/Vin)')
    ax=axis;
    axis([ax(1) ax(2) 0 1])
    ylabel('Gain (unitless)')
    xlabel('Frequency (Hz)')
%     subplot(3,1,3)
%     plot_idx
%     impedance = (gain_plot./(1-gain_plot))*resistor_values(plot_idx);
%     impedance = impedance/(10^6);
%     impedance_plt(plot_idx) = semilogx(freq_ar, impedance,'color', color, 'LineWidth', line_width);
%     hold on
%     set(gca, 'fontsize', 18)
%     set(gca, 'box', 'off');
%     title('Impedance values (Gain/(1/(1-Gain))*Resistance)')
%     ax=axis;
%     ylabel('Impedance (MOhm)')
%     xlabel('Frequency (Hz)')
    
end
%plot the ideal value for the first plot
subplot(3,1,1)
%ideal_plt(plot_idx+1) = semilogx(freq_ar, abs(data_plot(plot_idx).gain_in)/50000,'LineStyle','--','color', [109 137 213]/255, 'LineWidth', 4);
ideal_plt(plot_idx+1) = semilogx(freq_ar, abs(data_plot(plot_idx).gain_in)/50000,'LineStyle','--','color', [71 109 213]/255, 'LineWidth', line_width);
subplot(3,1,1)
ax = axis;
axis([0.4 ax(2) ax(3) ax(4)]);
subplot(3,1,2)
ax = axis;
axis([0.4 ax(2) ax(3) ax(4)]);
% subplot(3,1,3)
% ax = axis;
% axis([10 1000 ax(3) 100]);
subplot(3,1,3)
ax = axis;
axis([0.4 ax(2) -110 ax(4)]);


figureHandle = gcf;
set(findall(figureHandle,'type','text'),'fontSize',18,'fontWeight','bold', 'color', [0,0,0])
set(gcf, 'color', [1,1,1])
set(gcf,'renderer', 'zbuffer');
%set(gcf, 'Position', get(0,'Screensize'));
lg = legend(ideal_plt, [name_new '0K\Omega'], 'location', 'EastOutside');
set(lg,'FontSize',12);
%lg = legend(phase_pl, name, 'location', 'EastOutside');
%set(lg,'FontSize',12);
%lg = legend(gain_plt, name, 'location', 'EastOutside');
%set(lg,'FontSize',12);
%lg = legend(impedance_plt, name, 'location', 'EastOutside');
%set(lg,'FontSize',12);

plot_title = cell2mat(name); %get a single string
plot_title(plot_title==' ')=[]; %remove spaces
plot_title(plot_title=='.')=[]; %remove points
plot_title = [plot_title '.png'];
outerpos = [0.0    0.0   931   1067+101];
set(gcf,'OuterPosition', outerpos);
myaa([4 2],plot_title)
