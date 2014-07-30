clear;
close all;

addpath('../utilities');

%% Constants
channelNames_VEP = {'Disconnected','Endo','Mid head','Disconnected','Right Eye','Right Leg','Back Head','Left Eye','Bottom Precordial','Top Precordial'};
maxNumberOfChannels = 10;
digitalinCh = 65;
channelToPlot = [2,3,5,7,8];
%channelToPlot = [2];
fs = 9600;

CM = [hex2dec('e9'), hex2dec('00'), hex2dec('3a');
      hex2dec('ff'), hex2dec('ba'), hex2dec('00');
      hex2dec('40'), hex2dec('40'), hex2dec('ff');
      hex2dec('58'), hex2dec('e0'), hex2dec('00');
      hex2dec('b0'), hex2dec('00'), hex2dec('b0')];

CM = CM/256;


%% Filters
hp = fdesign.highpass('Fst,Fp,Ast,Ap',(2.0),(10.0),90,1,fs);
hpf = design(hp, 'butter');

lp = fdesign.lowpass('Fp,Fst,Ap,Ast',(220.0),(256.0),1,90,fs);
lpf = design(lp, 'butter');

n60 = fdesign.notch('N,F0,BW,Ap',6,60,20,2,fs);
n120 = fdesign.notch('N,F0,Q,Ap',6,120,10,1,fs);
n180 = fdesign.notch('N,F0,Q,Ap',6,180,10,1,fs);
nf60 = design(n60);
nf120 = design(n120);
nf180 = design(n180);

