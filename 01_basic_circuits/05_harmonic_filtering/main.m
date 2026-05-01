%% Harmonic waveform generation
%% Signal generation
clear 
close all
clc

f1 = 60 ; % Fundamental Frequency
Ns = 128; % Number of samples per cycle
Ts = 1/(f1*Ns); % Sample frequency

%        H1     H2       H3      H4      H4      H6      H7
Am = [ 100.00  000.00  065.68  000.00  042.40  000.00  040.10 ...
       000.00  028.29  000.00  019.55  000.00  015.32  000.00 ...
       010.95  000.00  010.20  000.00  010.70  000.00  012.34 ...
       000.00  011.84  000.00  010.85  000.00  007.90  000.00 ...
       006.36  000.00  003.99];

Ph = [ 033.37  000.00 -070.65  000.00 -144.53  000.00  135.49 ...
       000.00  047.01  000.00 -021.39  000.00 -091.57  000.00 ...
       149.73  000.00  150.10  000.00  089.96  000.00  015.53 ...
       000.00 -063.76  000.00 -138.37  000.00  145.95  000.00 ...
       083.12  000.00 -115.23];

% create the signal data 
t = (0 : Ts :3*1/f1); % create a time vector
y = (zeros(1,length(t))); 
for k = 1:length(Am)    
    y = y + (Am(k)/Am(1) * sin(2*pi*k*f1*t + deg2rad(Ph(k))));
end

% Save the txt file with signal data
fid = fopen("data.txt","w","native","UTF-8");
for k = 1:length(t)
    fprintf(fid,"%.4f \t %.4f\n",t(k),y(k));
end
fclose(fid);

%% Signal Analysis

% Take the signal FFT
Y = fft(y); 
L = length(y); % Signal length
f = (1/(Ts*L) * (0:L/2));
Yf = abs(Y(1:(L/2+1))/L);
Yf(2:end-1) = 2*Yf(2:end-1); 

% Clear unecessary variables
clear Y k fid

% Plot the harmonic waveform
figure()
subplot(2,1,1)
plot(t,y,'LineWidth',1.1)
grid on
grid minor
set(gca,'FontSize',12)

subplot(2,1,2)
semilogx(f,20*log10(Yf))
grid on
grid minor
axis("tight")
set(gca,'FontSize',12)

%% Filter design

% First order filter elements 
Rx = 1e3;
Cx = 220e-9;

% Second order filter elements
Ry1 = 1e3;
Cy1 = 22e-9;
Ry2 = 10e3;
Cy2 = 22e-9;

% First order filter transfer function
GFO = tf([0 1],[Rx*Cx 1]);

% Sallen-key transfer function
K = 1; % static gain 
GSO = tf([0 K],[Ry1*Ry2*Cy1*Cy2 (Ry1*Cy1 + Ry2*Cy1 + Ry1*Cy2*(1-K)) 1]);

% Configure bode plot options
opts = bodeoptions;
opts.FreqUnits = 'Hz';
opts.Grid = 'on';
opts.Title.String = "Low Pass Filter";
opts.Title.FontSize = 12;

% Plot bode diagram
figure()
bodeplot(GFO,GSO,opts);
grid minor
legend({'1^{st} order','2^{nd} order'}, ...
        'FontSize',12,'Location','best')

%%