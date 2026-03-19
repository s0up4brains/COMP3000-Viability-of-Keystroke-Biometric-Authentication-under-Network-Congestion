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
numUsers = 51;

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
% User typing profile 
% Mean value of each users key-up key-down times

for i = 1:numUsers %iterate trough all 51 users
    startIdx = (i-1)*splitSize + 1;
    endIdx = i*splitSize;
     
    userData = trainData(startIdx:endIdx, :);
    trainArray = table2array(userData);
    
    trainArrayMeans(i, :) = mean(trainArray, 1);    
 
end

% make test data compatible with trainArrayMeans array
testArray = table2array(testData);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Keystroke Authenication for test samples using Euclidean disatnce Success / Failure

%Initialise 
threshold = 0.7; 
output = []; 

for u = 1:numUsers
    
    startIdx = (u-1)*splitSize + 1;
    endIdx   = u*splitSize;
    
    currentTemplate = trainArrayMeans(u, :);
    
    for j = startIdx:endIdx
        
        testSample = testArray(j, :);
        
        % Euclidean distance
        dist = sqrt(sum((testSample - currentTemplate).^2));
        
        % Decision
        if dist < threshold
            output = [output; 1]; % Success
        else
            output = [output; 0]; % Failure
        end
        
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Evaluate the base data FAR FRR EER accuracy


%FAR

%FRR

%accuracy

% Find EER


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Apply Latency / controlled delay model

% timings for different countries OR Random timings

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