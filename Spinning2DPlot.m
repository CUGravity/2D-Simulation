function Spinning2DPlot( t, z, param, down )
close all;
% x_i = [th1 th1d, th2 th2d, th3 th3d, phi12 phi12d, phi13 phi13d, ...
%     dis_G1G2 disd_G1G2 dis_G1G3 disd_G1G3, x1 x1d, y1 y1d];

figure;
plot(t,z(:,[8 10]));
title('System Rotation Rates');
legend('G2 about G1','G3 about G1');
if down
    movegui('southwest');
end

figure;
plot(t,z(:,[2 4 6]));
title('Body Rotation Rates');
legend('Body rate of 1','Body rate of 2','Body rate of 3');
if down
    movegui('south');
end

figure;
plot(t,z(:,[11 13]));
title('Body Distances');
legend('G1 to G2','G1 to G3');
if down
    movegui('southeast');
end

figure;
plot(t,z(:,[26 27]));
title('Tether Tension');
legend('T1 to T2','T1 to T3');
if down
    movegui('southeast');
end

figure;

subplot(3,2,1);
plot(t/60,z(:,end-3));
title('Tether Rest Length');
ylabel('[m]');
xlabel('Time [min]');

subplot(3,2,2);
% ang momentum about m1 = IG1*th1d + IG2*th2d + IG3*th3d + M2*ph12d + M3*phi13d
ang_momentum_about_m1 = param.I_G1*z(:,2) + param.I_G2*z(:,4) + param.I_G3*z(:,6) + param.m2*z(:,8) + param.m3*z(:,10);
plot(t/60,ang_momentum_about_m1);
title('Angular Momentum about Central Sat');
ylabel('[kg*m^2/s]');
xlabel('Time [min]');

subplot(3,2,3);
plot(t/60,z(:,[8 10]));
title('Rotation Rates about Central Sat');
%legend('Rate of G2 about G1','Rate of G3 about G1');
ylabel('[rad/s]');
xlabel('Time [min]');

subplot(3,2,4);
plot(t/60,z(:,[2 4 6]));
title('Body Rotation Rates');
legend('Body rate of 1','Body rate of 2','Body rate of 3');
ylabel('[rad/s]');
xlabel('Time [min]');

subplot(3,2,5);
plot(t/60,z(:,[11 13]));
title('Body Distances');
%legend('G1 to G2','G1 to G3');
ylabel('[m]');
xlabel('Time [min]');

subplot(3,2,6);
plot(t/60,z(:,end-1:end));
title('Tether Tension');
%legend('T1 to T2','T1 to T3');
ylabel('[N]');
xlabel('Time [min]');

end

