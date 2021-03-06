function EOMGenerator(param)
%Rerun this script anytime a change needs to be made to any of the
%variables listed in the "Constants" section so that they get captured in
%the EOM files. 
% Contact - Douglas Kaiser (dtk42@cornell.edu)
tic;
%% Constants
%Anthing known to be unchanged in each run in the future. I.e. this will
%have to be restructed upon any Monte Carlo analysis.

%Replaced with param struct

%% Symbolic variables
%Anything wanted as an input or output to these EOM files needs to be
%defined and used symbolically.
syms x_G1 xd_G1 xdd_G1 y_G1 yd_G1 ydd_G1 real;
syms th1 th1d th1dd real;
syms th2 th2d th2dd real;
syms th3 th3d th3dd real;
syms phi12 phi12d phi12dd real; % measured from G1
syms phi13 phi13d phi13dd real;
syms dis_G1G2 disd_G1G2 disdd_G1G2 dis_G1G3 disd_G1G3 disdd_G1G3 real;
syms coil1 coil2 coil3 real;
syms Lo12 Lo13 real; % rest length of tether
syms Ldamp12 Ldamp13 real; % length of spring-dashpot attached between tether and end-sats
syms Ldamp12d Ldamp13d real; % derivative of spring-dashpot
syms Rdamp_w1 Rdamp_w2 Rdamp_w3 real;
syms Rdamp_w1d Rdamp_w2d Rdamp_w3d real;

%% Basis vectors
%Define system axis. Everything at the end is in Cartesian though local
%polar coordinates can be used as defined below.
i = [1 0 0]; j = [0 1 0]; k = [0 0 1];
er_G1 = [cos(th1) sin(th1) 0]; et_G1 = [-sin(th1) cos(th1) 0];
er_G2 = [cos(th2) sin(th2) 0]; et_G2 = [-sin(th2) cos(th2) 0];
er_G3 = [cos(th3) sin(th3) 0]; et_G3 = [-sin(th3) cos(th3) 0];

er_G1G2 = [cos(phi12) sin(phi12) 0];
er_G2G1 = -er_G1G2;
et_G1G2 = [-sin(phi12) cos(phi12) 0];
et_G2G1 = -et_G1G2;
er_G1G3 = [cos(phi13) sin(phi13) 0];
er_G3G1 = -er_G1G3;
et_G1G3 = [-sin(phi13) cos(phi13) 0];
et_G3G1 = -et_G1G3;

r_G2G1  = dis_G1G2*er_G2G1;
r_G3G1  = dis_G1G3*er_G3G1;
r_G1G1 = [0 0 0];
r_G2G2 = [0 0 0];
r_G3G3 = [0 0 0];

r_G2T2 = er_G2*param.d_G2T2;
r_T2G2 = -r_G2T2;
r_G3T3 = -er_G3*param.d_G3T3;
r_T3G3 = -r_G3T3;
r_G1T12 = -er_G1*param.d_G1T12;
r_G1T13 = er_G1*param.d_G1T13;

r_G1G2 = -r_G2G1;
r_T12G1 = -r_G1T12;
r_T12T2 = r_T12G1 + r_G1G2 + r_G2T2;
r_T2T12 = -r_T12T2;

r_G1G3 = -r_G3G1;
r_T13G1 = -r_G1T13;
r_T13T3 = r_T13G1 + r_G1G3 + r_G3T3;
r_T3T13 = -r_T13T3;

r_G1F = [x_G1 y_G1 0];
r_G2F = r_G1G2 + r_G1F;
r_G3F = r_G1G3 + r_G1F;

%% Kinematics
%Here is the main advantage of using polar coordinates; the kinematics of
%the accelerations are easily defined.
a_G1F = [xdd_G1 ydd_G1 0];
a_G1G2 = (disdd_G1G2 - dis_G1G2*phi12d^2)*er_G1G2 + ...
    (dis_G1G2*phi12dd + 2*disd_G1G2*phi12d)*et_G1G2;
a_G2F = a_G1G2 + a_G1F;

a_G1G3 = (disdd_G1G3 - dis_G1G3*phi13d^2)*er_G1G3 + ...
    (dis_G1G3*phi13dd + 2*disd_G1G3*phi12d)*et_G1G3;
a_G3F = a_G1G3 + a_G1F;

