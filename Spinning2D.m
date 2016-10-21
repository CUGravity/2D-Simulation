function [tarray , zarr , param] = Spinning2D_EOMs(tf,needToGenEOMs)
close all;
%% Generate EOMs and add them to the path

param.d_width = 0.1;
param.d_G2T2 = 0.025;
param.d_G3T3 = 0.025;
param.d_G1T12 = 0.1;
param.d_G1T13 = 0.1;
param.lo12 = 1; %rest length
param.lo13 = 1; %rest length
param.ks = 10; %spring constant
param.m1 = 4*(2/3);
param.m2 = 4*(1/6);
param.m3 = 4*(1/6);
param.khv = 1000;
param.I_G1 = param.m1*((param.d_G1T13+param.d_G1T13)^2+param.d_width^2)/12;
param.I_G2 = param.m2*((2*param.d_G2T2)^2+param.d_width^2)/12;
param.I_G3 = param.m3*((2*param.d_G3T3)^2+param.d_width^2)/12;

if needToGenEOMs
    EOMGenerator(param);
end

%% Init Controller
odeP.kp1 = 0;
odeP.kp2 = 0;
odeP.kp3 = 0;
odeP.wti = .1;
odeP.wtf = 1;
odeP.tfin = tf;

%% Propagator
tic;
% x_i = [th1 th1d, th2 th2d, th3 th3d, phi12 phi12d, phi13 phi13d, ...
%     dis_G1G2 disd_G1G2 dis_G1G3 disd_G1G3];
x_i = [0 0, 0 0, 0 0, pi .01, 0 .01, ...
    1+param.d_G1T12 0 1+param.d_G1T13 0]; % NULL
tspan=linspace(0,tf,tf*1000);
[tarray, zarr] = ode45(@RHS, tspan, x_i, odeset, odeP);

disp(['ode45 took ',num2str(toc),' seconds to run']);
end

function xdot = RHS(t,x,odeP)
%x = [th1 th1d, th2 th2d, th3 th3d, phi12 phi12d, phi13 phi13d, ...
%     dis_G1G2 disd_G1G2 dis_G1G3 disd_G1G3];
%x_dot=[th1d th1dd, th2d th2dd, th3d th3dd, phi12d phi12dd, phi13d phi13dd,
%     disd_G1G2 disdd_G1G2 disd_G1G3 disdd_G1G3];

th1 = x(1);
th1d = x(2);
th2 = x(3);
th2d = x(4);
th3 = x(5);
th3d = x(6);
phi12 = x(7);
phi12d = x(8);
phi13 = x(9);
phi13d = x(10);
dis_G1G2 = x(11);
disd_G1G2 = x(12);
dis_G1G3 = x(13);
disd_G1G3 = x(14);

wtarget = odeP.wti + t*(odeP.wtf-odeP.wti)/odeP.tfin;

[coil1, coil2, coil3] = TorqueController1(x,odeP,wtarget);

th1dd = th1dd_EOM(coil1,dis_G1G2,dis_G1G3,phi12,phi13,th1,th2,th3);
th2dd = th2dd_EOM(coil2,dis_G1G2,phi12,th1,th2);
th3dd = th3dd_EOM(coil3,dis_G1G3,phi13,th1,th3);
phi12dd = phi12dd_EOM(dis_G1G2,disd_G1G2,phi12,phi12d,th1,th2);
phi13dd = phi13dd_EOM(dis_G1G3,disd_G1G3,phi13,phi13d,th1,th3);
disdd_G1G2 = disdd_G1G2_EOM(dis_G1G2,phi12,phi12d,th1,th2);
disdd_G1G3 = disdd_G1G3_EOM(dis_G1G3,phi13,phi13d,th1,th3);

xdot = [th1d th1dd, th2d th2dd, th3d th3dd, phi12d phi12dd, ...
    phi13d phi13dd, disd_G1G2 disdd_G1G2 disd_G1G3 disdd_G1G3]';

end

