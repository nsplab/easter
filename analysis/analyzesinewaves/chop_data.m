function data = chop_data(data, chopmeta, indicator)

fileID=fopen(chopmeta);
tline=fgets(fileID);
while ischar(tline)
    line = strsplit(tline, ':'); %This takes out the characters ahead of the colon
    if strcmp(line(1), indicator) == 1
        data(str2num(line{2}):str2num(line{3})) = []
        break
    else
        
    end
    tline = fgets(fileID);    
end
fclose(fileID);