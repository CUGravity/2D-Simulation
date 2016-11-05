function [tarray , zarr , param] = Spinning2D(tf,needToGenEOMs)
close all;
%% Generate EOMs and add them to the path

param.d_width = 0.1;
param.d_G2T2 = 0.025;
param.d_G3T3 = 0.025;
param.d_G1T12 = 0.1;
param.d_G1T13 = 0.1;
param.lo12 = 1; %rest length
param.lo13 = 1; %rest length
% Dyneema
tethE = 1.72e11; % 172000 MPa
tethA = pi*((5e-4)/2)^2; % diameter = 0.5mm
param.ks = (tethE*tethA/param.lo12); %spring constant
% param.ks = 100; %spring constant
param.m1 = 4*(2/3);
param.m2 = 4*(1/6);
param.m3 = 4*(1/6);
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
odeP.wtf = .3;
odeP.tmid = tf/2;
odeP.kramp = 0.03;

%% Propagator
tic;
% x_i = [th1 th1d, th2 th2d, th3 th3d, phi12 phi12d, phi13 phi13d, ...
%     dis_G1G2 disd_G1G2 dis_G1G3 disd_G1G3, x1 x1d, y1 y1d];
x_i = [0 0, 0 0, 0 0, pi .09, 0 .1, ...
    param.lo12+param.d_G1T12 0 param.lo13+param.d_G1T13 0, 0 0, 0 0]; % NULL
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
x1 = x(15);
x1d = x(16);
y1 = x(17);
y1d = x(18);

% wtarget = odeP.wti + t*(odeP.wtf-odeP.wti)/odeP.tfin;
wtarget = odeP.wti +(odeP.wtf-odeP.wti)/(1+exp(-odeP.kramp*(t-odeP.tmid)));

[coil1, coil2, coil3] = TorqueController1(x,odeP,wtarget);

th1dd = th1dd_EOM(coil1,dis_G1G2,dis_G1G3,phi12,phi13,th1,th2,th3);
th2dd = th2dd_EOM(coil2,dis_G1G2,phi12,th1,th2);
th3dd = th3dd_EOM(coil3,dis_G1G3,phi13,th1,th3);
phi12dd = phi12dd_EOM(dis_G1G2,dis_G1G3,disd_G1G2,phi12,phi13,phi12d,th1,th2,th3);
phi13dd = phi13dd_EOM(dis_G1G2,dis_G1G3,disd_G1G3,phi12,phi13,phi12d,th1,th2,th3);
disdd_G1G2 = disdd_G1G2_EOM(dis_G1G2,dis_G1G3,phi12,phi13,phi12d,th1,th2,th3);
disdd_G1G3 = disdd_G1G3_EOM(dis_G1G2,dis_G1G3,phi12,phi13,phi13d,th1,th2,th3);
x1dd = xdd_G1_EOM(dis_G1G2,dis_G1G3,phi12,phi13,th1,th2,th3);
y1dd = ydd_G1_EOM(dis_G1G2,dis_G1G3,phi12,phi13,th1,th2,th3);

xdot = [th1d th1dd, th2d th2dd, th3d th3dd, phi12d phi12dd, ...
    phi13d phi13dd, disd_G1G2 disdd_G1G2 disd_G1G3 disdd_G1G3, x1d x1dd, y1d y1dd]';

end

