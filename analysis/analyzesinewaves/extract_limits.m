function [right_lim, left_lim, limit] = extract_limits(filename, indicator)
%EXTRACT_LIMITS uses the metadata file and the passed indicator to find the
%starting index, ending index and lower limit for the data

%----
%Input: 
%----
%filename: filename of the metadata file, with the path
%indicator: indicator to look in the metadata file, it  is usually the name
%of the file without the extension

%----
%Output
%----
%right_lim: Staring index of the data
%left_lim: Ending Index of the data
%limit: Lower limit of the data

fileID=fopen(filename);
tline=fgets(fileID);
line_idx = 1;
while ischar(tline)
    line = strsplit(tline, ':'); %This takes out the characters ahead of the colon
    if strcmp(line(1), indicator) == 1
        break
    end
    tline = fgets(fileID);    
end
right_lim = str2num(line{2});
left_lim = str2num(line{3});
limit = -str2num(line{4});
fclose(fileID);
