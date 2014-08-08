function [ channelToPlot, CM ] = plot_settings()

%channelToPlot = [2,3,5,7,8]; 
channelToPlot = [3,5,8,2]; 
CM = [hex2dec('ff'), hex2dec('ba'), hex2dec('00'); 
      hex2dec('40'), hex2dec('40'), hex2dec('ff'); 
      hex2dec('b0'), hex2dec('00'), hex2dec('b0'); 
      hex2dec('e9'), hex2dec('00'), hex2dec('3a')];
CM = CM/256; 

end

