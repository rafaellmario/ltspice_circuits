%% Open .ac analysis
%%
clear 
close all
clc

% FILENAME is a string containing the name and path of the .raw file 
% to be converted
FILENAME = './thermal.raw';
% FILENAME = './single.raw';

% Ensure the LTspice2Matlab function is available
if ~exist('LTSpice2Matlab', 'file')
    error('LTspice2Matlab function not found. Please check your path.');
end
% Check if the .raw file exists
if ~exist(FILENAME,'file')
    error('.raw function not found. Please check your path.');
end

raw_data = LTSpice2Matlab(FILENAME);
for k = 1:raw_data.num_variables
    fprintf('%s type %s\n', ...
    raw_data.variable_name_list{k},raw_data.variable_type_list{k})
end

% Compute the NTC curve
r_ntc = (raw_data.variable_mat(3,:) - raw_data.variable_mat(2,:))./raw_data.variable_mat(5,:); 

figure()
% Plot NTC resistive curve
subplot(2,1,1)
plot(raw_data.variable_mat(1,:),r_ntc)
grid on
grid minor
set(gca,'FontSize',12,'XTickLabel',[])

% Plot linearized curve
subplot(2,1,2)
plot(raw_data.variable_mat(1,:),raw_data.variable_mat(4,:))
grid on
grid minor
set(gca,'FontSize',12)

%%