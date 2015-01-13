%PiConCal(wc,Kforward), wc is the cross freq, Kforward is the open loop
%Forward Gain.
%PiConCal(wc,Ls,Vdc), Ls is the inductance of the inductor Vdc is the
%Dc-link voltage.
%General case, Specify the forward value
function [Kp,Ki,Kc] = polesPlacementv3(PM,fc,fs,Vdc,L,C)
    
    PMw = PM*pi/180 ;
    wc = fc*2*pi ;
    ws = fs*2*pi ;
    
    PMw+wc*pi/ws
    
    a = tan(PMw+wc*pi/ws) 
    
    Sk = sqrt(a^2+1)-a ;
    
    k = Sk^2 ;
    
    beta = wc/Sk ;
    
    Kc = L*beta/Vdc ;
    Kp = (L*C*sqrt(k)*beta^2)/(Kc*Vdc) ;
    Ki = k*beta*Kp;

end

