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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graph Svae lcaotion filepath
graphFilePath = 'research\figures';

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

trainArray = table2array(trainData);
testArray  = table2array(testData);

% Normalise dataset
mu = mean(trainArray, 1);
sigma = std(trainArray, 0, 1);

sigma(sigma == 0) = 1; 

trainArray = (trainArray - mu) ./ sigma;
testArray  = (testArray - mu) ./ sigma;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% User typing profile: Mean value of each users key-up key-down times
trainArrayMeans = zeros(numUsers, size(trainArray,2));

for i = 1:numUsers %iterate trough all 51 users
    startIdx = (i-1)*splitSize + 1;
    endIdx = i*splitSize;
     
    userData = trainArray(startIdx:endIdx, :);
    trainArrayMeans(i, :) = mean(userData, 1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Control / Baseline Euclidean
% Keystroke Authenication for test samples using Euclidean disatnce Success / Failure

% Optimum threshold
% threshold = 3.789061255426592;


% indexes
idx = 1;
imposterIdx = 1;

%Preallocate Tables
genuineScores = zeros(numUsers * splitSize,1);
imposterScores = zeros(numUsers * splitSize * (numUsers-1),1);

% Euclidean Distance of all Users
for u = 1:numUsers
    
    startIdx = (u-1)*splitSize + 1;
    endIdx = u*splitSize;
    template = trainArrayMeans(u,:);
   
    for j = startIdx:endIdx
        
        sample = testArray(j,:);
        
        % Euclidean distance Equation
        dist = sqrt(sum((sample - template).^2));
        
        % Store the distance for plotting
        genuineScores(idx) = dist;

        for k = 1:numUsers
            if k ~= u
                imposterTemplate = trainArrayMeans(k,:);
                distImposter = sqrt(sum((sample - imposterTemplate).^2));
                imposterScores(imposterIdx) = distImposter;
                imposterIdx = imposterIdx + 1;
            end
        end
        
     %Increase iteration
        idx = idx + 1;
    end
end

%Plot All Users
figure;
plot(genuineScores);
hold on;

% yline(threshold, 'r--', 'Threshold');

for u = 1:numUsers
    userSection = u * splitSize;
    xline(userSection, 'k--');
end

title('Euclidean Distance of Original Data');
xlabel('Sample Number');
ylabel('Distance from Mean');
grid on;
filename = 'EuclideanDistanceOfOriginalData' ; 
saveas(gca, fullfile(graphFilePath, filename), 'jpeg');



% %Euclidean Distance of one User
userToPlot = 1;

startIdx = (userToPlot-1)*splitSize + 1;
endIdx   = userToPlot*splitSize;

currentTemplate = trainArrayMeans(userToPlot, :);
idx = 1;
userDistance = zeros(splitSize,1); 

for j = startIdx:endIdx

    testSample = testArray(j, :);

    % Euclidean distance Equation
    dist = sqrt(sum((testSample - currentTemplate).^2));

    % Store the distance for plotting
    userDistance(idx) = dist;
    idx = idx + 1;
end

% Plot one User
figure;
plot(userDistance, 'b');
hold on;
% yline(threshold, 'r--', 'Threshold');
title(['Euclidean Distance of Original Data - User ', num2str(userToPlot)]);
xlabel('Sample Number');
ylabel('Distance');
grid on;
filename = 'EuclideanDistanceOfOriginalDataSingleUser' ; 
saveas(gca, fullfile(graphFilePath, filename), 'jpeg');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Evaluate the base data FAR FRR EER & Balanced accuracy

% ROC
scores = -[genuineScores; imposterScores];
labels = [ones(length(genuineScores),1); zeros(length(imposterScores),1)];

%FAR original
[FAR_original, TPR, T, AUC] = perfcurve(labels, scores, 1);

%FRR original
FRR_original = 1 - TPR;

%EER original
[~, idxEER] = min(abs(FAR_original - FRR_original));
EER_original = FAR_original(idxEER);

%Optimal Threshold
threshold = -T(idxEER); % threshold at EER from ROC

% Balanced Accuracy Confusion Matrix
TP = sum(genuineScores < threshold);
FN = sum(genuineScores >= threshold);
FP = sum(imposterScores < threshold);
TN = sum(imposterScores >= threshold);

accuracy_original = ((TP/(TP+FN)) + (TN/(TN+FP))) / 2;


disp(['Original Balanced Accuracy = ', num2str(accuracy_original * 100), '%']);
disp(['Original EER = ', num2str(EER_original)]);

avgEuclidean_base = mean(genuineScores);
disp(['Baseline Avg Euclidean Distance = ', num2str(avgEuclidean_base)]);
avgImposter_base = mean(imposterScores);
disp(['Baseline Avg Imposter Distance = ', num2str(avgImposter_base)]);


separation = avgImposter_base - avgEuclidean_base;

separationNorm = separation / std(genuineScores);

disp(['Baseline separation  ', num2str(separation)  ' | Baseline separationNorm = ', num2str(separationNorm)]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Apply Latency / controlled delay model

%Get timings from datset
latency = timingsTable.latency;
jitter = timingsTable.jitter;
packetLoss = timingsTable.packet_loss;


numLevels = 15;
accuracyResults = zeros(numLevels,1);
EERResults = zeros(numLevels,1);

%Averages for results 
avgEuclidean = zeros(1, numLevels);
avgPacketLoss = zeros(1, numLevels);
avgLatency = zeros(1, numLevels);
avgJitter = zeros(1, numLevels);


for L = 1:numLevels

    totalDist = 0;
    count = 0;
    
    idxNet = randi(length(latency), size(testArray,1), 1);

    latencySample = latency(idxNet);
    jitterSample  = jitter(idxNet);
    lossSample    = packetLoss(idxNet);

    %Scale Latency Values
    latencyNorm = latencySample / max(latency);
    jitterNorm  = jitterSample / max(jitter);
    
    scale = L * 10;
    
    %Expand Matixes
    latencyMatrix = repmat(latencyNorm, 1, size(testArray,2));
    jitterMatrix  = repmat(jitterNorm, 1, size(testArray,2));

    %Latency
    Ls = latencyMatrix * scale * 0.05;

    %Jitter
    Js = randn(size(testArray)) .* (jitterMatrix * scale * 0.1);

    % Apply distortion
    DistortionData = testArray + Ls + Js;

    % Packet loss
    lossProb = lossSample / 100;
    lossMatrix = repmat(lossProb, 1, size(testArray,2));
    lossProbScaled = 1 - (1 - lossMatrix).^(scale * 0.05);

    lossMask = rand(size(testArray)) < lossProbScaled;


    %Apply Loss to distortion model
    DistortionData(lossMask) = NaN;

    DistortionData = fillmissing(DistortionData, 'linear');


    % Euclidean Distance
    idx = 1;
    imposterIdx = 1;

    genuineScores = zeros(numUsers * splitSize,1);
    imposterScores = zeros(numUsers * splitSize * (numUsers-1),1);

    for u = 1:numUsers
        
        startIdx = (u-1)*splitSize + 1;
        endIdx = u*splitSize;
        template = trainArrayMeans(u,:);
        
        for j = startIdx:endIdx
            
            sample = DistortionData(j,:);
            
            dist = sqrt(sum((sample - template).^2));
            genuineScores(idx) = dist;

            % Total Distortion for this level
            totalDist = totalDist + dist;
            count = count + 1;

            for k = 1:numUsers
                if k ~= u
                    imposterTemplate = trainArrayMeans(k,:);
                    distImposter = sqrt(sum((sample - imposterTemplate).^2));
                    imposterScores(imposterIdx) = distImposter;
                    imposterIdx = imposterIdx + 1;
                end
            end
            
            idx = idx + 1;
        end
    end



    % Averages
    avgEuclidean(L) = totalDist / count;
    avgImposter(L) = mean(imposterScores);
    separation(L) = avgImposter(L) - avgEuclidean(L);

    separationNorm(L) = separation(L) / std(genuineScores);

    avgLatency(L) = mean(Ls(:));
    avgJitter(L) = mean(abs(Js(:)));
    avgPacketLoss(L) = sum(lossMask(:)) / numel(lossMask);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Network FAR FRR EER 

    %ROC
    scores = -[genuineScores; imposterScores];
    labels = [ones(length(genuineScores),1); zeros(length(imposterScores),1)];
    
    % FAR Network
    [FAR_network, TPR, T, AUC] = perfcurve(labels, scores, 1);

    %FRR Network
    FRR_network = 1 - TPR;

    %EER Network
    [~, idxEER] = min(abs(FAR_network - FRR_network));
    EERResults(L) = FAR_network(idxEER);

    % Network Accuracy Confusion Matrix
    TP = sum(genuineScores < threshold);
    FN = sum(genuineScores >= threshold);
    FP = sum(imposterScores < threshold);
    TN = sum(imposterScores >= threshold);

    accuracyResults(L) = ((TP/(TP+FN)) + (TN/(TN+FP))) / 2;

    disp(['Degradation Level ', num2str(L), ' | Balanced Accuracy = ', num2str(accuracyResults(L)*100), '% | EER = ', num2str(EERResults(L)),' | Average Euclidean = ', num2str(avgEuclidean(L)), ' | Average Imposter Euclidean = ',num2str(avgImposter(L)), ' | Average Latency = ',num2str(avgLatency(L)), ' | Average Jitter = ',num2str(avgJitter(L)), ' | Average Packet Loss = ', num2str(avgPacketLoss(L)*100), '%']);
    disp(['separation  ', num2str(separation(L))  ' | separationNorm = ', num2str(separationNorm(L))]);



    %Store Each level
    DistortionStore{L} = DistortionData;

end


cutoffIdx = find(EERResults > 0.3, 1);
cutoffLatency = cutoffIdx;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %Convert modified array to table
modifiedDataTable = array2table(DistortionData);

% Save as Modidied Data as CSV table
saveDirectoryPath = 'data\';
fullFilePath = fullfile(saveDirectoryPath, 'modifiedDataTable.csv');
writetable(modifiedDataTable, fullFilePath);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOTS


% Prepare for plotting the Balanced accuracy results
figure;
plot(1:numLevels, accuracyResults, 'b-o', 'LineWidth', 2);
hold on;
plot(1:numLevels, EERResults, 'r-x', 'LineWidth', 2);
xlabel('Degradation Level');
ylabel('Performance Metrics');
title('Balanced Accuracy and EER across Degradation Levels');
legend('Balanced Accuracy', 'EER');
grid on;
filename = 'AccuracyEERacrossDegradationLevels' ; 
saveas(gca, fullfile(graphFilePath, filename), 'jpeg');


%Plot All Users
figure;
plot(genuineScores);
hold on;

yline(threshold, 'r--', 'Threshold');
yline(cutoffLatency, 'r--', 'Viability Threshold');

for u = 1:numUsers
    userSection = u * splitSize;
    xline(userSection, 'k--');
end

title('Euclidean Distance of Network Modified Data');
xlabel('Sample Number');
ylabel('Distance from Mean');
grid on;
filename = 'EuclideanDistanceNetworkModifiedData' ; 
saveas(gca, fullfile(graphFilePath, filename), 'jpeg');

userToPlot = 1;

startIdx = (userToPlot-1)*splitSize + 1;
endIdx   = userToPlot*splitSize;

currentTemplate = trainArrayMeans(userToPlot, :);
idx = 1;
userDistance = zeros(splitSize,1); 

for j = startIdx:endIdx

    testSample = DistortionData(j, :);

        % Euclidean distance Equation
    dist = sqrt(sum((testSample - currentTemplate).^2));

        % Store the distance for plotting
    userDistance(idx) = dist;
    idx = idx + 1;
end

% Plot one User
figure;
plot(userDistance, 'b');
hold on;
yline(threshold, 'r--', 'Threshold');
title(['Euclidean Distance of Network Modifed Data - User ', num2str(userToPlot)]);
xlabel('Sample Number');
ylabel('Distance');
grid on;
filename = 'EuclideanDistanceNetworkModifiedDataSignleUSer' ; 
saveas(gca, fullfile(graphFilePath, filename), 'jpeg');


% Plot FAR vs FRR
figure;
plot(FAR_original, FRR_original, 'b', 'LineWidth', 2); hold on;
plot(FAR_network, FRR_network, 'r-', 'LineWidth', 2);
legend('Original','Network');
xlabel('FAR'); ylabel('FRR');
title('FAR vs FRR Comparison');
grid on;
filename = 'FARFRRComparison' ; 
saveas(gca, fullfile(graphFilePath, filename), 'jpeg');

% EER vs Degradation
figure;
plot(1:numLevels, EERResults, '-o');
xlabel('Network Degradation Level');
ylabel('EER');
title('EER vs Network Degradtion');
grid on;
filename = 'EERNetworkDegradation' ; 
saveas(gca, fullfile(graphFilePath, filename), 'jpeg');


%Genuine vs Imposters OR separation
figure;
plot(1:numLevels, avgEuclidean, '-o', 'LineWidth', 2); hold on;
plot(1:numLevels, avgImposter, '-o', 'LineWidth', 2); hold on;
xlabel('Degradation Level');
ylabel('Mean Euclidean Distance');
legend('Genuine User Distances', 'Imposter User Distance');
title('Euclidean Distributions under Network Degradation');
grid on;
filename = 'EuclideanDistributionsunderNetworkDegradation' ; 
saveas(gca, fullfile(graphFilePath, filename), 'jpeg');

figure;
plot(1:numLevels, separation, '-o', 'LineWidth', 2);
xlabel('Degradation Level');
ylabel('Genuine–Imposter separation');
title('Euclidean separation vs Network Degradation');
grid on;
filename = 'separation' ; 
saveas(gca, fullfile(graphFilePath, filename), 'jpeg');

%Average Network Conditions per Degradation Level
%MAYBE INCLDUE?
figure;
plot(1:numLevels, avgLatency, '-o'); hold on;
plot(1:numLevels, avgJitter, '-o'); hold on;
plot(1:numLevels, avgPacketLoss, '-o');
xlabel('Degradation Level');
ylabel('Average Value');
legend('Latency (ms)', 'Jitter (ms)', 'Packet Loss');
title('Average Network Conditions per Degradation Level');
grid on;
filename = 'NetworkConditionsvsDegradation' ; 
saveas(gca, fullfile(graphFilePath, filename), 'jpeg');







