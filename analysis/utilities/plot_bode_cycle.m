function plot_bode_cycle(data_list, name_list, extra_description)
%PLOT_BODE_CYCLE plots a set of different dta functions in the same set of
%plots for easy visualization.
%--------------------------------------------------------------------------
%input:
%-------------------------------------------------------------------------
%data_list =  cell array containing the set of dta files to visualize
%name_list = desired names for each of the plots to visualize, this has to
%be a cell array
%extra_description: This description will be added at the end of the top
%title.
plot_lg_1 = [];
plot_lg_2 = [];
%color_array = copper(length(data_list)); %Creates a set of colors of the same size as the number of files
color_array = [255,13, 0; 255,184, 0; 23, 41, 176; 0, 198, 24; 0,0,0; 200, 200, 200; 166, 120, 0]/255;%Uses a predefined set of colors
%color_array = [255,13, 0; 255,13, 0; 23, 41, 176; 23, 41, 176; 166, 120, 0; 166, 120, 0]/255;%Uses a predefined set of colors
% color_array(2,:) = color_array(1,:)*0.8
% color_array(3,:) = color_array(1,:)*0.6
% color_array(5,:) = color_array(4,:)*0.8
% color_array(6,:) = color_array(4,:)*0.6
style_array = {'-','-','-','-','-','-', '-'}; %Set the plot style for the different plots
for data_idx = 1:length(data_list)
    data_list{data_idx}
    [plot_lg_1(data_idx), plot_lg_2(data_idx)] = plot_bode_dta(data_list{data_idx}, color_array(data_idx,:), style_array{1}, extra_description);%create the actual plot
end
%Set the limits for the axes
subplot(2,1,2)
ax = axis;
axis([0.4 ax(2) ax(3) ax(4)]);
subplot(2,1,1)
ax = axis;
axis([0.4 ax(2) ax(3) ax(4)]);
lg = legend(plot_lg_1, name_list, 'location', 'EastOutside')
set(lg,'FontSize',12);
lg = legend(plot_lg_2, name_list, 'location', 'EastOutside')
set(lg,'FontSize',12);
plot_title = cell2mat(name_list); %get a single string
plot_title(plot_title==' ')=[]; %remove spaces
plot_title(plot_title=='.')=[]; %remove points
%plot_title = [plot_title '.svg'];
%myaa([4 2],plot_title)
%plot2svg(plot_title)
