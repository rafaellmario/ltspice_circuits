%% Run and load LTSpice simulation
%% Run LTSpice program
clear 
close all
clc

filePath = "./";
fileName = "active_filter";
spicePath = "C:\\Program Files\\ADI\\LTspice";

% Start simulation task 
string = sprintf('start "%s\\LTSpice.exe -b -Run" "%s%s.asc"',spicePath, filePath, fileName); % LTspice.exe
dos(string);

outputfile = sprintf('%s.raw', fileName);
pause(5); %This 5 seconds pause is needed so that the the LT spice analysis is completed and results are available to read. 
          %If it is a very big analysis you may need to increse from 5s to higher time.

result = importSPICEresults(outputfile,'LTspice',1);

% Terminate process
string = "taskkill /IM LTSpice.exe";
dos(string); 

figure()
subplot(2,1,1)
semilogx(result.freq_vect, 20*log10(abs(result.variable_mat(14,:))));
legend(result.variable_name_list(14));
xlim([1 1e4])
grid on
grid minor

subplot(2,1,2)
semilogx(result.freq_vect, rad2deg(angle(result.variable_mat(14,:))));
legend(result.variable_name_list(14));
xlim([1 1e4])
grid on
grid minor


%% Opening raw file





