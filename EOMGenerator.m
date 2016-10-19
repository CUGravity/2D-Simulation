function EOMGenerator

%% Constants
d_G2T2 = 0.025;
d_G3T3 = 0.025;
d_G1T12 = 0.1;
d_G1T13 = 0.1;

%% Symbolic variables
syms th1 th1d th1dd real;
syms th2 th2d th2dd real;
syms th3 th3d th3dd real;
syms phi12 phid12 phidd12 real;
syms phi13 phid13 phidd13 real;
syms dG1G2 vG1G2 aG1G2 dG1G3 vG1G3 aG1G3 real;

%% Basis vectors
i = [1 0 0]; j = [0 1 0]; k = [0 0 1];
er_G1 = [cos(th1) sin(th1) 0]; et_G1 = [-sin(th1) cos(th1) 0];
er_G2 = [cos(th2) sin(th2) 0]; et_G2 = [-sin(th2) cos(th2) 0];
er_G3 = [cos(th3) sin(th3) 0]; et_G3 = [-sin(th3) cos(th3) 0];

er_G2G1 = [cos(phi2) sin(phi2) 0]; 
et_G2G1 = [-sin(phi2) cos(phi2) 0];
er_G3G1 = [cos(phi3) sin(phi3) 0]; 
et_G3G1 = [-sin(phi3) cos(phi3) 0];

r_G2G1  = dG1G2*er_G2G1;
r_G3G1  = dG1G3*er_G3G1;

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
end

