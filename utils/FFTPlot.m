
%Creat a sample signal
Fs = 10000;                    % Sampling frequency
T = 1/Fs;                     % Sample time
L = 362;                     % Length of signal
t = (0:L-1)*T;                % Time vector
% Sum of a 50 Hz sinusoid and a 120 Hz sinusoid
%x = 0.7*sin(2*pi*50*t) + sin(2*pi*120*t); 
y = FFTx(:,2) ; %+ 2*randn(size(t));     % Sinusoids plus noise
%plot(Fs*t(1:50),y(1:50))
plot(Fs*t,y);
title('Signal Corrupted with Zero-Mean Random Noise')
xlabel('time (milliseconds)')

NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(y,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);

%Plot single-sided amplitude spectrum.
plot(f,2*abs(Y(1:NFFT/2+1))) 
title('Single-Sided Amplitude Spectrum of y(t)')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')