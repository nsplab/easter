function [] = reduce_all_data(start_dir, end_dir)
%REDUCE_ALL_DATA  Recursively reduces all data in this directory.
%
% REDUCE_ALL_DATA(START_DIR, END_DIR)
%
% Parameters:
%
%   START_DIR is the directory to copy from.
%
%   END_DIR is the directory to copy into.
%
% Output:
%
%   No return value.
%
%   The new files are copied into END_DIR.
%
% Directory names are copied directly. Text files are considered special
% cases, and are copied directly. All other files are assumed to be data
% files, and are reduced.
%
% Example:
% >> reduce_all_data('../data_complete', '../data');


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
        reduce_all_data(start, finish);
    else
        % print current file
        fprintf('%s\t%s\n', start, finish);

        if ((numel(file.name) >= 4) && strcmp(file.name(end + (-3:0)), '.txt'))
            % just copy text files (experiment logs)
            copyfile(start, finish);
        else
            % keep only the first 10 channels and digital in channel
            reduce_data(start, finish, 65, [1:10, 65]);
        end

    end
end

end

