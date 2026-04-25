%% .dc with steps analysis
%%
clear 
close all
clc

% FILENAME is a string containing the name and path of the .raw file 
% to be converted
FILENAME = 'bsp89_output_charac';

% LTSpice installation folder
SpicePath = "C:\\Program Files\\ADI\\LTspice\\";

% Ensure the LTspice2Matlab function is available
if ~exist('LTSpice2Matlab', 'file')
    error('LTspice2Matlab function not found. Please check your path.');
end

% Ensure the LTspice2Matlab function is available
if ~exist(sprintf("./%s.net",FILENAME), 'file')
    error('%s.net was not found',FILENAME);
end

% Cleanup folder
delete("./*.raw") % remove raw files
delete("./*.log") % remove log files

vg_pattern = ".param vg=\d+\.?\d*";
m = 1;

for k = [5 4.2 3.4 3 2]

    % Store the previous simulation data content
    fileContent = fileread(sprintf("./%s.net",FILENAME));
    
    % Create a string to modify the simulation
    vg_current = sprintf(".param vg=%.2f",k);
    
    % Update the simulation circuit
    modifiedContent = regexprep(fileContent,vg_pattern,vg_current);
    
    % Write the modified content
    fid = fopen(sprintf("./%s.net",FILENAME),"w"); 
    if fid == -1
        error('Cannot open the file!');
    end
    fprintf(fid,"%s",modifiedContent);
    fclose(fid);
    
    % Execute the simulation
    command = sprintf('"%sLTspice.exe" -b -Run "./%s.net"', ...
    SpicePath,FILENAME);
    dos(command);
    pause(1); % Wait for 5 seconds to run the simulation
    
    % Get the results
    if ~exist(sprintf("./%s.net",FILENAME), 'file')
        error('.raw file was not found');
    end
    outputfile = sprintf('%s.raw', FILENAME);
    raw_data = LTSpice2Matlab(outputfile);

    % capture sweep data
    id(:,m) = raw_data.variable_mat;
    rds(:,m) = raw_data.sweep_vect./raw_data.variable_mat;
    vg_steps(m) = sprintf("V_{gs} = %.1f",k);
    m = m + 1;
end 

% For this simulation sweep variable was the VDS voltage
vdd = raw_data.sweep_vect;

% Clear unecessary variables
clear fileContent vg_pattern vg_current outputfile FILENAME ...
      SpicePath outputfile k m modifiedContent fid command

figure()
% Plot ID vs. VDS curve
subplot(2,1,1)
plot(vdd, id, 'LineWidth',1.5)
ylim([0 0.6])
grid on 
grid minor
set(gca,'FontSize',12)
legend(vg_steps,'Orientation','horizontal','Location','northoutside')

subplot(2,1,2)
% plot RDS vs. ID
plot(id, rds, 'LineWidth',1.5)
axis([0 0.6 0 9])
grid on 
grid minor
set(gca,'FontSize',12)

%%