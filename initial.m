clear all;
close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define the file paths
filePath = 'data\CMUDataOriginal'; 
%Read the data into a table
dataTable = readtable(filePath); 
%Remove first 3 rows
dataTable(:,[1 2 3]) = [];

