%% Open .ac analysis
%%
clear 
close all
clc

% FILENAME is a string containing the name and path of the .raw file 
% to be converted
FILENAME = './transistor_polarization.raw';

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

figure()
subplot(2,1,1)
semilogx(raw_data.freq_vect,20*log(abs(raw_data.variable_mat(5,:))), ...
    "Color",[1 0 0],"LineWidth",1.5)
grid on
grid minor
set(gca,"FontSize",12)
set(gca,"XTickLabel",[])

subplot(2,1,2)
semilogx(raw_data.freq_vect,rad2deg(angle(raw_data.variable_mat(5,:))), ...
    "Color",[1 0 0],"LineWidth",1.5)
grid on
grid minor

set(gca,"FontSize",12)
%%