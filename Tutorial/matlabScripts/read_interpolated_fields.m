%%

clc
close all
clear
format long
double precision;

addpath matFunctions/

%% Setup info

PATH_MESH='../run_interp3d_history/ZSTAT/';
PATH_INT='../run_historyInt/ZSTAT/';

%% Load Data

disp('load data')

% Read interpolated data (a files)

history_fields = load_fields(PATH_INT,33);

disp('done')

%% figures

step=0.01;

xx=0.25:step:2.25;
yy=0:step:2;

Nx = length(xx);
Ny = length(yy);

[XX,YY]=meshgrid(xx,yy);

i_time = 33;

U= reshape(history_fields.U{i_time},[Nx,Ny]);
V= reshape(history_fields.V{i_time},[Nx,Ny]);
W= reshape(history_fields.W{i_time},[Nx,Ny]);

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





