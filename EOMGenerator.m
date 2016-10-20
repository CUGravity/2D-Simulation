function EOMGenerator

%% Constants
d_width = 0.1;
d_G2T2 = 0.025;
d_G3T3 = 0.025;
d_G1T12 = 0.1;
d_G1T13 = 0.1;
lo12 = 1; %rest length
lo13 = 1; %rest length
k = 1; %spring constant
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
syms phi12 phid12 phidd12 real; % measured from G1
syms phi13 phid13 phidd13 real;
syms dis_G1G2 disd_G1G2 disdd_G1G2 dis_G1G3 disd_G1G3 disdd_G1G3 real;

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

r_G2T2 = er_G2*d_G2T2;
r_G3T3 = -er_G3*d_G3T3;
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
FsT12T2 = k*(r_T12T2 - lo12)*hvs(r_T12T2 - lo12);
FsT2T12 = -FsT12T2;
FsT13T3 = k*(r_T13T3 - lo13)*hvs(r_T13T3 - lo13);
FsT3T13 = -FsT13T3;

%% AMB About F (fixed frame)
M_F = [0 0 0];

H_1F = cross( r_G1F , m1*a_G1F ) + I_G1*th1d*k;
H_2F = cross( r_G2F , m1*a_G2F ) + I_G1*th1d*k;
H_3F = cross( r_G3F , m1*a_G3F ) + I_G1*th1d*k;
H_F = H_1F + H_2F + H_3F;

eqn1 = M_F == H_F;

%% AMB of 1 About G1



end

function Heaviside = hvs(x)
% negative heaviside actually
x = norm(x);
k = 10000;
Heaviside = 1/(1 + exp(-2*k*x));

end

