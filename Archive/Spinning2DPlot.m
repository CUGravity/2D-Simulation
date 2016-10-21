function Spinning2DPlot(t , z)
close all;

figure;
plot(t,z(:,[6 12 18]));
title('Rotation Rates All');

% figure;
% plot(t,z(:,6));
% title('Rotation Rate Center');

% n = 100000;
% ave18 = conv(z(:,18), ones(2*n+1,1)/(2*n+1), 'same');
% ave12 = conv(z(:,12), ones(2*n+1,1)/(2*n+1), 'same');
% figure;
% plot(t,ave12,t,ave18);
% title('Moving average of rotation rates, Sides');

n = 50000;
helper = ones(1,n);
fil18 = filter( helper , 1 , z(:,18)/n);
fil12 = filter( helper , 1 , z(:,12)/n);
figure;
plot(t,fil12,t,fil18);
title('Filtered of rotation rates, Sides');

figure;
n = 500;
helper = ones(1,n);
fil6 = filter( helper , 1 , z(:,6)/n);
plot(t,fil6);
title('Filtered Rotation Rate Center');

end