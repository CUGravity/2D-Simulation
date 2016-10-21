function Spinning2DPlot_EOMs( t,z )

close all;

% x_i = [th1 th1d, th2 th2d, th3 th3d, phi12 phi12d, phi13 phi13d, ...
%     dis_G1G2 disd_G1G2 dis_G1G3 disd_G1G3];

figure;
plot(t,z(:,[8 10]));
title('System Rotation Rates');
legend('G2 about G1','G3 about G1');

figure;
plot(t,z(:,[2 4 6]));
title('Body Rotation Rates');
legend('Body rate of 1','Body rate of 2','Body rate of 3');

% n = 50000;
% helper = ones(1,n);
% fil18 = filter( helper , 1 , z(:,18)/n);
% fil12 = filter( helper , 1 , z(:,12)/n);
% figure;
% plot(t,fil12,t,fil18);
% title('Filtered of rotation rates, Sides');
% 
% figure;
% n = 500;
% helper = ones(1,n);
% fil6 = filter( helper , 1 , z(:,6)/n);
% plot(t,fil6);
% title('Filtered Rotation Rate Center');

end

