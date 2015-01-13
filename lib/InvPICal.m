function [ Kp,Ki,Kc ] = InvPICal(PM,fs,Vdc,L,C )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%define Phase Margin
PMw = PM*pi/180 ;
ws = 2*pi*fs;

%firstly, shape the inner loop

%consider a PM of 70degree in the inner loop. then cross frequency can be
%calculated by
wc = (pi/2-PMw)*ws/pi ;

Kc = L*wc/Vdc ;

%PI is based on Parallel structure Kp+Ki/s = Kp(s+Ki/Kp)/s

wcv = wc*0.8;

a = wcv/atan(PMw) ;

Kp = C*wcv^2/sqrt(a^2+wcv^2) ;

Ki = Kp * a ;

end

