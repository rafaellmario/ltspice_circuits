%% Open .ac analysis
%%
clear 
close all
clc

f1 = 60 ; % Fundamental Frequency
Ns = 128; % Number of samples per cycle
Ts = 1/(f1*Ns); % Sample frequency

%     
   H1     H2       H3      H4      H4      H6      H7
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
t = (0 : Ts :3/f1); % create a time vector
y = (zeros(1,length(t))); 
for k = 1:length(Am)    
    y = y + (Am(k)/Am(1) * sin(2*pi*k*f1*t + deg2rad(Ph(k))));
end

figure()
subplot(2,1,1)
plot(t,y,'LineWidth',1.1)
grid on
grid minor
set(gca,'FontSize',12)

% Save the txt file with signal data
fid = fopen("data.txt","w","native","UTF-8");
for k = 1:length(t)
    fprintf(fid,"%.4f \t %.4f\n",t(k),y(k));
end
fclose(fid);

%%
clear 
close all
clc

% FILENAME is a string containing the name and path of the .raw file 
% to be converted
FILENAME = './harmonic.fft';

% Ensure the LTspice2Matlab function is available
if ~exist('LTSpice2Matlab', 'file')
    error('LTspice2Matlab function not found. Please check your path.');
end
% Check if the .raw file exists
if ~exist(FILENAME,'file')
    error('.raw function not found. Please check your path.');
end

% Import LTSpice .raw variables
raw_data = LTSpice2Matlab(FILENAME);
fprintf("Importing ...\n");
for k = 1:raw_data.num_variables
    fprintf('%s type %s\n', ...
    raw_data.variable_name_list{k},raw_data.variable_type_list{k})
end

% Plot 
figure()
subplot(3,1,1)
semilogx(raw_data.freq_vect,20*log10(abs(raw_data.variable_mat(1,:))), ...
    "Color",[1 0 0],"LineWidth",1.5)
grid on
grid minor
axis("tight")
set(gca,"FontSize",12,"XTickLabel",[])
ylabel("$\|G(s)\|$",'Interpreter','Latex','FontSize',14)

subplot(3,1,2)
semilogx(raw_data.freq_vect,20*log10(abs(raw_data.variable_mat(2,:))), ...
    "Color",[0 0 1],"LineWidth",1.5)
grid on
grid minor
axis("tight")
set(gca,"FontSize",12,"XTickLabel",[])
ylabel("$\|G(s)\|$",'Interpreter','Latex','FontSize',14)

subplot(3,1,3)
semilogx(raw_data.freq_vect,20*log10(abs(raw_data.variable_mat(3,:))), ...
    "Color",[0 1 0],"LineWidth",1.5)
grid on
grid minor
axis("tight")
set(gca,"FontSize",12)
ylabel("$\|G(s)\|$",'Interpreter','Latex','FontSize',14)

%%