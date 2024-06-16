function [statdata] = load_stat_b(PATH_INT)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

%Load file containing number of points per core
load(strcat([PATH_INT,'history2.txt']))
ncores=history2(end,1)+1; % number of cores

for field_number=1:8
%U
%%%%%
fname=[PATH_INT,strcat('U'),num2str(field_number,'%2.2d')];
disp(['read file: ',fname])

[fid,message] = fopen(fname,'r','ieee-le');
hdr           = fread(fid,1,'int32')      ;
F             = fread(fid,hdr,'*char')'   ;
dum5          = fread(fid,1,'*float64')   ;
time          = fread(fid,1,'*float64')   ;
sfn           = fread(fid,1,'int32')      ;
dum6          = fread(fid,1,'*float64')   ;

aa=fread(fid,Inf,'*float64');

%Assign points taking into account gaps among processors
for i=1:ncores
    bb(1+sum(history2(1:i-1,2)):sum(history2(1:i,2)),1)=aa(1+sum(history2(1:i-1,2))+(i-1):sum(history2(1:i,2))+(i-1));
end

UD{field_number}=bb;

fclose(fid);

%W
%%%%%
fname=[PATH_INT,strcat('W'),num2str(field_number,'%2.2d')];
disp(['read file: ',fname])

[fid,message] = fopen(fname,'r','ieee-le');
hdr           = fread(fid,1,'int32')      ;
F             = fread(fid,hdr,'*char')'   ;
dum5          = fread(fid,1,'*float64')   ;
time          = fread(fid,1,'*float64')   ;
sfn           = fread(fid,1,'int32')      ;
dum6          = fread(fid,1,'*float64')   ;

aa=fread(fid,Inf,'*float64');

%Assign points taking into account gaps among processors
for i=1:ncores
    bb(1+sum(history2(1:i-1,2)):sum(history2(1:i,2)),1)=aa(1+sum(history2(1:i-1,2))+(i-1):sum(history2(1:i,2))+(i-1));
end

WD{field_number}=bb;

fclose(fid);

%L2
%%%%%
fname=[PATH_INT,strcat('L'),num2str(field_number,'%2.2d')];
disp(['read file: ',fname])

[fid,message] = fopen(fname,'r','ieee-le');
hdr           = fread(fid,1,'int32')      ;
F             = fread(fid,hdr,'*char')'   ;
dum5          = fread(fid,1,'*float64')   ;
time          = fread(fid,1,'*float64')   ;
sfn           = fread(fid,1,'int32')      ;
dum6          = fread(fid,1,'*float64')   ;

aa=fread(fid,Inf,'*float64');

%Assign points taking into account gaps among processors
for i=1:ncores
    bb(1+sum(history2(1:i-1,2)):sum(history2(1:i,2)),1)=aa(1+sum(history2(1:i-1,2))+(i-1):sum(history2(1:i,2))+(i-1));
end

LD{field_number}=bb;

fclose(fid);

%V
%%%%%
fname=[PATH_INT,strcat('V'),num2str(field_number,'%2.2d')];
disp(['read file: ',fname])

[fid,message] = fopen(fname,'r','ieee-le');
hdr           = fread(fid,1,'int32')      ;
F             = fread(fid,hdr,'*char')'   ;
dum5          = fread(fid,1,'*float64')   ;
time          = fread(fid,1,'*float64')   ;
sfn           = fread(fid,1,'int32')      ;
dum6          = fread(fid,1,'*float64')   ;

aa=fread(fid,Inf,'*float64');

%Assign points taking into account gaps among processors
for i=1:ncores
    bb(1+sum(history2(1:i-1,2)):sum(history2(1:i,2)),1)=aa(1+sum(history2(1:i-1,2))+(i-1):sum(history2(1:i,2))+(i-1));
end

VD{field_number}=bb;

fclose(fid);
end

%% Define data
statdata.uu=UD{1};
statdata.uw=VD{1};
statdata.ppp=WD{1};

statdata.www=UD{2};
statdata.vvw=VD{2};
statdata.Pxx=WD{2};

statdata.Pxz=UD{3};
statdata.Dzz=VD{3};
statdata.Txx=WD{3};

statdata.Txz=UD{4};
statdata.VDzz=VD{4};
statdata.Pixx=WD{4};

statdata.Pixz=UD{5};
statdata.Czz=VD{5};
statdata.Pk=WD{5};

statdata.Pik=UD{6};
statdata.PTyy=VD{6};
statdata.PTyz=WD{6};

statdata.PSxy=UD{7};
statdata.dUdy=VD{7};
statdata.dVdz=WD{7};

statdata.dPdx=UD{8};
statdata.dPdy=VD{8};
statdata.dPdz=WD{8};

end
