%PiConCal(wc,Kforward), wc is the cross freq, Kforward is the open loop
%Forward Gain.
%PiConCal(wc,Ls,Vdc), Ls is the inductance of the inductor Vdc is the
%Dc-link voltage.
%General case, Specify the forward value
function [Kp,Ki] = PiConCal(wc,varargin)
if(nargin<=1||nargin>=4)
    error('You should put in two paramaters at least!');
elseif(nargin==2)
    [Kp,Ki] = PiCal(wc,varargin{1});
elseif(nargin==3)
    %first Ls, then, Vdc
    [Kp,Ki] = PiCal(wc,varargin{1}/varargin{2});
end
end

%Particular for DC/DC case with Specific inductor and Dc-link Voltage
function [Kp,Ki] = PiCal(wc,Kforward)
Kic = 10000/wc;
Kpc = (wc^2)/(Kforward*abs(Kic*wc*1i+1));
Ki = Kpc;
Kp = Kic*Kpc;
end