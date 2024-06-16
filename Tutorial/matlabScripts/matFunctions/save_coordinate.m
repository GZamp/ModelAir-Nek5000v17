function save_coordinate(file_name,values)

fid=fopen(file_name,'w','ieee-le.l64');

%First write 4 bytes integer
data=length(values);
eor=length(data)*8;
fwrite(fid,eor,'int32');
fwrite(fid,data,'int64');
fwrite(fid,eor,'int32');

%Then write npoints reals
data=values;
eor=length(data)*8;
fwrite(fid,eor,'int32');
fwrite(fid,data,'float64');
fwrite(fid,eor,'int32');
fclose(fid);

end

