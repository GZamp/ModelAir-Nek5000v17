function [statdata] = load_stat_a(PATH_INT)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

%Load file containing number of points per core
load(strcat([PATH_INT,'history2.txt']))
ncores=history2(end,1)+1; % number of cores


for field_number=1:22
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

statdata.U = UD{1};
statdata.V = VD{1};
statdata.W = WD{1};
statdata.uu = LD{1};

statdata.vv = UD{2};
statdata.ww = VD{2};
statdata.uv = WD{2};
statdata.uw = LD{2};

statdata.vw = UD{3};
statdata.P  = VD{3};
statdata.pp = WD{3};
statdata.ppp = LD{3};

statdata.pppp = UD{4};
statdata.uuu = VD{4};
statdata.vvv = WD{4};
statdata.www = LD{4};

statdata.uuv = UD{5};
statdata.uuw = VD{5};
statdata.uvv = WD{5};
statdata.vvw = LD{5};

statdata.uww = UD{6};
statdata.vww = VD{6};
statdata.uvw = WD{6};
statdata.Pxx = LD{6};

statdata.Pyy = UD{7};
statdata.Pzz = VD{7};
statdata.Pxy = WD{7};
statdata.Pxz = LD{7};

statdata.Pyz = UD{8};
statdata.Dxx = VD{8};
statdata.Dyy = WD{8};
statdata.Dzz = LD{8};

statdata.Dxy = UD{9};
statdata.Dxz = VD{9};
statdata.Dyz = WD{9};
statdata.Txx = LD{9};

statdata.Tyy = UD{10};
statdata.Tzz = VD{10};
statdata.Txy = WD{10};
statdata.Txz = LD{10};

statdata.Tyz = UD{11};
statdata.VDxx = VD{11};
statdata.VDyy = WD{11};
statdata.VDzz = LD{11};

statdata.VDxy = UD{12};
statdata.VDxz = VD{12};
statdata.VDyz = WD{12};
statdata.Pixx = LD{12};

statdata.Piyy = UD{13};
statdata.Pizz = VD{13};
statdata.Pixy = WD{13};
statdata.Pixz = LD{13};

statdata.Piyz = UD{14};
statdata.Cxx = VD{14};
statdata.Cyy = WD{14};
statdata.Czz = LD{14};

statdata.Cxy = UD{15};
statdata.Cxz = VD{15};
statdata.Cyz = WD{15};
statdata.Pk = LD{15};

statdata.Dk = UD{16};
statdata.Tk = VD{16};
statdata.VDk = WD{16};
statdata.Pik = LD{16};

statdata.Ck = UD{17};
statdata.Resk = VD{17};
statdata.PTxx = WD{17};
statdata.PTyy = LD{17};

statdata.PTzz = UD{18};
statdata.PTxy = VD{18};
statdata.PTxz = WD{18};
statdata.PTyz = LD{18};

statdata.PSxx = UD{19};
statdata.PSyy = VD{19};
statdata.PSzz = WD{19};
statdata.PSxy = LD{19};

statdata.PSxz = UD{20};
statdata.PSyz = VD{20};
statdata.dUdx = WD{20};
statdata.dUdy = LD{20};

statdata.dUdz = UD{21};
statdata.dVdx = VD{21};
statdata.dVdy = WD{21};
statdata.dVdz = LD{21};

statdata.dWdx = UD{22};
statdata.dWdy = VD{22};
statdata.dWdz = WD{22};

end
