function [ S, allData ] = get_information(pathname, pathname_comments, experiment)

% experiment is 'VEP', 'SSVEP', 'SSAEP'

tmp = dir(pathname);                                                       % get the list of data filenames for this particular type of evoked potential
S = {tmp(3:end).name};                                                     % chop out the '.' and '..' filename entries that are in every directory
%                                                                          %note from Ram, 4/18/14: do *not* sort by modification time - this may change; instead, rely on lexicographic sort of name which contains timestamp
%S = [tmp(:).datenum].';                                                   
%[S,S] = sort(S);
%S = {tmp(S).name};                                                        

fid = fopen(pathname_comments);
if fid==-1                      %if the vep.txt comments file doesn't exist, display an error message to the console and skip the textscan
    disp('Hey - you may want to create vep.txt to populate the titles in these figures. See plot_all_vep.m for details.');
    allData = [];
else
    allData = textscan(fid,'%s','Delimiter','\n');
    % specific for rabbit 8
    C = strfind(allData{1}, ['- ' experiment]); % get rows with '- VEP' in them
    rows = find(~cellfun('isempty', C));
    allData = allData{1}(rows);
    fclose(fid);
end

assert_match(S, allData);

end

