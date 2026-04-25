%% .op analysis
%%
clear 
close all
clc

% FILENAME is a string containing the name and path of the .raw file 
% to be converted
FILENAME = './thermal.raw';

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


% Plot NTC resistive curve
figure()
% First axis plot
plot(raw_data.variable_mat(1,:),r_ntc, ...
    'LineWidth',1.5,'Marker','o')
ax1 = gca;
ax1_position = ax1.Position;
set(ax1,'XTickLabel',[],'FontSize',12)
grid on
grid minor
ylabel('R_{ntc} [\Omega]','FontSize',12)
xlabel('T [^oC]')

% Second axis plot 
ax2 = axes('Color','none'); % Create secondary axis
plot(ax2,raw_data.variable_mat(1,:),raw_data.variable_mat(4,:), ...
    'Color','r','LineWidt',1.5,'Marker','+')
ax2.Position = ax1_position;
ax2.Color = 'none';
ax2.YColor = 'r';
ax2.YAxisLocation = 'right';
ylabel('V_{out} [V]','FontSize',12)
set(ax2,'FontSize',12)
grid off

%%