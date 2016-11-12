function Spinning2DAnimate(t , z, param, timeX, filming, withPlots)
close all;
%
if withPlots
    Spinning2DPlot(t,z,1);
end
%% Coordinate conversion
% z = [th1 th1d, th2 th2d, th3 th3d, phi12 phi12d, phi13 phi13d, ...
%     dis_G1G2 disd_G1G2 dis_G1G3 disd_G1G3, x1 x1d, y1 y1d];
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
x1 = z(:,15);
x1d = z(:,16);
y1 = z(:,17);
y1d = z(:,18);

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
r_G1F = [x1 y1 zeros(size(x1))];
r_G2F = r_G1G2 + r_G1F;
r_G3F = r_G1G3 + r_G1F;

%% Plot Body Traces
figure; hold on;
% fig.Position(3) = fig.Position(3)*2;
% subplot(1,2,1);
plot(r_G1F(:,1), r_G1F(:,2), '--k');
plot(r_G1F(end,1), r_G1F(end,2), 'ok');
plot(r_G1F(1,1), r_G1F(1,2), '*k');

plot(r_G2F(:,1), r_G2F(:,2), '--k');
plot(r_G2F(end,1), r_G2F(end,2), 'ok');
plot(r_G2F(1,1), r_G2F(1,2), '*k');

plot(r_G3F(:,1), r_G3F(:,2), '--k');
plot(r_G3F(end,1), r_G3F(end,2), 'ok');
plot(r_G3F(1,1), r_G3F(1,2), '*k');
title(['Three Body Tethered Simulation, Xspeed=',num2str(timeX)]);
shg;

%% Line Objects
r_T2 = r_G2F+r_G2T2;
r_T12 = r_G1F+r_G1T12;
tether_2_to_1 = line([r_T2(1,1) r_T12(1,1)],[r_T2(1,2) r_T12(1,2)]);
r_T3 = r_G3F+r_G3T3;
r_T13 = r_G1F+r_G1T13;
tether_3_to_1 = line([r_T3(1,1) r_T13(1,1)],[r_T3(1,2) r_T13(1,2)]);

%% Box Objects
xverts1 = [-param.d_G1T12, param.d_G1T12, param.d_G1T12, -param.d_G1T12];
yverts1 = [param.d_width, param.d_width, -param.d_width, -param.d_width]/2;
s1 = patch(xverts1,yverts1,'r');
xverts2 = [-param.d_G2T2, param.d_G2T2, param.d_G2T2, -param.d_G2T2];
yverts2 = [param.d_width, param.d_width, -param.d_width, -param.d_width]/2;
s2 = patch(xverts2,yverts2,'b');
xverts3 = [-param.d_G3T3, param.d_G3T3, param.d_G3T3, -param.d_G3T3];
yverts3 = [param.d_width, param.d_width, -param.d_width, -param.d_width]/2;
s3 = patch(xverts3,yverts3,'g');

oV1 = s1.Vertices;
oV2 = s2.Vertices;
oV3 = s3.Vertices;

%% Animate
currTime = 0;
dim = [.69 0 .3 .24];
str = ['time = ',num2str(currTime)];
anno1 = annotation('textbox',dim,'String',str,'FitBoxToText','on');
dim = [.55 0 .3 .175];
str = ['Rotation Rate = ',num2str(0)];
anno2 = annotation('textbox',dim,'String',str,'FitBoxToText','on');

if filming
    vwr = VideoWriter('2D Animation.avi');
    open(vwr);
end
axis([-1 1 -1 1]*1.5);
axis square;
tic;

while currTime*timeX < t(end)
    cTx = currTime*timeX;
        
    x1 = interp1(t,r_G1F(:,1),cTx);
    y1 = interp1(t,r_G1F(:,2),cTx);
    x2 = interp1(t,r_G2F(:,1),cTx);
    y2 = interp1(t,r_G2F(:,2),cTx);
    x3 = interp1(t,r_G3F(:,1),cTx);
    y3 = interp1(t,r_G3F(:,2),cTx);
    
    th1i = interp1(t,th1,cTx);
    th2i = interp1(t,th2,cTx);
    th3i = interp1(t,th3,cTx);
    
    rotation1 = [cos(th1i),-sin(th1i); sin(th1i),cos(th1i)];
    rotation2 = [cos(th2i),-sin(th2i); sin(th2i),cos(th2i)];
    rotation3 = [cos(th3i),-sin(th3i); sin(th3i),cos(th3i)];
    
    rot1 = (rotation1*oV1')';
    rot2 = (rotation2*oV2')';
    rot3 = (rotation3*oV3')';
    
    s1.Vertices = [rot1(:,1) + x1 , rot1(:,2) + y1];
    s2.Vertices = [rot2(:,1) + x2 , rot2(:,2) + y2];
    s3.Vertices = [rot3(:,1) + x3 , rot3(:,2) + y3];
    
    xt12 = interp1(t,r_T12(:,1),cTx);
    yt12 = interp1(t,r_T12(:,2),cTx);
    xt13 = interp1(t,r_T13(:,1),cTx);
    yt13 = interp1(t,r_T13(:,2),cTx);
    xt2 = interp1(t,r_T2(:,1),cTx);
    yt2 = interp1(t,r_T2(:,2),cTx);
    xt3 = interp1(t,r_T3(:,1),cTx);
    yt3 = interp1(t,r_T3(:,2),cTx);
    
    tether_2_to_1.XData = [xt2 , xt12];
    tether_2_to_1.YData = [yt2 , yt12];
    tether_3_to_1.XData = [xt3 , xt13];
    tether_3_to_1.YData = [yt3 , yt13];
    
    anno1.String = ['time = ',num2str(cTx,'%.2f'),' sec'];
    
    phi12di = interp1(t,phi12d,cTx);
    phi13di = interp1(t,phi13d,cTx);
    anno2.String = ['Rotation Rate = ', ...
        num2str((phi12di+phi13di)*0.5,'%.3f'),' rad/sec'];
    
    drawnow;
    currTime = toc;
    
    if filming
        writeVideo(vwr,getframe(gcf));        
    end
end

end