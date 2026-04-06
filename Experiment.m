clear;
close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define the file paths

% CMU Dataset
filePath = 'data\CMUDataOriginal'; 
%Read the data into a table
dataTable = readtable(filePath); 
%Remove first 3 rows
dataTable(:,[1,2,3]) = [];

% Network Timings Dataset
filePath = 'data\networkDataset\network_dataset'; 
%Read the data into a table
timingsTable = readtable(filePath); 
%Remove rows
timingsTable(:,[1,8,9,10,11,12,13,14,15]) = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Train and Normalise Data

X = dataTable;
n = height(X);

userSize = 400; % sample size for each of the 51 users
splitSize = userSize / 2; %Split userSize in half for train/test
numUsers = 51; % Users in CMU Dataset

trainIdx = false(n,1);
testIdx  = false(n,1);

for i = 1:userSize:n
    trainIdx(i:i+splitSize-1) = true;
    testIdx(i+splitSize:i+userSize-1) = true;
end

% % Training Dataset - First 200 password entries per user
trainData = X(trainIdx, :);
% % Testing Dataset - Last 200 password entries per user
testData  = X(testIdx, :);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% User typing profile 
% Mean value of each users key-up key-down times
trainArrayMeans = zeros(51, 31); %Preallocate

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

threshold = 2;
idx = 1;
imposterIdx = 1;
output = zeros(10000,1); 
distancesPlot = zeros(10000,1);
imposterScores = zeros(500000,1);


% Euclidean Distance of all Users
for u = 1:numUsers
    
    startIdx = (u-1)*splitSize + 1;
    endIdx = u*splitSize;
   
    currentTemplate = trainArrayMeans(u, :);
    
    for j = startIdx:endIdx

        testSample = testArray(j, :);
        
        % Euclidean distance Equation
        dist = sqrt(sum((testSample - currentTemplate).^2));
        
        % Store the distance for plotting
        distancesPlot(idx) = dist;


        for k = 1:numUsers
            if k ~= u
                imposterTemplate = trainArrayMeans(k, :);
                
                distImposter = sqrt(sum((testSample - imposterTemplate).^2));
                imposterScores(imposterIdx) =  distImposter;
                imposterIdx = imposterIdx + 1;
            end
        end


        % Decision
        if dist < threshold
            output(idx) = 1; % Success
        else
            output(idx) = 0; % Failure
        end
     %Increase iteration
     idx = idx + 1;
    end

end


%Plot All Users
figure;
plot(distancesPlot);
hold on;

yline(threshold, 'r--', 'Threshold');

for u = 1:numUsers
    userSection = u * splitSize;
    xline(userSection, 'k--');
end

title('Euclidean Distance for Test Samples');
xlabel('Sample Number');
ylabel('Distance from Mean');
grid on;



% %Euclidean Distance of one User
% userToPlot = 1;
% 
%     startIdx = (userToPlot-1)*splitSize + 1;
%     endIdx   = userToPlot*splitSize;
% 
%     currentTemplate = trainArrayMeans(userToPlot, :);
%     idx = 1;
%     userDistance = zeros(200,1); 
% 
%     for j = startIdx:endIdx
% 
%         testSample = testArray(j, :);
% 
%         % Euclidean distance Equation
%         dist = sqrt(sum((testSample - currentTemplate).^2));
% 
%         % Store the distance for plotting
%         userDistance(idx) = dist;
%         idx = idx + 1;
%     end
% 
% % Plot one User
% figure;
% plot(userDistance, 'b');
% hold on;
% 
% yline(threshold, 'r--', 'Threshold');
% 
% title(['Euclidean Distance - User ', num2str(userToPlot)]);
% xlabel('Sample Number');
% ylabel('Distance');
% grid on;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Evaluate the base data FAR FRR EER accuracy

scores = [distancesPlot; imposterScores];
labels = [ones(length(distancesPlot),1); zeros(length(imposterScores),1)];

%FAR
[FAR, TPR, T, AUC] = perfcurve(labels, scores, 1);

%FRR
FRR = 1 - TPR;

figure;
plot(FAR, FRR, 'b', 'LineWidth', 2);
xlabel('FAR');
ylabel('FRR');
title('FAR vs FRR Curve');
grid on;

% Find EER
[~, idx] = min(abs(FAR - FRR));
EER = FAR(idx);
disp(['EER = ', num2str(EER)]);


%accuracy
accuracy = sum(output == 1) / length(output);
disp(['Accuracy = ', num2str(accuracy)]);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Apply Latency / controlled delay model

% timings for different countries OR Random timings

% for loop (i)

%Latency

%Jitter

%Packet Loss


%Store (i) modified Latency dataset


%Convert Array back to table

% modifiedDataTable = table([1; 2], {'A'; 'B'}, 'VariableNames', {'ID', 'Label'});
% 
% % Save as Modidied Data as CSV table
% saveDirectoryPath = 'data\';
% fullFilePath = fullfile(saveDirectoryPath, 'modifiedDataTable.csv');
% writetable(modifiedDataTable, fullFilePath);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Evaluate the base data FAR FRR EER accuracy

% scores = -[distancesPlot; imposterScores];
% labels = [ones(length(distancesPlot),1); zeros(length(imposterScores),1)];
% 
% %FAR
% [FAR, TPR, T, AUC] = perfcurve(labels, scores, 1);
% 
% %FRR
% FRR = 1 - TPR;
% 
% figure;
% plot(FAR, FRR, 'b', 'LineWidth', 2);
% xlabel('FAR');
% ylabel('FRR');
% title('FAR vs FRR Curve');
% grid on;
% 
% % Find EER
% [~, idx] = min(abs(FAR - FRR));
% EER = FAR(idx);
% disp(['EER = ', num2str(EER)]);
% 
% 
% %accuracy
% accuracy = sum(output == 1) / length(output);
% disp(['Accuracy = ', num2str(accuracy)]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Compare base vs modified latency results

%compare accuracy
%compare FAR
%compare FRR


%Plot accuracy vs latency