function Spinning2DPlot( t, z, down )
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
plot(t,z(:,[23 24]));
title('Tether Tension');
legend('T1 to T2','T1 to T3');
if down
    movegui('southeast');
end

end

