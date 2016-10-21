function angleDD = EOMGenerator
tic;
%% Constants
d_width = 0.1;
d_G2T2 = 0.025;
d_G3T3 = 0.025;
d_G1T12 = 0.1;
d_G1T13 = 0.1;
lo12 = 1; %rest length
lo13 = 1; %rest length
ks = 1; %spring constant
m1 = 4*(2/3);
m2 = 4*(1/6);
m3 = 4*(1/6);
I_G1 = m1*((d_G1T13+d_G1T13)^2+d_width^2)/12;
I_G2 = m2*((2*d_G2T2)^2+d_width^2)/12;
I_G3 = m3*((2*d_G3T3)^2+d_width^2)/12;

%% Symbolic variables
syms th1 th1d th1dd real;
syms th2 th2d th2dd real;
syms th3 th3d th3dd real;
syms phi12 phi12d phi12dd real; % measured from G1
syms phi13 phi13d phi13dd real;
syms dis_G1G2 disd_G1G2 disdd_G1G2 dis_G1G3 disd_G1G3 disdd_G1G3 real;
syms coil1 coil2 coil3 real;

%% Basis vectors
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

r_G2T2 = er_G2*d_G2T2;
r_T2G2 = -r_G2T2;
r_G3T3 = -er_G3*d_G3T3;
r_T3G3 = -r_G3T3;
r_G1T12 = -er_G1*d_G1T12;
r_G1T13 = er_G1*d_G1T13;

r_G1G2 = -r_G2G1;
r_T12G1 = -r_G1T12;
r_T12T2 = r_T12G1 + r_G1G2 + r_G2T2;
r_T2T12 = -r_T12T2;

r_G1G3 = -r_G3G1;
r_T13G1 = -r_G1T13;
r_T13T3 = r_T13G1 + r_G1G3 + r_G3T3;
r_T3T13 = -r_T13T3;

r_G1F = [0 0 0];
r_G2F = r_G1G2 + r_G1F;
r_G3F = r_G1G3 + r_G1F;

%% Kinematics
a_G1F = [0 0 0];
a_G2G1 = (disdd_G1G2 - dis_G1G2*phi12d^2)*er_G1G2 + ...
    (dis_G1G2*phi12dd + 2*disd_G1G2*phi12d)*et_G1G2;
a_G2F = a_G2G1 + a_G1F;

a_G3G1 = (disdd_G1G3 - dis_G1G3*phi13d^2)*er_G1G3 + ...
    (dis_G1G3*phi13dd + 2*disd_G1G3*phi13d)*et_G1G3;
a_G3F = a_G3G1 + a_G1F;

%% Spring Forces
F_T12T2 = ks*r_T12T2*(norm(r_T12T2) - lo12)*hvs(norm(r_T12T2) , lo12);
F_T2T12 = -F_T12T2;
F_T13T3 = ks*r_T13T3*(norm(r_T13T3) - lo13)*hvs(norm(r_T13T3) , lo13);
F_T3T13 = -F_T13T3;

%% Torquers 
tau_1 = coil1*k;
tau_2 = coil2*k;
tau_3 = coil3*k;

%% AMB of System About G1
M_G1 = tau_1 + tau_2 + tau_3;

H_1G1 = cross( r_G1G1 , m1*a_G1F ) + I_G1*th1d*k;
H_2G1 = cross( r_G2G1 , m2*a_G2F ) + I_G2*phi12d*k;
H_3G1 = cross( r_G3G1 , m3*a_G3F ) + I_G3*phi13d*k;
H_G1 = H_1G1 + H_2G1 + H_3G1;

eqn1 = M_G1 == H_G1;

%% AMB of 1 About G1
M_T12G1 = cross( r_T12G1 , F_T12T2 );
M_T13G1 = cross( r_T13G1 , F_T13T3 );
M_G1 = M_T12G1 + M_T13G1 + tau_1;

H_G1G1 = cross( r_G1G1 , m1*a_G1F ) + I_G1*th1dd*k;
H_G1 = H_G1G1;

eqn2 = M_G1 == H_G1;

%% AMB of 2 About G2
M_T2G2 = cross( r_T2G2 , F_T2T12 );
M_G2 = M_T2G2 + tau_2;

H_G2G2 = cross( r_G2G2 , m2*a_G2F ) + I_G2*th2dd*k;
H_G2 = H_G2G2;

eqn3 = M_G2 == H_G2;

%% AMB of 3 About G3
M_T3G3 = cross( r_T3G3 , F_T3T13 );
M_G3 = M_T3G3 + tau_3;

H_G3G3 = cross( r_G3G3 , m3*a_G3F ) + I_G3*th3dd*k;
H_G3 = H_G3G3;

eqn4 = M_G3 == H_G3;

%% LMB about 1
F_t1 = F_T12T2 + F_T13T3;
eqn5 = F_t1 == m1*a_G1F;

%% LMB about 2
F_t2 = F_T2T12;
eqn6 = F_t2 == m2*a_G2F;

%% LMB about 3
F_t3 = F_T3T13;
eqn7 = F_t3 == m3*a_G3F;

%% Solve EOM equations

equations = [ eqn1(3) eqn2(3) eqn3(3) eqn4(3) eqn5(1) eqn5(2) eqn6(1) ...
    eqn6(2) eqn7(1) eqn7(2)];
variables = [ th1dd th2dd th3dd phi12dd phi13dd disdd_G1G2 disdd_G1G3 ];

angleDD = solve( equations , variables );

matlabFunction(eqn1,'File','test');

disp(['Script took ',num2str(toc),' seconds']);
end

function Heaviside = hvs(r,lo)
% negative heaviside actually
x = r - lo;
khv = 1000;
Heaviside = 1/(1 + exp(-2*khv*x));
end

