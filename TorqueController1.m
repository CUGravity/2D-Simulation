function [coil1, coil2, coil3] = TorqueController1(state, cparam,wtarget)
%Temp holder for the Torque Controller. 

% state = [th1 th1d, th2 th2d, th3 th3d, phi12 phi12d, phi13 phi13d, ...
%     dis_G1G2 disd_G1G2 dis_G1G3 disd_G1G3];
coil1 = cparam.kp1*(wtarget - state(2));

coil2 = cparam.kp2*(wtarget - state(4));

coil3 = cparam.kp3*(wtarget - state(6));

end

