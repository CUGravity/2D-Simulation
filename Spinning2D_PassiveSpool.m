function [tarray , zarr_extra , param] = Spinning2D_PassiveSpool(tf,needToGenEOMs)
close all;
%% Generate EOMs and add them to the path

param.d_width = 0.1;
param.d_length1 = 0.2;
param.d_G2T2 = 0.025;
param.d_G3T3 = 0.025;
% the center sat has a total length of 20cm,
% but tethers are anchored 5cm from ends
param.d_G1T12 = 0.05;
param.d_G1T13 = 0.05;
% Dyneema
tethE = 1.72e11; % 172000 MPa
tethA = pi*((5e-4)/2)^2; % diameter = 0.5mm
param.tethEA = tethE*tethA;
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
opts = odeset('RelTol',1e-10,'AbsTol',1e-10);
% x_i = [th1 th1d, th2 th2d, th3 th3d, phi12 phi12d, phi13 phi13d, ...
%     dis_G1G2 disd_G1G2 dis_G1G3 disd_G1G3, x1 x1d, y1 y1d, Lo12, Lo13];
x_i = [0 .1, 0 .1, 0 .1, pi .1, 0 .1, ...
    1+param.d_G1T12+param.d_G2T2 0 1+param.d_G1T13+param.d_G3T3 0, 0 0, 0 0, 1, 1]; % NULL
tspan=linspace(0,tf,tf*1000);
[tarray, zarr] = ode45(@RHS, tspan, x_i, opts, odeP);

zarr_extra = [zarr, zeros(numel(tarray),2)];
for a = 1:numel(tarray)
    [~, F12, F13] = RHS(tarray(a),zarr(a,:),odeP);
    zarr_extra(a,end-1:end) = [F12, F13];
end

disp(['ode45 took ',num2str(toc),' seconds to run']);
end

function [xdot, F12, F13] = RHS(t,x,odeP)
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
Lo12 = x(19);
Lo13 = x(20);

% wtarget = odeP.wti + t*(odeP.wtf-odeP.wti)/odeP.tfin;
wtarget = odeP.wti +(odeP.wtf-odeP.wti)/(1+exp(-odeP.kramp*(t-odeP.tmid)));

%[coil1, coil2, coil3] = TorqueController1(x,odeP,wtarget);
coil1 = 1e-4;
coil2 = 0;
coil3 = 0;

[x1dd,y1dd,th1dd,th2dd,th3dd,phi12dd,phi13dd,disdd_G1G2,disdd_G1G3,F12,F13] = ...
    merged_EOM(Lo12,Lo13,coil1,coil2,coil3,dis_G1G2,dis_G1G3,disd_G1G2,...
    disd_G1G3,phi12,phi13,phi12d,phi13d,th1,th2,th3);

Lo12d = (0.2*F12-0.1*0.01)*heaviside(F12-0.01);
Lo13d = (0.2*F13-0.1*0.01)*heaviside(F13-0.01);

xdot = [th1d th1dd, th2d th2dd, th3d th3dd, phi12d phi12dd, ...
    phi13d phi13dd, disd_G1G2 disdd_G1G2 disd_G1G3 disdd_G1G3, x1d x1dd, y1d y1dd, Lo12d, Lo13d]';

end

