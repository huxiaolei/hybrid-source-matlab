%PiConCal(wc,Kforward), wc is the cross freq, Kforward is the open loop
%Forward Gain.
%PiConCal(wc,Ls,Vdc), Ls is the inductance of the inductor Vdc is the
%Dc-link voltage.
%General case, Specify the forward value
function [Kp,Ki,Kc] = polesPlacement(Ts,zeta,L,C)
    wn = 4/(zeta*Ts) ;
    w1 = 10*wn ;
    
    Kc = (w1+2*zeta*wn)*L;
    Kp = ((2*zeta*wn*w1+wn^2)*L*C)/Kc ;
    Ki = (wn^2*w1)*L*C/Kc ;

end