%% Spring Forces
% first calculate length of tethers
L12 = norm(r_T12T2)-Ldamp12;
L13 = norm(r_T13T3)-Ldamp13;
% second calculate tension of tether
%The Heaviside function is how we model the tether only acting on one side
%of the rest length while maintaining a continuous function with no
%logical/binary statements.
tension12 = param.tethEA*(L12/Lo12-1)*heaviside(L12-Lo12);
tension13 = param.tethEA*(L13/Lo13-1)*heaviside(L13-Lo13);
% third calculate the forces on the tension connections
F_T2_on_T12 = tension12*r_T12T2/norm(r_T12T2);
F_T3_on_T13 = tension13*r_T13T3/norm(r_T13T3);
F_T12_on_T2 = -F_T2_on_T12;
F_T13_on_T3 = -F_T3_on_T13;
% fourth calculate the change in length of the damper
% note: tension = k*length + c*length_dot
% also note: the tension in the damper must equal the tension in the tether
Ldamp12d = (tension12 - param.lindamp_k*Ldamp12)/param.lindamp_c;
Ldamp13d = (tension13 - param.lindamp_k*Ldamp13)/param.lindamp_c;

%% Rotational damping torques
rotdamp_tau_1 = 16*pi^2*param.rotdamp_dyn_vis*param.rotdamp_majorR_1^3*(Rdamp_w1-th1d);
rotdamp_tau_2 = 16*pi^2*param.rotdamp_dyn_vis*param.rotdamp_majorR_2^3*(Rdamp_w2-th2d);
rotdamp_tau_3 = 16*pi^2*param.rotdamp_dyn_vis*param.rotdamp_majorR_2^3*(Rdamp_w3-th3d);

%% Calculate angular acceleration of damping fluid
Rdamp_w1d = -8*param.rotdamp_kin_vis/param.rotdamp_minorR_1^2*(Rdamp_w1-th1d);
Rdamp_w2d = -8*param.rotdamp_kin_vis/param.rotdamp_minorR_2^2*(Rdamp_w2-th2d);
Rdamp_w3d = -8*param.rotdamp_kin_vis/param.rotdamp_minorR_2^2*(Rdamp_w3-th3d);

%% Torquers (plus the rotational damping torque)
tau_1 = coil1*k + rotdamp_tau_1;
tau_2 = coil2*k + rotdamp_tau_2;
tau_3 = coil3*k + rotdamp_tau_3;

%% AMB of System About G1 - TAKEN OUT B/C IT IS A NULL CASE
% M_G1 = tau_1 + tau_2 + tau_3;
% 
% H_1G1 = cross( r_G1G1 , m1*a_G1F ) + I_G1*th1d*k;
% H_2G1 = cross( r_G2G1 , m2*a_G2F ) + I_G2*phi12d*k;
% H_3G1 = cross( r_G3G1 , m3*a_G3F ) + I_G3*phi13d*k;
% H_G1 = H_1G1 + H_2G1 + H_3G1;
% 
% eqn1 = M_G1 == H_G1;

%% AMB of 1 About G1
M_T12_about_G1 = cross( r_G1T12 , F_T2_on_T12 );
M_T13_about_G1 = cross( r_G1T13 , F_T3_on_T13 );
M_G1 = M_T12_about_G1 + M_T13_about_G1 + tau_1;
H_G1G1 = cross( r_G1G1 , param.m1*a_G1F ) + param.I_G1*th1dd*k;
H_G1 = H_G1G1;
eqn2 = M_G1 == H_G1;

%% AMB of 2 About G2
M_T2_about_G2 = cross( r_G2T2 , F_T12_on_T2 );
M_G2 = M_T2_about_G2 + tau_2;
H_G2G2 = cross( r_G2G2 , param.m2*a_G2F ) + param.I_G2*th2dd*k;
H_G2 = H_G2G2;
eqn3 = M_G2 == H_G2;

%% AMB of 2 About G2
M_T3_about_G3 = cross( r_G3T3 , F_T13_on_T3 );
M_G3 = M_T3_about_G3 + tau_3;
H_G3G3 = cross( r_G3G3 , param.m3*a_G3F ) + param.I_G3*th3dd*k;
H_G3 = H_G3G3;
eqn4 = M_G3 == H_G3;

%% LMB about 1
F_t1 = F_T2_on_T12 + F_T3_on_T13;
eqn5 = F_t1 == param.m1*a_G1F;

%% LMB about 2
F_t2 = F_T12_on_T2;
eqn6 = F_t2 == param.m2*a_G2F;

