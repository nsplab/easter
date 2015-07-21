function [] = filter_all_cardiac(start_dir, end_dir)
% Example:
% >> reduce_all_data('../data', '../data_filtered');
% Run in util/ directory.

% print current directory
fprintf('%s\t%s\n', start_dir, end_dir);

% Make output directory if needed
if ~exist(end_dir, 'dir')
    mkdir(end_dir);
end

% Grab all files / directories
files = dir(start_dir);

% Run through files / directories
for i = 1:numel(files)

    % Get current filename
    file = files(i);

    % skip . and .. directories
    if (strcmp(file.name, '.') || strcmp(file.name, '..'))
        continue;
    end

    start = [start_dir '/' file.name];
    finish = [end_dir '/' file.name];

    if (file.isdir)
        % recurse on directories
        filter_all_cardiac(start, finish);
    else
        % print current file
        fprintf('%s\t%s\n', start, finish);

        if ((numel(file.name) >= 4) && strcmp(file.name(end + (-3:0)), '.txt'))
            % just copy text files (experiment logs)
            copyfile(start, finish);
        else
            filter_cardiac(start, finish);
        end

    end
end

end

