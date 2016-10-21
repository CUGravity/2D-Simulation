function EOMEqualibriumSearch

syms th1 th2 th3 real;
syms dis_G1G2 dis_G1G3 real;
syms coil1 coil2 coil3 real;

w = 1;
phi12 = pi;
phi13 = 0;
phi12dd = phi12dd_EOM(dis_G1G2,0,phi12,w,th1,th2);
phi13dd = phi13dd_EOM(dis_G1G3,0,phi13,w,th1,th3);
th1dd = th1dd_EOM(coil1,dis_G1G2,dis_G1G3,phi12,phi13,th1,th2,th3);
th2dd = th2dd_EOM(coil2,dis_G1G2,phi12,th1,th2);
th3dd = th3dd_EOM(coil3,dis_G1G3,phi13,th1,th3);
disdd_G1G2 = disdd_G1G2_EOM(dis_G1G2,phi12,w,th1,th2);
disdd_G1G3 = disdd_G1G3_EOM(dis_G1G3,phi13,w,th1,th3);

solve([dphi12dd == 0, phi13dd == 0, th1dd == 0, th2dd == 0, ...
    th3dd == 0, isdd_G1G2 == 0, disdd_G1G3 == 0]);

end

