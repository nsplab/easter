function [ filtered_data ] = qrs_removal(chData, cardiacData, name, color, channel)

    if nargin >= 3 && nargin < 4
        color = 'blue';
    end

    % chData must be at least high pass filtered (to get rid of drifting
    % cardiacData probably has to be unfiltered to work
    assert(all(size(chData) == size(cardiacData)));
    %tic
    [pks,locs]=findpeaks(cardiacData,'minpeakdistance', round(0.18 * 9600));
    %toc
    %locs = locs(2:(end-1));

    if nargin >= 3
        f1 = figure;
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

        saveas(f1, ['matlab_data/' name '_' int2str(channel) '_r_peak.fig']);
    end

    dt = diff(locs);

    if nargin >= 3
        f2 = figure;
        scatter(1:numel(dt), dt / 9600 * 1000, 36, color);
        xlabel('Interval Number');
        ylabel('Interval Length (ms)');
        title('Time Between R Peaks');
        xlim([0 numel(dt)]);
        ylim([200 270]);

        %[a,b] = min(dt);
        %figure(f1);
        %xlim(locs(b) / 9600 + [-0.4 0.4]);
        %locs(b + (-1:1)) / 9600 * 1000

        saveas(f1, ['matlab_data/' name '_' int2str(channel) '_dt.fig']);
        save2pdf(['matlab_data/' name '_' int2str(channel) '_dt.pdf'], f2, 1200);
    end

    %% Gather and align the channel data
    standard = round(median(dt));
    padded = nan(numel(locs) + 1, max(dt));
    % first period
    padded(1, standard + ((-locs(1)+2):0)) = chData(1:(locs(1)-1));
    % middle periods
    for i = 1:(numel(locs) - 1)
        padded(i + 1, 1:(locs(i+1)-locs(i))) = chData(locs(i):(locs(i+1)-1));
    end
    % last period
    padded(numel(locs) + 1, 1:(numel(chData)+1-locs(end))) = chData(locs(end):numel(chData));

    %% Check that every column/row has a non-nan value
    assert(all(any(~isnan(padded),1)));
    assert(all(any(~isnan(padded),2)));

    %% Remove trials that have extreme values
    invalid = any(abs(padded) > 1e3, 2); % for some reason after applying hpf/lpf/nf, first and last area have extreme values
    num_invalid = sum(invalid);
    fprintf('num_invalid: %d\n', num_invalid);
    %assert(sum(invalid) < 15);
    padded = padded(~invalid, :);

    qrs = nanmean(padded, 1)';

    if nargin >= 3
        f3 = figure;
        scatter((1:numel(qrs)) / 9600, qrs, 36, color);
        xlabel('Time (seconds)');
        ylabel('$\mu V$', 'interpreter', 'LaTeX');
        title('QRS Complex Shape');
        xlim([0 numel(qrs) / 9600]);
        ylim([-100 100]);

        save2pdf(['matlab_data/' name '_' int2str(channel) '_qrs.pdf'], f3, 1200);

        f3 = figure;
        plot((1:numel(qrs)) / 9600, padded, 'color', color);
        xlabel('Time (seconds)');
        ylabel('$\mu V$', 'interpreter', 'LaTeX');
        title('QRS Complex Shape');
        xlim([0 numel(qrs) / 9600]);
        ylim([-100 100]);

        save2pdf(['matlab_data/' name '_' int2str(channel) '_qrs_all.pdf'], f3, 1200);
    end

    filtered_data = chData;

    % first period
    filtered_data(1:(locs(1)-1)) = chData(1:(locs(1)-1)) - qrs(standard + ((-locs(1)+2):0));
    % middle periods
    for i = 1:(numel(locs) - 1)
        filtered_data(locs(i):(locs(i+1)-1)) = chData(locs(i):(locs(i+1)-1)) - qrs(1:(locs(i+1)-locs(i)));
    end
    % last period
    filtered_data(locs(end):numel(chData)) = chData(locs(end):numel(chData)) - qrs(1:(numel(chData)+1-locs(end)));

end

