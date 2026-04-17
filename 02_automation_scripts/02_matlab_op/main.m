%% Open .op analysis
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
table(string(raw_data.variable_name_list'), ...
      raw_data.variable_mat, ...
      string(raw_data.variable_type_list'))

%%