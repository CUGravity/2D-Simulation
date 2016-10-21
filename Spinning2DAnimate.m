function Spinning2DAnimate_EOMs(t , z, param, timeX, filming)
close all;

%% Coordinate conversion
% z = [th1 th1d, th2 th2d, th3 th3d, phi12 phi12d, phi13 phi13d, ...
%     dis_G1G2 disd_G1G2 dis_G1G3 disd_G1G3];
th1 = z(:,1);
th1d = z(:,2);
th2 = z(:,3);
th2d = z(:,4);
th3 = z(:,5);
th3d = z(:,6);
phi12 = z(:,7);
phi12d = z(:,8);
phi13 = z(:,9);
phi13d = z(:,10);
dis_G1G2 = z(:,11);
disd_G1G2 = z(:,12);
dis_G1G3 = z(:,13);
disd_G1G3 = z(:,14);

%% TAKEN FROM COORD FRAMES IN EOMGenerator
er_G1 = [cos(th1) sin(th1) 0*th1]; et_G1 = [-sin(th1) cos(th1) 0*th1];
er_G2 = [cos(th2) sin(th2) 0*th1]; et_G2 = [-sin(th2) cos(th2) 0*th1];
er_G3 = [cos(th3) sin(th3) 0*th1]; et_G3 = [-sin(th3) cos(th3) 0*th1];

er_G1G2 = [cos(phi12) sin(phi12) 0*th1];
er_G2G1 = -er_G1G2;
et_G1G2 = [-sin(phi12) cos(phi12) 0*th1];
et_G2G1 = -et_G1G2;
er_G1G3 = [cos(phi13) sin(phi13) 0*th1];
er_G3G1 = -er_G1G3;
et_G1G3 = [-sin(phi13) cos(phi13) 0*th1];
et_G3G1 = -et_G1G3;

r_G2G1  = bsxfun(@times,er_G2G1,dis_G1G2);%=dis_G1G2.*er_G2G1; row wise
r_G3G1  = bsxfun(@times,er_G3G1,dis_G1G3);%=dis_G1G3.*er_G3G1;
r_G1G1 = [0 0 0];
r_G2G2 = [0 0 0];
r_G3G3 = [0 0 0];

r_G2T2 = er_G2*param.d_G2T2;
r_T2G2 = -r_G2T2;
r_G3T3 = -er_G3*param.d_G3T3;
r_T3G3 = -r_G3T3;
r_G1T12 = -er_G1*param.d_G1T12;
r_G1T13 = er_G1*param.d_G1T13;

r_G1G2 = -r_G2G1;
r_T12G1 = -r_G1T12;
r_T12T2 = r_T12G1 + r_G1G2 + r_G2T2;
r_T2T12 = -r_T12T2;

r_G1G3 = -r_G3G1;
r_T13G1 = -r_G1T13;
r_T13T3 = r_T13G1 + r_G1G3 + r_G3T3;
r_T3T13 = -r_T13T3;

%THESE ARE THE ONES WE WANT TO BE PLOTTING
r_G1F = zeros(length(th1),3);%=[0 0 0];
r_G2F = r_G1G2 + r_G1F;
r_G3F = r_G1G3 + r_G1F;

%% Plot Body Traces
figure; hold on;
plot(r_G1F(:,1), r_G2F(:,2), '--k');
plot(r_G2F(end,1), r_G2F(end,2), 'ok');
plot(r_G2F(:,1), r_G2F(:,2), '--k');
plot(r_G2F(end,1), r_G2F(end,2), 'ok');
plot(r_G2F(1,1), r_G2F(1,2), '*k');
plot(r_G3F(:,1), r_G3F(:,2), '--k');
plot(r_G3F(end,1), r_G3F(end,2), 'ok');
plot(r_G3F(1,1), r_G3F(1,2), '*k');
title(['Three Body Tethered Simulation, Xspeed=',num2str(timeX)]);
shg;

%% Box Objects
xverts1 = [-param.d_G1T12, param.d_G1T12, param.d_G1T12, -param.d_G1T12];
yverts1 = [param.d_width, param.d_width, -param.d_width, -param.d_width];
s1 = patch(xverts1,yverts1,'r');
xverts2 = [-param.d_G2T2, param.d_G2T2, param.d_G2T2, -param.d_G2T2];
yverts2 = [param.d_width, param.d_width, -param.d_width, -param.d_width];
s2 = patch(xverts2,yverts2,'b');
xverts3 = [-param.d_G3T3, param.d_G3T3, param.d_G3T3, -param.d_G3T3];
yverts3 = [param.d_width, param.d_width, -param.d_width, -param.d_width];
s3 = patch(xverts3,yverts3,'g');

oV1 = s1.Vertices;
oV2 = s2.Vertices;
oV3 = s3.Vertices;

%% Animate
currTime = 0;
if filming
    vwr = VideoWriter('2D Animation.avi');
    open(vwr);
end
axis([-param.lo12 param.lo12 -param.lo12 param.lo12]*1.5);
ind = 1;
tic;
while currTime < t(end)
    
    x1 = interp1(t,r_G1F(:,1),currTime*timeX);
    y1 = interp1(t,r_G1F(:,2),currTime*timeX);
    x2 = interp1(t,r_G2F(:,1),currTime*timeX);
    y2 = interp1(t,r_G2F(:,2),currTime*timeX);
    x3 = interp1(t,r_G3F(:,1),currTime*timeX);
    y3 = interp1(t,r_G3F(:,2),currTime*timeX);
       
    th1i = interp1(t,th1,currTime*timeX);
    th2i = interp1(t,th2,currTime*timeX);
    th3i = interp1(t,th3,currTime*timeX);
    
    rotation1 = [cos(th1i),-sin(th1i); sin(th1i),cos(th1i)];
    rotation2 = [cos(th2i),-sin(th2i); sin(th2i),cos(th2i)];
    rotation3 = [cos(th3i),-sin(th3i); sin(th3i),cos(th3i)];
    
    rot1 = (rotation1*oV1')';
    rot2 = (rotation2*oV2')';
    rot3 = (rotation3*oV3')';
    
    s1.Vertices = [rot1(:,1) + x1 , rot1(:,2) + y1];
    s2.Vertices = [rot2(:,1) + x2 , rot2(:,2) + y2];
    s3.Vertices = [rot3(:,1) + x3 , rot3(:,2) + y3];
    
    drawnow;
    currTime = toc;
    
    if filming
        writeVideo(vwr,getframe(gcf));        
    end
end

end