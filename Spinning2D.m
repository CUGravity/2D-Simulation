function [tarray , zarr , params] = Spinning2D(tf)
close all;
%%
tic;
params.m = 1.33; %kg
params.r = 0.05; %meters
params.I = params.m*(2*(2*params.r)^2)/12; %kg*m*m (10cm x 10cm)
params.L12 = 1; %meters
params.L13 = 1; %meters
params.k12 = 10; %Newtons/meter
params.k13 = 10; %Newtons/meter
% params.d12 = 0.1; %Newtons/meter
% params.d13 = 0.1; %Newtons/meter

params.kp1 = 0.1;
params.wtari = 0.1;
params.wtarf = 0.2;
params.ti = tf/1;
params.tf = tf*1/1;
params.kp2 = -0.001;

%x=[rx1 ry1 vx1 vy1 th1 w1, rx2 ry2 vx2 vy2 th2 w2, rx3 ry3 vx3 vy3 th3 w3]
x_i = [0 0 0 0 0 0, 0.9 0 0 0.1 0 0, -0.9 0 0 -0.1 0 0]';

% tf = 10;
tspan=linspace(0,tf,tf*1000);
opts = odeset('RelTol',3e-14,'AbsTol',1e-18);
[tarray, zarr] = ode45(@RHS, tspan, x_i, opts, params);

disp(['Sim Completed in: ',num2str(toc),' seconds']);

end

function xdot = RHS(t,x,params)

an = anchorPos(x,params);
d12 = sqrt((an.x12-an.x2)^2 + (an.y12-an.y2)^2);
d13 = sqrt((an.x13-an.x3)^2 + (an.y13-an.y3)^2);

if d12 >= params.L12
    F_12_mag = params.k12*(d12 - params.L12);
else
    F_12_mag = 0;
end
if d13 >= params.L13
    F_13_mag = params.k13*(d13 - params.L13);
else
    F_13_mag = 0;
end

% find COM to Anchors unit vectors for all four anchors
c_12 = [ an.x12-x(1) , an.y12-x(2) ]; c_hat_12 = c_12/norm(c_12);
c_13 = [ an.x13-x(1) , an.y13-x(2) ]; c_hat_13 = c_13/norm(c_13);
c_2  = [ an.x2-x(7) , an.y2-x(8) ];   c_hat_2  = c_2/norm(c_2);
c_3  = [ an.x3-x(13) , an.y3-x(14) ]; c_hat_3  = c_3/norm(c_3);

anch12 = [ an.x2-an.x12 , an.y2-an.y12 ];
F_12 = F_12_mag*anch12/norm(anch12);
F_2 = -F_12;
anch13 = [ an.x3-an.x13 , an.y3-an.y13 ];
F_13 = F_13_mag*anch13/norm(anch13);
F_3 = -F_13;

F_2_ll = c_hat_2*dot(F_2,c_hat_2);
F_2_perp = F_2 - F_2_ll;
M_2 = params.r*cross([c_hat_2 0], [F_2_perp 0]);
F_3_ll = c_hat_3*dot(F_3,c_hat_3);
F_3_perp = F_3 - F_3_ll;
M_3 = params.r*cross([c_hat_3 0], [F_3_perp 0]);
F_12_ll = c_hat_12*dot(F_12,c_hat_12);
F_12_perp = F_12 - F_12_ll;
M_12 = params.r*cross([c_hat_12 0], [F_12_perp 0]);
F_13_ll = c_hat_13*dot(F_13,c_hat_13);
F_13_perp = F_13 - F_13_ll;
M_13 = params.r*cross([c_hat_13 0], [F_13_perp 0]);

%x=[rx1 ry1 vx1 vy1 th1 w1, rx2 ry2 vx2 vy2 th2 w2, rx3 ry3 vx3 vy3 th3 w3]
%xdot=[vx1 vy1 ax1 ay1 w1 wdot1, ... ]
vx1 = x(3); vy1 = x(4);
vx2 = x(9); vy2 = x(10);
vx3 = x(15); vy3 = x(16);
w1 = x(6); w2 = x(12); w3 = x(18);

a1 = (F_12_ll+F_13_ll)/params.m;
% a1 = 0*a1;
a2 = F_2_ll/params.m;
a3 = F_3_ll/params.m;

%% Torquer at center
wTarget = params.wtari + ...
    (t-params.ti)*(params.wtarf-params.wtari)/(params.tf-params.ti);
if t < params.ti
    wTarget = params.wtari;
end
if t > params.tf
    wTarget = params.wtarf;
end
TorqueC = params.kp1*(wTarget-w1);

if (x(1)-x(7)) < 0.01 && (x(1)-x(7)) > -0.01
    thTarget2 = atan( (x(2)-x(8)) / (x(1)-x(7)) );
else
    thTarget2 = sign((x(2)-x(8)))*pi/2;
end
Torque2 = params.kp2*(thTarget2-x(11));

if (x(1)-x(13)) < 0.01 && (x(1)-x(13)) > -0.01
    thTarget3 = atan( (x(2)-x(14)) / (x(1)-x(13)) );
else
    thTarget3 = sign((x(2)-x(14)))*pi/2;
end
Torque3 = params.kp2*(thTarget3-x(17));

wdot1 = (M_12(3)+M_13(3))/params.I + TorqueC/params.I;
wdot2 = M_2(3)/params.I + Torque2/params.I;
wdot3 = M_3(3)/params.I + Torque3/params.I;

xdot = [vx1 vy1 a1(1) a1(2) w1 wdot1, ...
    vx2 vy2 a2(1) a2(2) w2 wdot2, vx3 vy3 a3(1) a3(2) w3 wdot3]';

end

function anchors = anchorPos(x,params)
anchors.x13 = x(1) + params.r*cos(x(5));
anchors.y13 = x(2) + params.r*sin(x(5));

anchors.x12 = x(1) + params.r*cos(x(5) + pi);
anchors.y12 = x(2) + params.r*sin(x(5) + pi);

anchors.x2 = x(7) + params.r*cos(x(11));
anchors.y2 = x(8) + params.r*sin(x(11));

anchors.x3 = x(13) + params.r*cos(x(17));
anchors.y3 = x(14) + params.r*sin(x(17));
end

