function [ category ] = list_by_top( filename)
%prints the category fo the file passed in 

category = strsplit(filename, '/');
category = category(1);


end

