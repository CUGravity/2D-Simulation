close all;
%% Generate EOMs and add them to the path
tend = 10;
needToGenEOMs = 1;

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

%% Simulink
tic;
x_i = [0 0, 0 0, 0 0, pi .1, 0 .1, ...
    param.lo12+param.d_G1T12 0 param.lo13+param.d_G1T13 0, 0 0, 0 0]'; % NULL
u_i = [ 0 0 0 ]';
sim('extRHS');

disp(['ode45 took ',num2str(toc),' seconds to run']);
