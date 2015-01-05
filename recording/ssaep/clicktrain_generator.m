T = 0:1/48000:(30); % 48000 audio sampling  rate
D = [round(48000/12)/48000:round(48000/12)/48000:30]; % 30 seconds, 12 Hz

Y4 = pulstran(T,D,@rectpuls,0.002);
% when ready open a figure so we know the signal is generated
figure;
wavwrite([Y4], 48000, '12hz_ssaep_click_train.wav');