for rabbit_ID = {'9rabbit_may_6_2014', '10rabbit_may_15_2014'}
    rabbit_ID = rabbit_ID{1};
    fprintf('rabbit_ID: %s\n', rabbit_ID);

    switch rabbit_ID
        case '9rabbit_may_6_2014'
            vep_indices = [10 2 10 11 12 13 3];
            ssvep_indices = [5 29 32 38 8];
            ssaep_indices = [8 32 35 41 11];
        case '10rabbit_may_15_2014'
            vep_indices = [4 10 12 15 5];
            ssvep_indices = [11 23 32 35 14];
            ssaep_indices = [15 24 33 36 12];
    end

    pathname_comments = ['../../../../data/easter/' rabbit_ID '/neuro/neuro_experiment_log.txt'];

    fid = fopen(pathname_comments);
    if fid == -1
        disp('Hey - you may want to create vep.txt to populate the titles in these figures. See plot_all_vep.m for details.');
       return;
    end

    neuro_experiment_log = textscan(fid,'%s','Delimiter','\n');


    for experiment = {'vep', 'ssvep', 'ssaep'}
        experiment = experiment{1};
        fprintf('experiment: %s\n', experiment);

        pathname = ['../../../../data/easter/' rabbit_ID '/neuro/binary_data/' experiment '/'];
        pathname_matdata = ['../../../../data/easter/' rabbit_ID '/neuro/matlab_data/' experiment '/'];

        C = strfind(neuro_experiment_log{1}, ['- ' upper(experiment)]); % get rows with '- VEP' in them
        rows = find(~cellfun('isempty', C));
        allData = neuro_experiment_log{1}(rows);

        tmp = dir(pathname);
        S = {tmp(3:end).name}; 

        %% Check for matching experiment log and data files
        assert(length(S) == length(allData)); % check that the experiment log and data files have the same number of VEP runs
        for i = 1:length(S)
            % Hard coded parsing of file name
            assert(strcmp(S{i}(1), '_'))
            S_day = S{i}(2:4);
            assert(strcmp(S{i}(5), '_'))
            S_date = S{i}(6:7);
            assert(strcmp(S{i}(8), '.'))
            S_month = S{i}(9:10);
            assert(strcmp(S{i}(11), '.'))
            S_month = S{i}(12:15);
            assert(strcmp(S{i}(16), '_'))
            S_hour = S{i}(17:18);
            assert(strcmp(S{i}(19:21), '%3A'))
            S_minute = S{i}(22:23);
            assert(strcmp(S{i}(24:26), '%3A'))
            S_second = S{i}(27:28);
            assert(strcmp(S{i}(29 + (0:numel(experiment)+1)), ['_' experiment '_']))
            S_extra = S{i}(29+numel(experiment)+2:end);
        
            % Hard coded parsing of experiment log
            header = allData{i};
            if header(2) == ':'
                header = ['0' header]; % one digit hour - pad with extra 0
            end
            header_hour = header(1:2);
            assert(strcmp(header(3), ':'))
            header_minute = header(4:5);
            assert(strcmp(header(6), ':'))
            header_second = header(7:8);
        
            % Check for explicit match
            assert(strcmp(S_hour, header_hour));
            assert(strcmp(S_minute, header_minute));
            assert(strcmp(S_second, header_second));
        end

        indices = eval([experiment '_indices']);
        for i_ = 1:numel(indices)
            i = indices(i_);
            filename = S{i};

            % Clean name format
            name = S{i};
            name(name == '.') = '_';
            while any(name == '%')
                index = find(name == '%', 1);
                name = [name(1:(index-1)) '_' name((index+3):end)];
            end

            fprintf('i_: %d / %d,\ti: %d,\t%s, \t%s\n', i_, numel(indices), i, filename, name);

            %% Load data
            fid = fopen([pathname filename], 'r');

            data = cell(maxNumberOfChannels, 2);

            for j=1:maxNumberOfChannels
                fseek(fid, 4*(j-1), 'bof');
                dataColumn = fread(fid, Inf, 'single', 4*64);
                channelName = channelNames_VEP{j};

                data(j,1) = {channelName};
                data(j,2) = {dataColumn};
            end

            fseek(fid, 4*(digitalinCh-1), 'bof');
            dataColumnDig = fread(fid, Inf, 'single', 4*64);
            cleanDigitalIn = (dataColumnDig>0);

            cardiacData = data{strcmp(data, 'Bottom Precordial'), 2};

            cardiacData = filtfilt(nf60.sosMatrix, nf60.ScaleValues, cardiacData);
            cardiacData = filtfilt(nf120.sosMatrix, nf120.ScaleValues, cardiacData);
            cardiacData = filtfilt(nf180.sosMatrix, nf180.ScaleValues, cardiacData);

            cardiacData = filtfilt(hpf.sosMatrix, hpf.ScaleValues, cardiacData);

            cardiacData = filtfilt(lpf.sosMatrix, lpf.ScaleValues, cardiacData);

            f1 = figure('units', 'pixels', 'outerposition', [0 0 1366 768]);
            f2 = figure('units', 'pixels', 'outerposition', [0 0 1366 768]);
            f3 = figure('units', 'pixels', 'outerposition', [0 0 1366 768]);
            f4 = figure('units', 'pixels', 'outerposition', [0 0 1366 768]);
            f5 = figure('units', 'pixels', 'outerposition', [0 0 1366 768]);

            figure(f4);
            plot([0 0], [-120 120], 'color', 'black', 'linewidth', 4);
            qrs_plot(0.125 * cardiacData, cardiacData, name, 'black', f1, f2, f3, f4, f5);

            for ii=1:length(channelToPlot)
                fprintf('ii: %d, %d\n', ii, channelToPlot(ii));

                chData = data{channelToPlot(ii),2};

                % Apply filters
                chData = filtfilt(nf60.sosMatrix, nf60.ScaleValues,chData);
                chData = filtfilt(nf120.sosMatrix, nf120.ScaleValues,chData);
                chData = filtfilt(nf180.sosMatrix, nf180.ScaleValues,chData);

                chData = filtfilt(hpf.sosMatrix, hpf.ScaleValues,chData);

                chData = filtfilt(lpf.sosMatrix, lpf.ScaleValues,chData);

                qrs_plot(chData, cardiacData, name, CM(ii, :), 0, 0, 0, f4, f5);

            end

            ansdkasnd

            %saveas(f1, ['matlab_data/' name '_' int2str(channel) '_r_peak.fig']);
            saveas(f1, ['matlab_data/' name '_r_peak.fig']);

            %saveas(f1, ['matlab_data/' name '_' int2str(channel) '_dt.fig']);
            %save2pdf(['matlab_data/' name '_' int2str(channel) '_dt.pdf'], f2, 1200);
            saveas(f2, ['matlab_data/' name '_dt.fig']);
            save2pdf(['matlab_data/' name '_dt.pdf'], f2, 1200);

            %saveas(f1, ['matlab_data/' name '_' int2str(channel) '_dt.fig']);
            %save2pdf(['matlab_data/' name '_' int2str(channel) '_dt.pdf'], f3, 1200);
            saveas(f3, ['matlab_data/' name '_dt.fig']);
            save2pdf(['matlab_data/' name '_dt.pdf'], f3, 1200);

            %save2pdf(['matlab_data/' name '_' int2str(channel) '_qrs.pdf'], f4, 1200);
            save2pdf(['matlab_data/' name '_qrs.pdf'], f4, 1200);


            %save2pdf(['matlab_data/' name '_' int2str(channel) '_qrs_all.pdf'], f3, 1200);
            save2pdf(['matlab_data/' name '_qrs_all.pdf'], f5, 1200);

            close all;

        end
    end
end

