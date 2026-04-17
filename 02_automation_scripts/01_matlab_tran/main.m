%% Open a .tran analysis
%%
clear 
close all
clc

% FILENAME is a string containing the name and path of the .raw file 
% to be converted
FILENAME = './low_pass_filter.raw';

% Ensure the LTSpice2Matlab function is available
if ~exist('LTSpice2Matlab', 'file')
    error('LTSpice2Matlab function not found. Please check your path.');
end

% Check if the .raw file exists
if ~exist(FILENAME,'file')
    error('.raw function not found. Please check your path.');
end

raw_data = LTSpice2Matlab(FILENAME,[]);
fprintf("The file has %d variables listed below:\n",raw_data.num_variables);
raw_data = LTSpice2Matlab(FILENAME,[]); 
for k = 1:raw_data.num_variables
    fprintf('%s ', raw_data.variable_name_list{k})
end
fprintf('\n')
clear raw_data;

% SELECTED_VARS is a vector of indexes indicating which variables 
% to extract  from the .raw file
SELECTED_VARS = [1 2];
raw_data = LTSpice2Matlab(FILENAME,SELECTED_VARS);
fprintf("Importing :\n");
for k = SELECTED_VARS
    fprintf('%s ', raw_data.variable_name_list{k})
end
fprintf('\n')

figure()
hold on
plot(raw_data.time_vect, raw_data.variable_mat(1,:), 'b','LineWidth',1.5);
plot(raw_data.time_vect, raw_data.variable_mat(2,:), 'r','LineWidth',1.5);
hold off
axis('tight')
grid on
grid minor
title(sprintf('Waveform %s, %s', raw_data.variable_name_list{1:2}));
legend(raw_data.variable_name_list{1:2}, 'Location', 'best');
ylabel(sprintf('%s', raw_data.variable_type_list{1}))
xlabel('Time (sec)' );

%%