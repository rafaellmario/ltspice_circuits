%% Run and load LTSpice simulation (windows)
%% Run LTSpice program
clear 
close all
clc

filePath = ".\\"; % path to the file
fileName = "cauer_passive_filter"; % Name of the file to run
spicePath = "C:\\Program Files\\ADI\\LTspice\\"; % path to LT spice installation folder

% Cleanup folder
delete(strcat(filePath,"*.raw")) % remove raw files
delete(strcat(filePath,"*.log")) % remove log files
delete(strcat(filePath,"*.net")) % remove net files

% Start simulation task 
string = sprintf('"%sLTspice.exe" -b -Run "%s%s.asc"',spicePath,filePath, fileName); % LTspice.exe
dos(string);
pause(5); % Wait for 5 seconds to run the simulation

% Get the results
outputfile = sprintf('%s.raw', fileName);
result = importSPICEresults(outputfile,'LTspice',1);

% Terminate process
% string = "taskkill /IM LTSpice.exe";
% dos(string); 

clear filePath fileName spicePath string outputfile

figure()
subplot(2,1,1)
semilogx(result.freq_vect, 20*log10(abs(result.variable_mat(3,:))));
legend(result.variable_name_list(3));
grid on
grid minor

subplot(2,1,2)
semilogx(result.freq_vect, rad2deg(angle(result.variable_mat(3,:))));
legend(result.variable_name_list(3));
grid on
grid minor

%% Run LTSpice program
clear 
close all
clc

filePath = ".\\"; % path to the file
fileName = "active_filter"; % Name of the file to run
spicePath = "C:\\Program Files\\ADI\\LTspice\\"; % path to LT spice installation folder

% Cleanup folder
delete(strcat(filePath,"*.raw")) % remove raw files
delete(strcat(filePath,"*.log")) % remove log files
delete(strcat(filePath,"*.net")) % remove net files

% Start simulation task 
string = sprintf('"%sLTspice.exe" -b -Run "%s%s.asc"',spicePath,filePath, fileName); % LTspice.exe
dos(string);
pause(5); % Wait for 5 seconds to run the simulation

% Get the results
outputfile = sprintf('%s.raw', fileName);
result = importSPICEresults(outputfile,'LTspice',1);

clear filePath fileName spicePath string outputfile

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

%%