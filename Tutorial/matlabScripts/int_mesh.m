%% interpolation mesh for tutorial

clc 
close 
warning off all
clear 
format long

addpath matFunctions/

%% set path

%%% create output folder for stat interpolation: 
%%% mkdir ../run_interp3d/ZSTAT/
% PATH_OUTPUT='../run_interp3d/ZSTAT/';

%%% create output folder for snapshots interpolation: 
%%% mkdir ../run_historyInt/ZSTAT/
% PATH_OUTPUT='../run_historyInt/ZSTAT/';


%% Create mesh
% sampling 

step=0.01;

xx=0.25:step:2.25;
yy=0:step:2;
zz=0;

Nx = length(xx);
Ny = length(yy);
Nz = length(zz);

Npoints=Nx*Ny*Nz;

[XX,YY,ZZ]=meshgrid(xx,yy,zz);

x_points=reshape(XX,[Npoints,1,1]);
y_points=reshape(YY,[Npoints,1,1]);
z_points=reshape(ZZ,[Npoints,1,1]);

disp('save x')
save_coordinate([PATH_OUTPUT,'x.fort'],x_points)

disp('save y')
save_coordinate([PATH_OUTPUT,'y.fort'],y_points)

disp('save z')
save_coordinate([PATH_OUTPUT,'z.fort'],z_points)

disp('done')

