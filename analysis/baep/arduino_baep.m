fs = 9600;

% ask the user to select the data file
run('../loaddata.m');

fid = fopen([pathname filename], 'r');
i = 65;
fseek(fid, 4*(i-1), 'bof');
dataColumn = fread(fid, Inf, 'single', 4*64);
time_axis = (0:length(dataColumn)-1)*1.0/fs;
figure;plot(time_axis,dataColumn);

tmp = (dataColumn>0);
t1 = diff(tmp);
t2 = find(t1==1);
%t3 = find(t1==(-1));
%t2 = [t2(2:end); t3(2:end)];

hp = fdesign.highpass('Fst,Fp,Ast,Ap',(90.0),(105.0),90,1,fs);
hpf = design(hp, 'butter');

lp = fdesign.lowpass('Fp,Fst,Ap,Ast',(2000.0),(2300.0),1,90,fs);
lpf = design(lp, 'butter');

positive = floor(0.09 * fs);
negative = floor(0.09 * fs) - 1;
total = positive * 2;

% choose the colormap for the plots
CM = colorcube(size(data,1)+1);

% draw the figure with white background and full screen
figure('Color',[1 1 1],'units','normalized','outerposition',[0 0 1 1]);
hold on

% the titles in the legend
legends = [];

for i=1:size(data,1)
    i
    
    chData = data{i,2};

    highPassed = filtfilt(hpf.sosMatrix,hpf.ScaleValues,chData);
    bandPassed = filtfilt(lpf.sosMatrix,lpf.ScaleValues,highPassed);

    m = [];

    for j=3:length(t2)-2,
         %m(end+1, 1:total) = bandPassed((t2(i)-negative):(t2(i)+positive)) - bandPassedEar((t2(i)-negative):(t2(i)+positive));
        m(end+1, 1:total) = detrend(chData((t2(j)-negative):(t2(j)+positive)));
    end
     
    t = (-negative:positive)/fs*1000;
    am = mean(m);
    legends(end+1) = plot(t, am,'color',CM(i,:),'linewidth',2);
end

% add the legend
legend(legends, data{:,1})

tmp = title([ 'BAEP: ' filename ' | Ref: middle head | GND: nose |  # samples =' int2str(length(t2)) ]);
set(tmp,'interpreter','none');

xlabel('time (ms)');
ylabel('$\mu V$','Interpreter','LaTex');

grid on
grid minor

