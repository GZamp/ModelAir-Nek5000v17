%%

clc
close all
clear


%%

load tut.mat; stat_a_tut=stat_a; stat_b_tut=stat_a;
load tutHR.mat; stat_a_tutHR=stat_a; stat_b_tutHR=stat_a;

%%

step=0.01;

xx=0.25:step:2.25;
yy=0:step:2;

Nx = length(xx);
Ny = length(yy);

[XX,YY]=meshgrid(xx,yy);

U= reshape(stat_a_tut.U,[Nx,Ny]);
V= reshape(stat_a_tut.V,[Nx,Ny]);
W= reshape(stat_a_tut.W,[Nx,Ny]);

%%

figure
h=pcolor(XX,YY,U); set(h, 'EdgeColor', 'none'); colorbar;
axis equal tight
title('$U$','FontSize',16,'Interpreter','latex')
xlabel('$x$','FontSize',16,'Interpreter','latex')
ylabel('$y$','FontSize',16,'Interpreter','latex')

%%

iprof=26;

u=U(:,iprof);

figure
plot(u,yy)