%% LMB about 3
F_t3 = F_T13_on_T3;
eqn7 = F_t3 == param.m3*a_G3F;

%% Solve EOM equations
%Collect the >useful< EOMs from the LMB and AMB equations we defined above
%then use MATLAB's powerful "solve" function to give us the variables we
%want as functions of the variables we have. Then we can generate those
%functions as function files for use in the ode45 we will implement later.
equations = [ eqn2(3) eqn3(3) eqn4(3) eqn5(1) eqn5(2) eqn6(1) eqn6(2) eqn7(1) eqn7(2)];
variables = [ xdd_G1 ydd_G1 th1dd th2dd th3dd phi12dd phi13dd disdd_G1G2 disdd_G1G3 ];

wid = 'symbolic:solve:SolutionsDependOnConditions';
warning('off',wid);
angleDD = solve( equations , variables );
warning('on',wid);

mkdir(pwd,'EOMs');
matlabFunction(angleDD.xdd_G1,'File','EOMs/xdd_G1_EOM');
matlabFunction(angleDD.ydd_G1,'File','EOMs/ydd_G1_EOM');
matlabFunction(angleDD.th1dd,'File','EOMs/th1dd_EOM');
matlabFunction(angleDD.th2dd,'File','EOMs/th2dd_EOM');
matlabFunction(angleDD.th3dd,'File','EOMs/th3dd_EOM');
matlabFunction(angleDD.phi12dd,'File','EOMs/phi12dd_EOM');
matlabFunction(angleDD.phi13dd,'File','EOMs/phi13dd_EOM');
matlabFunction(angleDD.disdd_G1G2,'File','EOMs/disdd_G1G2_EOM');
matlabFunction(angleDD.disdd_G1G3,'File','EOMs/disdd_G1G3_EOM');
matlabFunction(norm(F_T2_on_T12),'File','EOMs/F12_EOM');
matlabFunction(norm(F_T3_on_T13),'File','EOMs/F13_EOM');
matlabFunction(Ldamp12d,'File','EOMs/Ldamp12_EOM');
matlabFunction(Ldamp13d,'File','EOMs/Ldamp13_EOM');
matlabFunction(Rdamp_w1d,'File','EOMs/Rdamp_w1_EOM');
matlabFunction(Rdamp_w2d,'File','EOMs/Rdamp_w2_EOM');
matlabFunction(Rdamp_w3d,'File','EOMs/Rdamp_w2_EOM');
matlabFunction(angleDD.xdd_G1,angleDD.ydd_G1,angleDD.th1dd,...
    angleDD.th2dd,angleDD.th3dd,angleDD.phi12dd,angleDD.phi13dd,...
    angleDD.disdd_G1G2,angleDD.disdd_G1G3,...
    norm(F_T2_on_T12),norm(F_T3_on_T13),...
    Ldamp12d,Ldamp13d,Rdamp_w1d,Rdamp_w2d,Rdamp_w3d,...
    'File','EOMs/merged_EOM',...
    'Outputs',{'xdd_G1','ydd_G1','th1dd','th2dd','th3dd','phi12dd',...
    'phi13dd','disdd_G1G2','disdd_G1G3','F12','F13','Ldamp12d','Ldamp13d',...
    'Rdamp_w1d','Rdamp_w2d','Rdamp_w3d'});
addpath('EOMs');

%EQUIVALENT BUT DONE PIECE BY PIECE
% th1dd_sol = solve( eqn2(3) , th1dd );
% th2dd_sol = solve( eqn3(3) , th2dd );
% th3dd_sol = solve( eqn4(3) , th3dd );
% G2_sol = solve( [eqn6(1) eqn6(2)],[disdd_G1G2 phi12dd]);
% G3_sol = solve( [eqn7(1) eqn7(2)],[disdd_G1G3 phi13dd]);
% matlabFunction(G3_sol.disdd_G1G3,'File','disdd_G1G3');
% matlabFunction(G3_sol.phi13dd,'File','phi13dd');
% matlabFunction(G2_sol.disdd_G1G2,'File','disdd_G1G2');
% matlabFunction(G2_sol.phi12dd,'File','phi12dd');
% matlabFunction(th1dd_sol,'File','th1dd_sol');
% matlabFunction(th2dd_sol,'File','th2dd_sol');
% matlabFunction(th3dd_sol,'File','th3dd_sol');

disp(['EOM Generation took ',num2str(toc),' seconds to run']);
end
