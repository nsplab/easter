% example:
% >> reduce_all_data('../data_complete', '../data');

function [] = reduce_all_data(start_dir, end_dir)

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

    if (file.isdir)
        % recurse on directories
        reduce_all_data([start_dir '/' file.name], [end_dir '/' file.name]);
    else
        % skip text files (experiment logs)
        if ((numel(file.name) >= 4) && strcmp(file.name(end + (-3:0)), '.txt'))
            continue;
        end

        % print current file
        fprintf('%s\t%s\n', [start_dir '/' file.name], [end_dir '/' file.name]);
        % keep only the first 10 channels and digital in channel
        reduce_data([start_dir '/' file.name], [end_dir '/' file.name], 65, [1:10, 65]);
    end
end

end

