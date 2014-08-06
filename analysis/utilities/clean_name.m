function [ name ] = clean_name(name)

name(name == '.') = '_';
while any(name == '%')
    index = find(name == '%', 1);
    name = [name(1:(index-1)) '_' name((index+3):end)];
end

end

