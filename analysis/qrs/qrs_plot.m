function [] = qrs_plot(chData, cardiacData, name, color, f1, f2, f3, f4, f5)

    % chData must be at least high pass filtered (to get rid of drifting
    % cardiacData probably has to be unfiltered to work
    assert(all(size(chData) == size(cardiacData)));
    %tic
    [pks,locs]=findpeaks(cardiacData,'minpeakdistance', round(0.18 * 9600));
    %toc
    %locs = locs(2:(end-1));

    if (nargin >= 5 && f1 ~= 0)
        %% Plot Cardiac Data with Detected Peaks
        figure(f1);
        hold on;
        plot((1:numel(cardiacData)) / 9600, cardiacData, 'color', color);
        yl = ylim;
        for i = 1:numel(locs)
            plot(locs(i) * [1 1] / 9600, yl, 'color', 'black');
        end
        plot((1:numel(cardiacData)) / 9600, cardiacData, 'color', color);
        ylim(yl);
        xlabel('Time (seconds)');
        ylabel('$\mu V$', 'interpreter', 'LaTeX');
        title('Detected R Wave');
        xlim([0 numel(cardiacData) / 9600]);
    
        %saveas(f1, ['matlab_data/' name '_' int2str(channel) '_r_peak.fig']);
        saveas(f1, ['matlab_data/' name '_r_peak.fig']);
    end

    if (nargin >= 6 && f2 ~= 0)
        %% Compute Distance between R Peaks
        dt = diff(locs);
    
        %% Plot Distance between r peaks
        figure(f2);
        scatter(1:numel(dt), dt / 9600 * 1000, 36, color);
        xlabel('Interval Number');
        ylabel('Interval Length (ms)');
        title('Time Between R Peaks');
        xlim([0 numel(dt)]);
        ylim([150 300]);
    
        %[a,b] = min(dt);
        %figure(f1);
        %xlim(locs(b) / 9600 + [-0.4 0.4]);
        %locs(b + (-1:1)) / 9600 * 1000
    
        %saveas(f1, ['matlab_data/' name '_' int2str(channel) '_dt.fig']);
        %save2pdf(['matlab_data/' name '_' int2str(channel) '_dt.pdf'], f2, 1200);
        saveas(f2, ['matlab_data/' name '_dt.fig']);
        save2pdf(['matlab_data/' name '_dt.pdf'], f2, 1200);
    end

    %% Compute interval (include first, exclude last)
    cutoff = [1; locs(1:(end-1)) + round(diff(locs) / 2); numel(chData) + 1];

    if (nargin >= 7 && f3 ~= 0)
        %% Plot Distance between midpoints
        figure(f3);
        scatter(1:numel(dt), dt / 9600 * 1000, 36, color);
        xlabel('Interval Number');
        ylabel('Interval Length (ms)');
        title('Time Between Complexes');
        xlim([0 numel(dt)]);
        ylim([150 300]);
    
        %[a,b] = min(dt);
        %figure(f1);
        %xlim(locs(b) / 9600 + [-0.4 0.4]);
        %locs(b + (-1:1)) / 9600 * 1000
    
        %saveas(f1, ['matlab_data/' name '_' int2str(channel) '_dt.fig']);
        %save2pdf(['matlab_data/' name '_' int2str(channel) '_dt.pdf'], f3, 1200);
        saveas(f3, ['matlab_data/' name '_dt.fig']);
        save2pdf(['matlab_data/' name '_dt.pdf'], f3, 1200);
    end

    %% Compute start, R peak, end, and length of each interval
    r_peak = locs;
    start = cutoff(1:(end-1));
    finish = cutoff(2:end);

    assert(all(size(start) == size(r_peak)));
    assert(all(size(start) == size(finish)));
    assert(all(start < r_peak));
    assert(all(r_peak < finish));

    dt = finish - start;
    max_before = max(r_peak - start);
    max_after = max(finish - r_peak);
    median_before = median(r_peak - start);
    median_after = median(finish - r_peak);

    %% Gather and align the channel data
    %padded = nan(numel(r_peak), max(dt));
    padded = zeros(numel(r_peak), max_before + max_after);
    for i = 1:numel(r_peak)
        padded(i, (start(i):(finish(i)-1)) - r_peak(i) + max_before + 1) = chData(start(i):(finish(i)-1));
    end

    %% Check that every column/row has a non-nan value
    assert(all(any(~isnan(padded),1)));
    assert(all(any(~isnan(padded),2)));

    %% Remove trials that have extreme values
    invalid = any(abs(padded) > 1e3, 2); % for some reason after applying hpf/lpf/nf, first and last area have extreme values
    num_invalid = sum(invalid)
    assert(sum(invalid) < 15);
    padded = padded(~invalid, :);

    qrs = nanmean(padded, 1)';

    if (nargin >= 8 && f4 ~= 0)
        %% Plot Mean and Confidence Interval
        figure(f4);
        hold on;
        plot(((1:numel(qrs)) - max_before) / 9600, qrs, 'color', color, 'linewidth', 2);
        confMean = bootci(100, @nanmean, padded);
        plot(((1:numel(qrs)) - max_before) / 9600, confMean(1,:),'--','color',color,'linewidth',2);
        plot(((1:numel(qrs)) - max_before) / 9600, confMean(2,:),'--','color',color,'linewidth',2);
    
        xlabel('Time (seconds)');
        ylabel('$\mu V$', 'interpreter', 'LaTeX');
        title('QRS Complex Shape');
        %xlim([0 numel(qrs) / 9600]);
        xlim([-median_before, median_after] / 9600);
        ylim([-120 120]);
        set(findall(f4,'type','text'),'fontSize',40,'fontWeight','normal', 'color', [0,0,0]);
        set(gca,'FontSize',40);
    
        %save2pdf(['matlab_data/' name '_' int2str(channel) '_qrs.pdf'], f4, 1200);
        save2pdf(['matlab_data/' name '_qrs.pdf'], f4, 1200);
    end

    if (nargin >= 9 && f5 ~= 0)
        %% Plot all curves
        figure(f5);
        hold on;
        plot(((1:numel(qrs)) - max_before) / 9600, padded, 'color', color);
        xlabel('Time (seconds)');
        ylabel('$\mu V$', 'interpreter', 'LaTeX');
        title('QRS Complex Shape');
        %xlim([0 numel(qrs) / 9600]);
        xlim([-median_before, median_after] / 9600);
        ylim([-120 120]);
        set(findall(f4,'type','text'),'fontSize',40,'fontWeight','normal', 'color', [0,0,0]);
        set(gca,'FontSize',40);
    
        %save2pdf(['matlab_data/' name '_' int2str(channel) '_qrs_all.pdf'], f3, 1200);
        save2pdf(['matlab_data/' name '_qrs_all.pdf'], f5, 1200);
    end

    %% Remove qrs
    %filtered_data = zeros(size(chData));
    %for i = 1:numel(r_peak)
    %    filtered_data(start(i):(finish(i)-1)) = chData(start(i):(finish(i)-1)) - padded(i, 1:(finish(i)-start(i)))';
    %end
end

