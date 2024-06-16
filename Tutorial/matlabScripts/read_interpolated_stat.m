%%

clc
close all
clear
format long
double precision;

addpath matFunctions/

%% Setup info

PATH_MESH='../run_interp3d/ZSTAT/';
PATH_INTa='../run_interp3d/output_a/';
PATH_INTb='../run_interp3d/output_b/';

Re=1000;
nu = 1/Re;

%% Load Data

disp('load data')

% Read interpolated data (a files)

stat_a = load_stat_a(PATH_INTa);

% Read interpolated data (b files)

stat_b = load_stat_b(PATH_INTb);

disp('done')

run matFunctions/check_stats.m

%% complete stats


stat_a.uu = stat_b.uu;
stat_a.uw = stat_b.uw;
stat_a.ppp = stat_b.ppp;
stat_a.www = stat_b.www;
stat_a.vvw = stat_b.vvw;
stat_a.Pxx = stat_b.Pxx;
stat_a.Pxz = stat_b.Pxz;
stat_a.Dzz = stat_b.Dzz;
stat_a.Txx = stat_b.Txx;
stat_a.Txz = stat_b.Txz;
stat_a.VDzz = stat_b.VDzz;
stat_a.Pixx = stat_b.Pixx;
stat_a.Pixz = stat_b.Pixz;
stat_a.Czz = stat_b.Czz;
stat_a.Pk = stat_b.Pk;
stat_a.Pik = stat_b.Pik;
stat_a.PTyy = stat_b.PTyy;
stat_a.PTyz = stat_b.PTyz;
stat_a.PSxy = stat_b.PSxy;
stat_a.dUdy = stat_b.dUdy;
stat_a.dVdz = stat_b.dVdz;

stat_a.dPdx = stat_b.dPdx;
stat_a.dPdy = stat_b.dPdy;
stat_a.dPdz = stat_b.dPdz;

%%

% save('tut.mat','stat_a','stat_b')
save('tutHR.mat','stat_a','stat_b')


%% figures

step=0.01;

xx=0.25:step:2.25;
yy=0:step:2;

Nx = length(xx);
Ny = length(yy);

[XX,YY]=meshgrid(xx,yy);

U= reshape(stat_a.U,[Nx,Ny]);
V= reshape(stat_a.V,[Nx,Ny]);
W= reshape(stat_a.W,[Nx,Ny]);

%%

figure
h=pcolor(XX,YY,U); set(h, 'EdgeColor', 'none'); colorbar;
axis equal tight
title('$U$','FontSize',16,'Interpreter','latex')
xlabel('$x$','FontSize',16,'Interpreter','latex')
ylabel('$y$','FontSize',16,'Interpreter','latex')

%%

figure('rend','painters','pos',[10 10 1500 600])

subplot(1,3,1)
h=pcolor(XX,YY,U); set(h, 'EdgeColor', 'none'); colorbar;
axis equal tight
title('$U$','FontSize',16,'Interpreter','latex')
xlabel('$x$','FontSize',16,'Interpreter','latex')
ylabel('$y$','FontSize',16,'Interpreter','latex')

subplot(1,3,2)
h=pcolor(XX,YY,V); set(h, 'EdgeColor', 'none'); colorbar;
axis equal tight
title('$V$','FontSize',16,'Interpreter','latex')
xlabel('$x$','FontSize',16,'Interpreter','latex')
ylabel('$y$','FontSize',16,'Interpreter','latex')

subplot(1,3,3)
h=pcolor(XX,YY,W); set(h, 'EdgeColor', 'none'); colorbar;
axis equal tight
title('$W$','FontSize',16,'Interpreter','latex')
xlabel('$x$','FontSize',16,'Interpreter','latex')
ylabel('$y$','FontSize',16,'Interpreter','latex')

saveas(gcf,'U.png')

%%

uu= reshape(stat_a.uu,[Nx,Ny]);
vv= reshape(stat_a.vv,[Nx,Ny]);
ww= reshape(stat_a.ww,[Nx,Ny]);
uv= reshape(stat_a.uv,[Nx,Ny]);
uw= reshape(stat_a.uw,[Nx,Ny]);
vw= reshape(stat_a.vw,[Nx,Ny]);

figure('rend','painters','pos',[10 10 1600 800])

subplot(2,3,1)
h=pcolor(XX,YY,uu); set(h, 'EdgeColor', 'none'); colorbar;
axis equal tight
title('$\overline{uu}$','FontSize',16,'Interpreter','latex')
xlabel('$x$','FontSize',16,'Interpreter','latex')
ylabel('$y$','FontSize',16,'Interpreter','latex')

subplot(2,3,2)
h=pcolor(XX,YY,vv); set(h, 'EdgeColor', 'none'); colorbar;
axis equal tight
title('$\overline{vv}$','FontSize',16,'Interpreter','latex')
xlabel('$x$','FontSize',16,'Interpreter','latex')
ylabel('$y$','FontSize',16,'Interpreter','latex')

subplot(2,3,3)
h=pcolor(XX,YY,ww); set(h, 'EdgeColor', 'none'); colorbar;
axis equal tight
title('$\overline{ww}$','FontSize',16,'Interpreter','latex')
xlabel('$x$','FontSize',16,'Interpreter','latex')
ylabel('$y$','FontSize',16,'Interpreter','latex')

subplot(2,3,4)
h=pcolor(XX,YY,uv); set(h, 'EdgeColor', 'none'); colorbar;
axis equal tight
title('$\overline{uv}$','FontSize',16,'Interpreter','latex')
xlabel('$x$','FontSize',16,'Interpreter','latex')
ylabel('$y$','FontSize',16,'Interpreter','latex')

subplot(2,3,5)
h=pcolor(XX,YY,uw); set(h, 'EdgeColor', 'none'); colorbar;
axis equal tight
title('$\overline{uw}$','FontSize',16,'Interpreter','latex')
xlabel('$x$','FontSize',16,'Interpreter','latex')
ylabel('$y$','FontSize',16,'Interpreter','latex')

subplot(2,3,6)
h=pcolor(XX,YY,vw); set(h, 'EdgeColor', 'none'); colorbar;
axis equal tight
title('$\overline{vw}$','FontSize',16,'Interpreter','latex')
xlabel('$x$','FontSize',16,'Interpreter','latex')
ylabel('$y$','FontSize',16,'Interpreter','latex')

saveas(gcf,'uu.png')

