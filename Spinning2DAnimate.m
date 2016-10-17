function Spinning2DAnimate(t , z, p, timeX)
close all;

figure; hold on;
shg;
plot(z(:,1), z(:,2), '--k');
plot(z(:,7), z(:,8), '--k');
plot(z(:,13), z(:,14), '--k');

xverts1 = [-p.r,p.r,p.r,-p.r];
yverts1 = [p.r,p.r,-p.r,-p.r];
s1 = patch(xverts1,yverts1,'r');
xverts2 = [-p.r,p.r,p.r,-p.r];
yverts2 = [p.r,p.r,-p.r,-p.r];
s2 = patch(xverts2,yverts2,'r');
xverts3 = [-p.r,p.r,p.r,-p.r];
yverts3 = [p.r,p.r,-p.r,-p.r];
s3 = patch(xverts3,yverts3,'r');

oV1 = s1.Vertices;
oV2 = s2.Vertices;
oV3 = s3.Vertices;

currTime = 0;

title(['Three Body Tethered Simulation, Xspeed=',num2str(timeX)]);

tic; 
while currTime < t(end)
    th1 = interp1(t,z(:,5),currTime*timeX);
    rotation1 = [cos(th1),-sin(th1); sin(th1),cos(th1)];
    th2 = interp1(t,z(:,11),currTime*timeX);
    rotation2 = [cos(th2),-sin(th2); sin(th2),cos(th2)];
    th3 = interp1(t,z(:,17),currTime*timeX);
    rotation3 = [cos(th3),-sin(th3); sin(th3),cos(th3)];
    
    rx1 = interp1(t,z(:,1),currTime*timeX);
    ry1 = interp1(t,z(:,2),currTime*timeX);
    rx2 = interp1(t,z(:,7),currTime*timeX);
    ry2 = interp1(t,z(:,8),currTime*timeX);
    rx3 = interp1(t,z(:,13),currTime*timeX);
    ry3 = interp1(t,z(:,14),currTime*timeX);
    
    margin = p.L12*1.1;
    
%     [-params.L12+rx1-margin params.L12+rx1+margin ...
%         -params.L12+ry1-margin params.L12+ry1+margin]
    
    axis([-p.L12+rx1-margin p.L12+rx1+margin ...
        -p.L12+ry1-margin p.L12+ry1+margin])
    
    rot1 = (rotation1*oV1')';
    rot2 = (rotation2*oV2')';
    rot3 = (rotation3*oV3')';
    
    s1.Vertices = [rot1(:,1) + rx1 , rot1(:,2) + ry1];
    s2.Vertices = [rot2(:,1) + rx2 , rot2(:,2) + ry2];
    s3.Vertices = [rot3(:,1) + rx3 , rot3(:,2) + ry3];
    
    drawnow;
    
    currTime = toc;
end

end