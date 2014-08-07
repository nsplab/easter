function [ f ] = make_legend()
  f = figure;
  hold on;

  CM = [hex2dec('e9'), hex2dec('00'), hex2dec('3a');
        hex2dec('ff'), hex2dec('ba'), hex2dec('00');
        hex2dec('40'), hex2dec('40'), hex2dec('ff');
        hex2dec('58'), hex2dec('e0'), hex2dec('00');
        hex2dec('b0'), hex2dec('00'), hex2dec('b0');
        hex2dec('00'), hex2dec('00'), hex2dec('00')];
  CM = CM/256;

  channelToPlot = [2,3,5,7,8];
  channelToPlot = [2,3,5,7,8,9];
  channelNames_VEP = {'Disconnected','Endo','Mid head','Disconnected','Right Eye','Right Leg','Back Head','Left Eye','Bottom Precordial','Top Precordial'};


  legends = [];
  for i = 1:numel(channelToPlot)
    legends = [legends plot(0, 0, 'Color', CM(i, :), 'linewidth', 3)];
  end
legends
  legend(legends, channelNames_VEP{channelToPlot})
  %legend(channelNames_VEP{channelToPlot})

  axis off;
  set(legends, 'visible', 'off');
  set(gca, 'visible', 'off');

  %save2pdf('legend.pdf', f, 1200);
  save2pdf('legend2.pdf', f, 1200);


end

