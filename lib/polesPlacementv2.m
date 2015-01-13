%PiConCal(wc,Kforward), wc is the cross freq, Kforward is the open loop
%Forward Gain.
%PiConCal(wc,Ls,Vdc), Ls is the inductance of the inductor Vdc is the
%Dc-link voltage.
%General case, Specify the forward value
function [Kp,Ki,Kc,wc] = polesPlacementv2(PM,fs,k,L,C)
    
    PMw = PM*pi/180 ;
    beta = atan((1-k)/(2*sqrt(k)))-PMw ;
    beta = beta*fs/sqrt(k) ;
    wc = sqrt(k)*beta ;
    
    Kc = L*beta/360 ;
    Kp = (L*C*sqrt(k)*beta^2)/(Kc*360) ;
    Ki = k*beta*Kp;

end

