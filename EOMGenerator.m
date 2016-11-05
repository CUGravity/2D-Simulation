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
%The Heaviside function is how we model the tether only acting on one side
%of the rest length while maintaining a continuous function with no
%logical/binary statements.
F_T2_on_T12 = param.ks*r_T12T2*(1 - param.lo12/norm(r_T12T2))*...
    heaviside(norm(r_T12T2)-param.lo12);
F_T12_on_T2 = -F_T2_on_T12;
F_T3_on_T13 = param.ks*r_T13T3*(1 - param.lo13/norm(r_T13T3))*...
    heaviside(norm(r_T13T3)-param.lo13);
F_T13_on_T3 = -F_T3_on_T13;

%% Torquers
tau_1 = coil1*k;
tau_2 = coil2*k;
tau_3 = coil3*k;

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
