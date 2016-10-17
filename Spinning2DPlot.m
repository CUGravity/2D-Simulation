function Spinning2DPlot(t , z)
close all;

figure;
plot(t,z(:,[6 12 18]));
title('Rotation Rates All');

figure;
plot(t,z(:,6));
title('Rotation Rate Center');

n = 10;
ave18 = conv(z(:,18), ones(2*n+1,1)/(2*n+1), 'same');
ave12 = conv(z(:,12), ones(2*n+1,1)/(2*n+1), 'same');
figure;
plot(t,ave12,t,ave18);
title('Moving average of rotation rates, Sides');

end