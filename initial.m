clear all;
close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define the file paths
filePath = 'data\CMUDataOriginal'; 
%Read the data into a table
dataTable = readtable(filePath); 
%Remove first 3 rows
dataTable(:,[1 2 3]) = [];

X = dataTable;
n = height(X);

userSize = 400; %User sample size
splitSize = userSize / 2; %Split for train/test

trainIdx = false(n,1);
testIdx  = false(n,1);

for i = 1:userSize:n
    trainRange = i:min(i+splitSize-1, n);
    testRange  = (i+splitSize):min(i+userSize-1, n);

    trainIdx(trainRange) = true;
    testIdx(testRange) = true;
end

% % Training Dataset - First 200 password entries per user
trainData = X(trainIdx, :);
% % Testing Dataset - Last 200 password entries per user
testData  = X(testIdx, :);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% User typing templates

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Keystroke Authenication for test samples using Euclidean disatnce Success / Failure

% Declare authentication threshold


%output success / failure

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Evaluate the base data FAR FRR EER accuracy


%FAR

%FRR

%accuracy

% Find EER




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Apply Latency / controlled delay model

% for loop (i)

%Latency

%Jitter

%Packet Loss


%Store (i) modified Latency dataset

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Evaluate the modified latency data FAR FRR EER accuracy

%FAR

%FRR

%accuracy

% Find EER

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Compare base vs modified latency results

%compare accuracy
%compare FAR
%compare FRR


%Plot accuracy vs latency