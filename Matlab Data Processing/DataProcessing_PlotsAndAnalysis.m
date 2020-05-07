%%  Aim3_plotBarGraphPerStim_allSubjects.m
%
% This file takes in individual csv files per subject that has frame and x
% information of right heel strike (RHS), and plot the step length for
% target foot and a few prior and after.
% 
% This file can also take all csv files from all subjects in this folder
% and perform analysis for the batch. To toggle this feature, change the
% value of variable 'allFiles' below.
%
% Programmer: Astrini Sie
% Date: 08.14.2019

clear all; close all; clc;

plotSeparate = 0;

% Defining colors
purple = [51/255 0 111/255]; % UW Purple
lightPurple = [222/255 189/255 255/255]; 
darkPurple = [120/255 84/255 156/255];
gold = [232/255 211/255 162/255]; % UW Gold
lightGold = [230/255 201/255 133/255];
darkGold = [194/255 166/255 101/255];
xDarkGold = [115/255 84/255 14/255];
grey = [0.4,0.4,0.4];
pink = [230/255 129/255 220/255];
red = [1 0 0];

mycolormap = [purple; 106/255 0 234/255; lightPurple; 1 1 1];

% Position and size of subplots for 3 by 2
% Changing subplot position and size from https://stackoverflow.com/questions/24125099/how-can-i-set-subplot-size-in-matlab-figure
posMatrix3by2 = [0.05    0.7    0.42    0.24;
    0.55    0.7    0.42    0.24;
    0.05    0.4    0.42    0.24;
    0.55    0.4    0.42    0.24;
    0.05    0.1    0.42    0.24;
    0.55    0.1    0.42    0.24];

posMatrix2by3 = [0.05 0.55 0.28 0.42;
    0.38 0.55 0.28 0.42;
    0.71 0.55 0.28 0.42;
    0.05 0.05 0.28 0.42;
    0.38 0.05 0.28 0.42;
    0.71 0.05 0.28 0.42;];

%% ANALYSIS FOR INDIVIDUAL

numSubject = 10;

for si = 1:1:numSubject
%% Load files
% Import only one csv file from one single subject
if si >= 10
    raw = importdata(['0',num2str(si),'.csv']);
else
raw = importdata(['00',num2str(si),'.csv']);
end
ns = 1; % number of subject being evaluated at current time

colStimCon = 2;
colForcePlate = 3;
colVibCue = 4;
colVibFrame = 5;
colFRHS0 = 6;
colFRHS1 = 7;
colFRHS2 = 8;
colFRHS3 = 9;
colFRHS4 = 10;
colxRHS0 = 11;
colxRHS1 = 12;
colxRHS2 = 13;
colxRHS3 = 14;
colxRHS4 = 15;
colSL1 = 16;
colSL2 = 17;
colSL3 = 18;
colSL4 = 19;
colSpeed = 20;

%% Parse data based on stim condition and vibration cues

% Sort raw data into ascending order of stim conditions
sorted = sortrows(raw.data,colStimCon);
sorted(isnan(sorted)) = 0;

% Calculate for step length
sorted(:,colSL1) = sorted(:,colxRHS0) - sorted(:,colxRHS1);
sorted(:,colSL2) = sorted(:,colxRHS1) - sorted(:,colxRHS2);
sorted(:,colSL3) = sorted(:,colxRHS2) - sorted(:,colxRHS3);
sorted(:,colSL4) = sorted(:,colxRHS3) - sorted(:,colxRHS4);

% Calculate for speed
distance = sorted(:,colxRHS0) - sorted(:,colxRHS4); % distance in mm
timeframe = (sorted(:,colFRHS4) - sorted(:,colFRHS0))/120;   % duration in second
sorted(:,colSpeed) = distance./timeframe/1000; % speed in m/s

% Separate raw data into different stim conditions
for i = 0:1:6
   fname = ['s',num2str(i)];
   rawS.(fname) = sorted(i*ns*12+1:(i+1)*ns*12 , :);
end

% Sort stim conditions into ascending order of vibration cues
for i = 0:1:6
   fname = ['s',num2str(i)];
   sortS.(fname) = sortrows(eval(['rawS.s', num2str(i)]), colVibCue);
end

% Separate each stim condition into long or short vibration cue
for i = 1:1:6
   fname = ['s',num2str(i)];
   short.(fname) = eval(['sortS.s', num2str(i), '(1:ns*6,:)']);
   long.(fname) = eval(['sortS.s', num2str(i), '(1+ns*6:2*ns*6,:)']);
end

%% Setting up matrix to contain target foot (absolute step length)
% We normalize the position of target foot step length to be step number 4.
% There is a total of 7 steps, while each trial has a maximum of 4 steps.
% For example, if the target foot is step 1 of the trial, in the normalized
% matrix, we will see values in steps 4,5,6,7, while 1,2,3 are blank. If
% the target foot is step 3 of the trial, in the normalized matrix we will
% see values in steps 2,3,4,5, while 1,6,7 are blank.

% S0
s0{si} = sortS.s0(:,colSL1:colSL4);

for st = 1:1:6
    fname = ['s',num2str(st)];
    % Short for each simi = S1-S6 for all subjects
    for i = 1:size(short.(fname),1)
        % Check for target foot step length
        if short.(fname)(i,colVibFrame) >= short.(fname)(i,colFRHS0) && short.(fname)(i,colVibFrame) < short.(fname)(i,colFRHS1)
            sAll.(fname){si}(i,:) = [0 0 0 short.(fname)(i,colSL1:colSL4)];
        else if short.(fname)(i,colVibFrame) >= short.(fname)(i,colFRHS1) && short.(fname)(i,colVibFrame) < short.(fname)(i,colFRHS2)
                sAll.(fname){si}(i,:) = [0 0 short.(fname)(i,colSL1:colSL4) 0];
            else if short.(fname)(i,colVibFrame) >= short.(fname)(i,colFRHS2) && short.(fname)(i,colVibFrame) < short.(fname)(i,colFRHS3)
                    sAll.(fname){si}(i,:) = [0 short.(fname)(i,colSL1:colSL4) 0 0];
                else if short.(fname)(i,colVibFrame) >= short.(fname)(i,colFRHS3) && short.(fname)(i,colVibFrame) < short.(fname)(i,colFRHS4)
                        sAll.(fname){si}(i,:) = [short.(fname)(i,colSL1:colSL4) 0 0 0];
                    else
                        sAll.(fname){si}(i,:) = [0 0 0 0 0 0 0];
                    end
                end
            end
        end
    end
    
    % Long for each simi = S1-S6 for all subjects
    for i = 1:size(long.(fname),1)
        % Check for target foot step length
        if long.(fname)(i,colVibFrame) >= long.(fname)(i,colFRHS0) && long.(fname)(i,colVibFrame) < long.(fname)(i,colFRHS1)
            lAll.(fname){si}(i,:) = [0 0 0 long.(fname)(i,colSL1:colSL4)];
        else if long.(fname)(i,colVibFrame) >= long.(fname)(i,colFRHS1) && long.(fname)(i,colVibFrame) < long.(fname)(i,colFRHS2)
                lAll.(fname){si}(i,:) = [0 0 long.(fname)(i,colSL1:colSL4) 0];
            else if long.(fname)(i,colVibFrame) >= long.(fname)(i,colFRHS2) && long.(fname)(i,colVibFrame) < long.(fname)(i,colFRHS3)
                    lAll.(fname){si}(i,:) = [0 long.(fname)(i,colSL1:colSL4) 0 0];
                else if long.(fname)(i,colVibFrame) >= long.(fname)(i,colFRHS3) && long.(fname)(i,colVibFrame) < long.(fname)(i,colFRHS4)
                        lAll.(fname){si}(i,:) = [long.(fname)(i,colSL1:colSL4) 0 0 0];
                    else
                        lAll.(fname){si}(i,:) = [0 0 0 0 0 0 0];
                    end
                end
            end
        end
    end
end

%% Setting up matrix to contain target foot (normalized step length)

s0mean{si} = [mean(sortS.s0(:,colSL1)) mean(sortS.s0(:,colSL2)) mean(sortS.s0(:,colSL3)) mean(sortS.s0(:,colSL4))];

for st = 1:1:6
    fname = ['s',num2str(st)];
    % Short for each stim time (st) = S1-S6 for all subjects
    for i = 1:size(short.(fname),1)
        % Check for target foot step length
        if short.(fname)(i,colVibFrame) >= short.(fname)(i,colFRHS0) && short.(fname)(i,colVibFrame) < short.(fname)(i,colFRHS1)
            sNorm.(fname){si}(i,:) = [0 0 0 short.(fname)(i,colSL1:colSL4)./s0mean{si}];
        else if short.(fname)(i,colVibFrame) >= short.(fname)(i,colFRHS1) && short.(fname)(i,colVibFrame) < short.(fname)(i,colFRHS2)
                sNorm.(fname){si}(i,:) = [0 0 short.(fname)(i,colSL1:colSL4)./s0mean{si} 0];
            else if short.(fname)(i,colVibFrame) >= short.(fname)(i,colFRHS2) && short.(fname)(i,colVibFrame) < short.(fname)(i,colFRHS3)
                    sNorm.(fname){si}(i,:) = [0 short.(fname)(i,colSL1:colSL4)./s0mean{si} 0 0];
                else if short.(fname)(i,colVibFrame) >= short.(fname)(i,colFRHS3) && short.(fname)(i,colVibFrame) < short.(fname)(i,colFRHS4)
                        sNorm.(fname){si}(i,:) = [short.(fname)(i,colSL1:colSL4)./s0mean{si} 0 0 0];
                    else
                        sNorm.(fname){si}(i,:) = [0 0 0 0 0 0 0];
                    end
                end
            end
        end
    end
    
    % Long for each stim time (st) = S1-S6 for all subjects
    for i = 1:size(long.(fname),1)
        % Check for target foot step length
        if long.(fname)(i,colVibFrame) >= long.(fname)(i,colFRHS0) && long.(fname)(i,colVibFrame) < long.(fname)(i,colFRHS1)
            lNorm.(fname){si}(i,:) = [0 0 0 long.(fname)(i,colSL1:colSL4)./s0mean{si}];
        else if long.(fname)(i,colVibFrame) >= long.(fname)(i,colFRHS1) && long.(fname)(i,colVibFrame) < long.(fname)(i,colFRHS2)
                lNorm.(fname){si}(i,:) = [0 0 long.(fname)(i,colSL1:colSL4)./s0mean{si} 0];
            else if long.(fname)(i,colVibFrame) >= long.(fname)(i,colFRHS2) && long.(fname)(i,colVibFrame) < long.(fname)(i,colFRHS3)
                    lNorm.(fname){si}(i,:) = [0 long.(fname)(i,colSL1:colSL4)./s0mean{si} 0 0];
                else if long.(fname)(i,colVibFrame) >= long.(fname)(i,colFRHS3) && long.(fname)(i,colVibFrame) < long.(fname)(i,colFRHS4)
                        lNorm.(fname){si}(i,:) = [long.(fname)(i,colSL1:colSL4)./s0mean{si} 0 0 0];
                    else
                        lNorm.(fname){si}(i,:) = [0 0 0 0 0 0 0];
                    end
                end
            end
        end
    end
end

% Tabulating all normalized step length of target foot only
for st = 1:1:6
    fname = ['s',num2str(st)];
    normSTargetStride(si,st) = nanmean(sNorm.(fname){1,si}(:,4));
    normLTargetStride(si,st) = nanmean(lNorm.(fname){1,si}(:,4));
end
meanNormSTarget(si) = mean(normSTargetStride(si,:));
meanNormLTarget(si) = mean(normLTargetStride(si,:));

%% Setting up matrix to contain only target foot relative stride length and speed of corresponding trial

s0mean{si} = [mean(sortS.s0(:,colSL1)) mean(sortS.s0(:,colSL2)) mean(sortS.s0(:,colSL3)) mean(sortS.s0(:,colSL4))];

for st = 1:1:6
    fname = ['s',num2str(st)];
    % Short for each stim time (st) = S1-S6 for all subjects
    for i = 1:size(short.(fname),1)
        % Check for target foot step length
        if short.(fname)(i,colVibFrame) >= short.(fname)(i,colFRHS0) && short.(fname)(i,colVibFrame) < short.(fname)(i,colFRHS1)
            speedAndTargetLengthShort.(fname){si}(i,1:3) = [short.(fname)(i,colSL1) s0mean{si}(1) short.(fname)(i,colSpeed)];
        else if short.(fname)(i,colVibFrame) >= short.(fname)(i,colFRHS1) && short.(fname)(i,colVibFrame) < short.(fname)(i,colFRHS2)
                speedAndTargetLengthShort.(fname){si}(i,1:3) = [short.(fname)(i,colSL2) s0mean{si}(2) short.(fname)(i,colSpeed)];
            else if short.(fname)(i,colVibFrame) >= short.(fname)(i,colFRHS2) && short.(fname)(i,colVibFrame) < short.(fname)(i,colFRHS3)
                    speedAndTargetLengthShort.(fname){si}(i,1:3) = [short.(fname)(i,colSL3) s0mean{si}(3) short.(fname)(i,colSpeed)];
                else if short.(fname)(i,colVibFrame) >= short.(fname)(i,colFRHS3) && short.(fname)(i,colVibFrame) < short.(fname)(i,colFRHS4)
                        speedAndTargetLengthShort.(fname){si}(i,1:3) = [short.(fname)(i,colSL4) s0mean{si}(4) short.(fname)(i,colSpeed)];
                    else
                        speedAndTargetLengthShort.(fname){si}(i,1:3) = [0 0 0];
                    end
                end
            end
        end
    end
    
    % Long for each stim time (st) = S1-S6 for all subjects
    for i = 1:size(long.(fname),1)
        % Check for target foot step length
        if long.(fname)(i,colVibFrame) >= long.(fname)(i,colFRHS0) && long.(fname)(i,colVibFrame) < long.(fname)(i,colFRHS1)
            speedAndTargetLengthLong.(fname){si}(i,:) = [long.(fname)(i,colSL1) s0mean{si}(1) long.(fname)(i,colSpeed)];
        else if long.(fname)(i,colVibFrame) >= long.(fname)(i,colFRHS1) && long.(fname)(i,colVibFrame) < long.(fname)(i,colFRHS2)
                speedAndTargetLengthLong.(fname){si}(i,:) = [long.(fname)(i,colSL2) s0mean{si}(2) long.(fname)(i,colSpeed)];
            else if long.(fname)(i,colVibFrame) >= long.(fname)(i,colFRHS2) && long.(fname)(i,colVibFrame) < long.(fname)(i,colFRHS3)
                    speedAndTargetLengthLong.(fname){si}(i,:) = [long.(fname)(i,colSL3) s0mean{si}(3) long.(fname)(i,colSpeed)];
                else if long.(fname)(i,colVibFrame) >= long.(fname)(i,colFRHS3) && long.(fname)(i,colVibFrame) < long.(fname)(i,colFRHS4)
                        speedAndTargetLengthLong.(fname){si}(i,:) = [long.(fname)(i,colSL4) s0mean{si}(4) long.(fname)(i,colSpeed)];
                    else
                        speedAndTargetLengthLong.(fname){si}(i,:) = [0 0 0];
                    end
                end
            end
        end
    end
end

%% Plot boxplot of absolute step length for each subject

% Changing all zeros to Nan to avoid zero inclusion to mean calculation
for i = 1:1:6
   fname = ['s',num2str(i)];
   sAll.(fname){si}(sAll.(fname){si} == 0) = NaN;
   lAll.(fname){si}(lAll.(fname){si} == 0) = NaN;
   sNorm.(fname){si}(sNorm.(fname){si} == 0) = NaN;
   lNorm.(fname){si}(lNorm.(fname){si} == 0) = NaN;
end

% Aggreggate for step long and step short
nanV = zeros(size(cell2mat(sAll.s1(si)),1),1);
nanV = NaN.*nanV;
for i = 1:1:6
    fname = ['s',num2str(i)];
    temps = cell2mat(sAll.(fname)(si)); templ = cell2mat(lAll.(fname)(si));
    
    aggAll.(fname) = [temps(:,1) templ(:,1) nanV ...
        temps(:,2) templ(:,2) nanV ...
        temps(:,3) templ(:,3) nanV ...
        temps(:,4) templ(:,4) nanV ...
        temps(:,5) templ(:,5) nanV ...
        temps(:,6) templ(:,6) nanV ...
        temps(:,7) templ(:,7)];
end

% Aggreggate boxplot
figure;
for i = 1:1:6
    fname = ['s',num2str(i)];
    f1 = subplot(3,2,i); hold on;
    plot([0 21],[mean(mean(s0{si})) mean(mean(s0{si}))],'--r','Color',red);
       
    %boxplot(eval(['target.s', num2str(i),'s']), 'Colors', purple, 'OutlierSize', 6);
    h = notBoxPlot(aggAll.(fname),'jitter',0.3,'markMedian',true); 
    set([h([1,4,7,10,13,16,19]).data],'markerfacecolor',red,'markeredgecolor','none','markersize',2);
    set([h([1,4,7,10,13,16,19]).semPtch],'FaceColor',lightPurple,'EdgeColor','none');
    set([h([1,4,7,10,13,16,19]).sdPtch],'FaceColor',darkPurple,'EdgeColor','none');
    set([h([1,4,7,10,13,16,19]).med],'Color',purple);
    set([h([1,4,7,10,13,16,19]).mu],'Color',purple);
    set([h([2,5,8,11,14,17,20]).data],'markerfacecolor',red,'markeredgecolor','none','markersize',2);
    set([h([2,5,8,11,14,17,20]).semPtch],'FaceColor',lightGold,'EdgeColor','none');
    set([h([2,5,8,11,14,17,20]).sdPtch],'FaceColor',darkGold,'EdgeColor','none');
    set([h([2,5,8,11,14,17,20]).med],'Color',xDarkGold);
    set([h([2,5,8,11,14,17,20]).mu],'Color',xDarkGold); 
    
    % Saving mean of target foot for step short and step long
    targetStride.(fname)(si,1) = h([10]).mu.YData(1);
    targetStride.(fname)(si,2) = h([11]).mu.YData(1);
    
    % Legend
    lgd = legend([h(1).sdPtch,h(1).semPtch,h(1).mu,h(1).med,...
        h(2).sdPtch,h(2).semPtch,h(2).mu,h(2).med],...
        'Short SD','Short SEM','Short Mean','Short Median',...
        'Long SD','Long SEM','Long Mean','Long Median');
    lgd.NumColumns = 2;
    lgd.TextColor = purple;
    lgd.Location = 'SouthWest';
   
    % Title and axes
%     ylim([0.4 1.8]);
    xticks([1.5 4.5 7.5 10.5 13.5 16.5 19.5]); 
    xticklabels({'T-3','T-2','T-1','Target (T)','T+1','T+2','T+3'});
    ylabel('Step length (mm)');
    title(['Stim ', num2str(i)], 'Color', purple);
    f1x = ancestor(f1, 'axes');
    f1x.TitleFontWeight = 'normal';
    f1x.FontName = 'Uni Sans Regular';
    f1x.FontSize = 8;
    f1x.YColor = purple;
    f1x.XColor = purple;
    
    % Global title
    annotation('textbox', [0 1 1 0],'String', ['Step length (mm) for Participant ', num2str(si)],...
        'EdgeColor','none','HorizontalAlignment', 'center',...
        'FontName','Uni Sans Regular','FontSize',12,'Color',purple);
end

%% Analyze speed

s0SpeedMean(si) = mean(sortS.s0(:,colSpeed));

speed{si} = [sortS.s0(:,colSpeed) sortS.s1(:,colSpeed) sortS.s2(:,colSpeed) ...
    sortS.s3(:,colSpeed) sortS.s4(:,colSpeed) sortS.s5(:,colSpeed) sortS.s6(:,colSpeed)];

speedShort{si} = [sortS.s1(1:6,colSpeed) sortS.s2(1:6,colSpeed) sortS.s3(1:6,colSpeed)...
    sortS.s4(1:6,colSpeed) sortS.s5(1:6,colSpeed) sortS.s6(1:6,colSpeed)];

speedLong{si} = [sortS.s1(7:12,colSpeed) sortS.s2(7:12,colSpeed) sortS.s3(7:12,colSpeed)...
    sortS.s4(7:12,colSpeed) sortS.s5(7:12,colSpeed) sortS.s6(7:12,colSpeed)];
end

%% ANALYSIS FOR POPULATION

%% Result 0a - Stim can make users change their stride length
% Calculate for Percent Correct and Incorrect

% Count number of correct for S0
toPercent = 100/12;
zCorSimpleCount = 0;
for subNo = 1:1:10
   zCorCount(subNo,1) = sum(s0{subNo}(:,1) > s0mean{subNo}(1))*toPercent;
   zCorCount(subNo,2) = sum(s0{subNo}(:,2) > s0mean{subNo}(2))*toPercent;
   zCorCount(subNo,3) = sum(s0{subNo}(:,3) > s0mean{subNo}(3))*toPercent;
   zCorCount(subNo,4) = sum(s0{subNo}(:,4) > s0mean{subNo}(4))*toPercent;
   zCorSimpleCount = zCorSimpleCount + sum(s0{subNo}(:,1) > s0mean{subNo}(1)) + sum(s0{subNo}(:,2) > s0mean{subNo}(2)) + sum(s0{subNo}(:,3) > s0mean{subNo}(3)) + sum(s0{subNo}(:,4) > s0mean{subNo}(4));
end
totalNoStimPercent = zCorSimpleCount/480; % total number of no stim steps are 120*4

zCorCountFlat = [zCorCount(:,1); zCorCount(:,2); zCorCount(:,3); zCorCount(:,4)];

% Count number of correct for S1-S6
toPercent = 100/6;  % convert to percent
lCorSimpleCount = zeros(1,6); % count all counts of correct step long
lTrialCount = zeros(1,6);    % total number of step long trials
sCorSimpleCount = zeros(1,6); % count all counts of correct step short
sTrialCount = zeros(1,6);    % total number of step short trials
for st = 1:1:6
    fname = ['s',num2str(st)];
    for si = 1:1:numSubject
        lTemp = cell2mat(lNorm.(fname)(si));  % lTemp is a matrix containing all the responses from Sx for subject si
        lCorCount.(fname)(1,si) = sum(lTemp(:,4)>1)*toPercent;  % Count the number of elements at target foot (column 4) that is larger than 1 (correct response)
        lCorSimpleCount(st) = lCorSimpleCount(st) + sum(lTemp(:,4)>1);
        lTrialCount(st) = lTrialCount(st) + sum(lTemp(:,4) >= 0);
        lCorCount.(fname)(2,si) = sum(lTemp(:,5)>1)*toPercent;  % Count the number of elements at T+1 (column 5) that is larger than 1 (correct response)
        lCorCount.(fname)(3,si) = sum(lTemp(:,6)>1)*toPercent;
        
        sTemp = cell2mat(sNorm.(fname)(si));  % lTemp is a matrix containing all the responses from Sx for subject si
        sCorCount.(fname)(1,si) = sum(sTemp(:,4)<1)*toPercent;  % Count the number of elements at target foot (column 4) that is smaller than 1 (correct response)
        sCorSimpleCount(st) = sCorSimpleCount(st) + sum(sTemp(:,4)<1);
        sTrialCount(st) = sTrialCount(st) + sum(sTemp(:,4) >= 0);
        sCorCount.(fname)(2,si) = sum(sTemp(:,5)<1)*toPercent;  % Count the number of elements at T+1 (column 5) that is smaller than 1 (correct response)
        sCorCount.(fname)(3,si) = sum(sTemp(:,6)<1)*toPercent;
    end
end

% How many percent all people are correct for each ST
totalLongPercentCorrect = lCorSimpleCount./lTrialCount
totalShortPercentCorrect = sCorSimpleCount./sTrialCount

% Put in matrix form for plotting of subplots
nanV = zeros(length(sCorCount.s1(1,:)),1);
nanV(nanV == 0) = NaN;
for st = 1:1:6
    fname = ['s',num2str(st)];
    aggCorCount.(fname) = [sCorCount.(fname)(1,:)' lCorCount.(fname)(1,:)' nanV ...
        sCorCount.(fname)(2,:)' lCorCount.(fname)(2,:)' nanV ...
        sCorCount.(fname)(3,:)' lCorCount.(fname)(3,:)'];
    
    meanSCorCount(st,:) = [mean(sCorCount.(fname)(1,:)) mean(sCorCount.(fname)(2,:)) mean(sCorCount.(fname)(3,:))];
    meanLCorCount(st,:) = [mean(lCorCount.(fname)(1,:)) mean(lCorCount.(fname)(2,:)) mean(lCorCount.(fname)(3,:))];
    
end

% Put in matrix form for plotting the single target foot plot
simpleCorCount = zeros(length(sCorCount.s1(1,:)),18);
nanV = zeros(length(sCorCount.s1(1,:)),1);
nanV(nanV == 0) = NaN;
for st = 1:1:6
    fname = ['s',num2str(st)];
    simpleCorCount(:,3*st-2) = sCorCount.(fname)(1,:)';
    simpleCorCount(:,3*st-1) = lCorCount.(fname)(1,:)';
    simpleCorCount(:,3*st) = nanV;
    
    simpleSCC(:,st) = sCorCount.(fname)(1,:)';
    simpleLCC(:,st) = lCorCount.(fname)(1,:)';
end

% Plot boxplot for target foot percent correct for S0-S6
N = 7;
delta = linspace(-.7,.7,N); %// define offsets to distinguish plots
width = .3; %// small width to avoid overlap
groupLabel = {'ST1', 'ST2', 'ST3', 'ST4', 'ST5', 'ST6'};
figure; hold on;
boxplot(zCorCountFlat, 'Colors',grey,'position',0.4167,'widths',width,'labels','ST0','boxstyle','filled','Symbol','kx');
plot(NaN,1,'color',grey); % Dummy plot for legend
boxplot(simpleSCC,'Colors',purple,'position',(2:N)+delta(1),'widths',width,'labels',groupLabel,'boxstyle','filled','Symbol','kx');
plot(NaN,1,'color',purple); % Dummy plot for legend
boxplot(simpleLCC,'Colors',darkGold,'position',(2:N)+delta(2),'widths',width,'labels',groupLabel,'boxstyle','filled','Symbol','kx');
plot(NaN,1,'color',darkGold); % Dummy plot for legend
f1 = plot([-0.2 100],[50 50],'--r');

% Legend
lgd = legend('No Stim','Step Shorter','Step Longer');
lgd.NumColumns = 1;
% lgd.TextColor = purple;
lgd.Location = 'SouthWest';

% Title and axes
uistack(f1,'bottom');
xlim([-0.2 7.0333]);
xlabel('Stimulation time');
ylim([-5 115]);
ylabel('Instances of correct stride change (%)');
% title('Percent correct directional stride length changes of target foot (T) (n=10)'); %,'Color',purple);
f1x = ancestor(f1, 'axes');
f1x.TitleFontWeight = 'normal';
f1x.TitleFontSizeMultiplier = 1.5;
f1x.FontName = 'Uni Sans Regular';
f1x.FontSize = 10;
% f1x.YColor = purple;
% f1x.XColor = purple;
xticks([0.4167 ((2:N)+delta(1) + (2:N)+delta(2))./2]);
f1x.XTickLabel = {'ST0', 'ST1', 'ST2', 'ST3', 'ST4', 'ST5', 'ST6'};
yticks([0 10 20 30 40 50 60 70 80 90 100]);
f1x.YTickLabel = {'0', '10', '20', '30', '40', '50', '60', '70', '80', '90', '100'};
% addpath('./export_fig_folder/')
% save_path = './Figures';
% export_fig(save_path, '-png', '-eps', '-transparent', '-q95');

%% Result 1 is below Results 2
%% Result 2a - Stim has collateral effects on subsequent strides after target T
% Plot boxplot of normalized step length for all subjects

% Initialization
for i = 1:1:6
    fname = ['s',num2str(i)];
    sNormAll.(fname) = [];
    lNormAll.(fname) = [];
end

% Combining normalized step lenghts of all subjects into a big array for
% each S condition.
for si = 1:1:numSubject
    for i = 1:1:6
        fname = ['s',num2str(i)];
        sNormAll.(fname) = [sNormAll.(fname); sNorm.(fname){si}];
        lNormAll.(fname) = [lNormAll.(fname); lNorm.(fname){si}];
    end
end

% Aggreggate for step long and step short
nanV = zeros(size(sNormAll.s1(:,1),1),size(sNormAll.s1(:,1),2));
nanV = NaN.*nanV;
for i = 1:1:6
    fname = ['s',num2str(i)];
    aggNormAll.(fname) = [sNormAll.(fname)(:,2) lNormAll.(fname)(:,2) nanV ...
        sNormAll.(fname)(:,3) lNormAll.(fname)(:,3) nanV ...
        sNormAll.(fname)(:,4) lNormAll.(fname)(:,4) nanV ...
        sNormAll.(fname)(:,5) lNormAll.(fname)(:,5) nanV ...
        sNormAll.(fname)(:,6) lNormAll.(fname)(:,6)];
end

% Aggregate boxplot
figure;
N = 4;
delta = linspace(-.4,.4,N); %// define offsets to distinguish plots
width = .3; %// small width to avoid overlap
groupLabel = {'T-2', 'Target (T)', 'T+2', 'T+4'};
for i = 1:1:6
    fname = ['s',num2str(i)];
    f1 = subplot(2,3,i,'position',posMatrix2by3(i,:)); hold on;
    boxplot([sNormAll.(fname)(:,3) sNormAll.(fname)(:,4) sNormAll.(fname)(:,5) sNormAll.(fname)(:,6)], ...
        'Colors',purple,'position',(1:N)+delta(1),'widths',width,'labels', groupLabel,'boxstyle','filled','Symbol','kx');
    plot(NaN,1,'color',purple); % Dummy plot for legend
    boxplot([lNormAll.(fname)(:,3) lNormAll.(fname)(:,4) lNormAll.(fname)(:,5) lNormAll.(fname)(:,6)], ...
        'Color',darkGold,'position',(1:N)+delta(2),'widths',width,'labels', groupLabel,'boxstyle','filled','Symbol','kx');
    plot(NaN,1,'color',darkGold); % Dummy plot for legend
    f2 = plot([0 20],[1 1],'--r');

    % Legend
    lgd = legend('Step Shorter','Step Longer');
    lgd.NumColumns = 1;
%     lgd.TextColor = purple;
    lgd.Location = 'SouthWest';
    
    % Title and axes
    uistack(f2,'bottom');
    ylim([0.3 1.75]);
    ylabel('Norm. right stride length');
    title(['Stimulation Time (ST) ', num2str(i)]); %, 'Color', purple);
    f1x = ancestor(f1, 'axes');
    f1x.TitleFontWeight = 'bold';
    f1x.FontName = 'Uni Sans Regular';
    f1x.FontSize = 10;
%     f1x.YColor = purple;
%     f1x.XColor = purple;
    
%     % Global title
%     annotation('textbox', [0 1 1 0],'String', 'Normalized right stride length for n=10 (box plot)',...
%         'EdgeColor','none','HorizontalAlignment', 'center',...
%         'FontName','Uni Sans Regular','FontSize',15,'Color',purple);
end

%% Result 2b - T-test

% t-test for step short
ps = zeros(6,6);
for st = 1:1:6
    fname = ['s',num2str(st)];
    tm2 = aggNormAll.(fname)(:,1);
    tm1 = aggNormAll.(fname)(:,4);
    t = aggNormAll.(fname)(:,7);
    tp1 = aggNormAll.(fname)(:,10);
    tp2 = aggNormAll.(fname)(:,13);
    
    [p1,h1] = ttest2(tm1, t);   % T-2 and T
    [p2,h2] = ttest2(tm1, tp1); % T-2 and T+1
    [p3,h3] = ttest2(tm1, tp2); % T-2 and T+2
    ps(st,:) = [p1 h1 p2 h2 p3 h3];
end

% t-test for step long
pl = zeros(6,6);
for st = 1:1:6
    fname = ['s',num2str(st)];
    tm2 = aggNormAll.(fname)(:,2);
    tm1 = aggNormAll.(fname)(:,5);
    t = aggNormAll.(fname)(:,8);
    tp1 = aggNormAll.(fname)(:,11);
    tp2 = aggNormAll.(fname)(:,14);
    
    [p1,h1] = ttest2(tm1, t);   % T-2 and T
    [p2,h2] = ttest2(tm1, tp1); % T-2 and T+1
    [p3,h3] = ttest2(tm1, tp2); % T-2 and T+2
    pl(st,:) = [p1 h1 p2 h2 p3 h3];
end

%% Result 1 - S1, S2, and (S3) can change stride length of target foot wrt average (1)
% Boxplot of only target foot for S1-S6

for i = 1:1:6
    fname = ['s',num2str(i)];
    sNormTarget(:,i) = sNormAll.(fname)(:,4);
    lNormTarget(:,i) = lNormAll.(fname)(:,4); 
end

N = 6;
delta = linspace(-.7,.7,N); %// define offsets to distinguish plots
width = .3; %// small width to avoid overlap
groupLabel = {'ST1','ST2','ST3','ST4','ST5','ST6'};
figure; hold on;
boxplot(sNormTarget,'Colors',purple,'position',(1:N)+delta(1),'widths',width,'labels', groupLabel,'boxstyle','filled','Symbol','kx');
plot(NaN,1,'color',purple); % Dummy plot for legend
boxplot(lNormTarget,'Color',darkGold,'position',(1:N)+delta(2),'widths',width,'labels', groupLabel,'boxstyle','filled','Symbol','kx');
plot(NaN,1,'color',darkGold); % Dummy plot for legend
f1 = plot([-0.2 20],[1 1],'--r');
   
% Legend
lgd = legend('Step Shorter','Step Longer');
lgd.NumColumns = 1;
% lgd.TextColor = purple;
lgd.Location = 'NorthEast';
    
% Title and axes
xticks(((1:N)+delta(1) + (1:N)+delta(2))./2);
xlim([-0.2 6.08]);
ylim([0.5 1.5]);
uistack(f1,'bottom');
xlabel('Stimulation time');
ylabel('Normalized right stride length');
% title('Normalized right stride length of target foot (T) (n=10, box plot)'); %, 'Color', purple);
f1x = ancestor(f1, 'axes');
f1x.TitleFontWeight = 'normal';
f1x.TitleFontSizeMultiplier = 1.5;
f1x.FontName = 'Uni Sans Regular';
f1x.FontSize = 10;
% f1x.YColor = purple;
% f1x.XColor = purple;

%% Result 5a - Plot boxplot of S0 step length for all subjects

s0All1 = s0{1}(:,1);
s0All2 = s0{1}(:,2);
s0All3 = s0{1}(:,3);
s0All4 = s0{1}(:,4);

for i = 2:1:10
    s0All1 = [s0All1; s0{i}(:,1)];
    s0All2 = [s0All2; s0{i}(:,2)];
    s0All3 = [s0All3; s0{i}(:,3)];
    s0All4 = [s0All4; s0{i}(:,4)];
end

% S0 for all individuals combined
figure; hold on;
boxplot([s0All1 s0All2 s0All3 s0All4],'Colors',purple,'boxstyle','filled','Symbol','kx');
f1 = plot([0 5],[median(s0All1) median(s0All1)], '--r'); 
grid on;
    
% Title and axes
uistack(f1,'bottom');
xlabel('Right stride index');
yticks([1100 1200 1300 1400 1500 1600]);
ylabel('Stride length (SL) (mm)');
% title('Normalized right stride length of target foot (T) (n=10, box plot)'); %, 'Color', purple);
f1x = ancestor(f1, 'axes');
f1x.TitleFontWeight = 'normal';
f1x.TitleFontSizeMultiplier = 1.5;
f1x.FontName = 'Uni Sans Regular';
f1x.FontSize = 10;
% f1x.YColor = purple;
% f1x.XColor = purple;

%% Result 5b - Speed analysis for all trials instead of just the mean

for figI = 1:1:2
figure;
for st = 1:1:6
    fname = ['s' num2str(st)];
    
    % Flattening the cell that contains col1: stride length, col2: mean
    % stride length for that trial, col3: speed for that trial
    oldtemps = cell2mat(speedAndTargetLengthShort.(fname)');
    oldtempl = cell2mat(speedAndTargetLengthLong.(fname)');
    
    % Removing all the zero values to avoid division by zero and invalid
    % trials
    oldtemps(oldtemps == 0) = NaN;
    oldtempl(oldtempl == 0) = NaN;
    for j = 1:3
        A = oldtemps(:,j);
        A(isnan(A)) = [];
        old2temps(:,j) = A;
        
        B = oldtempl(:,j);
        B(isnan(B)) = [];
        old2templ(:,j) = B;
    end
    
    selectOnlyCollectTrials = 0;    % toggle to 1 if we want to remove all the wrong trials
    
    if selectOnlyCollectTrials
        % Selecting only the correct trials
        count = 1;
        for i = 1:length(old2temps)
            if old2temps(i,2) - old2temps(i,1) > 0
                temps(count,:) = old2temps(i,:);
                count = count + 1;
            end
        end
        
        count = 1;
        for i = 1:length(old2templ)
            if old2templ(i,1) - old2templ(i,2) > 0
                templ(count,:) = old2templ(i,:);
                count = count + 1;
            end
        end
    else
        temps = old2temps;
        templ = old2templ;
    end
    
    % This is how we format the presentation style of the stride length in
    % the y-axis.
    % Over here I am taking the absolute delta between actual stride length
    % and mean stride length (amount of adjustment), normalized over mean
    % stride length of that trial. Hence normalized adjustment values for
    % that particular trial.
%     divS = (temps(:,1))./temps(:,2);
%     divL = (templ(:,1))./templ(:,2);
    divS = abs(temps(:,2) - temps(:,1))./temps(:,2);
    divL = abs(templ(:,1) - templ(:,2))./templ(:,2);
    
        
    % Plotting for step shorter and step longer combined
    if figI == 1
        f0 = subplot(2,3,st,'position',posMatrix2by3(st,:));
        plot([temps(:,3); templ(:,3)],[divS; divL],'.');
        %         f = fit([temps(:,3); templ(:,3)],[divS; divL], 'poly1');
        mdlsB{st} = fitlm([temps(:,3); templ(:,3)],[divS; divL], 'linear', 'RobustOpts', 'on');
        ta = anova(mdlsB{st},'summary');
        anovaSB(st) = table2array(ta(2,5));
        plot(mdlsB{st});
        % Plotting for step shorter only
    else if figI == 2
            posMatrix2by6 = [0.05 0.59 0.14 0.37;
                0.20 0.59 0.14 0.37;
                0.35 0.59 0.14 0.37;
                0.50 0.59 0.14 0.37;
                0.65 0.59 0.14 0.37;
                0.80 0.59 0.14 0.37;
                0.05 0.08 0.14 0.37;
                0.20 0.08 0.14 0.37;
                0.35 0.08 0.14 0.37;
                0.50 0.08 0.14 0.37;
                0.65 0.08 0.14 0.37;
                0.80 0.08 0.14 0.37];

            f0 = subplot(2,6,st,'position',posMatrix2by6(st,:));
            %             plot(temps(:,3), divS,'.','Color',purple); hold on;
            %             f = fit(temps(:,3), divS, 'poly1');
            %             plot(f, temps(:,3), divS);
            mdlsS{st} = fitlm(temps(:,3), divS, 'linear', 'RobustOpts', 'on');
            ta = anova(mdlsS{st},'summary');
            anovaSS(st) = table2array(ta(2,5));
            f1 = plot(mdlsS{st});
            
            h = plotAdded(mdlsS{st});
            h(1).Color = darkPurple;
            h(1).Marker = '.';
            h(2).Color = purple;
            h(2).LineWidth = 1.5;
            h(3).Color = purple;
            h(3).LineWidth = 1.5;
            
            anovaTit = {'*p = 0.0007', 'p = 0.112', '*p = 0.005', '*p = 0.0006', '*p = 0.006', 'p = 0.189'};
            
            title(['ST', num2str(st), '  (', anovaTit{st}, ')']);
            xlabel('Speed (m/s)');
            hx = ancestor(h,'axes');
            hx{3}.Legend.String{1} = ['One Trial Datapoint'];
            %             hx{3}.Legend.String{2} = ['Fit'];
            hx{3}.Legend.String{3} = ['95% Conf. Bounds'];
%             hx{3}.Legend.Location = 'NorthEast';
            hx{3}.Legend.FontSize = 10;
            if st == 1
                ylabel('STEP SHORTER: Norm. \Delta SL', 'Interp','tex');
                yticks([0 0.1 0.2 0.3 0.4 0.5]);
                yticklabels({'0','0.1','0.2','0.3','0.4','0.5'});
            else
                ylabel('');
                yticks([0 0.1 0.2 0.3 0.4 0.5]);
                yticklabels('');
            end
            
            xlim([0.8 1.5]);
            xticks([0.9 1.15 1.4]);
            
            ylim([0 0.5]);
            f0x = ancestor(f0,'axes');
            f0x.FontName = 'Uni Sans Regular';
            f0x.FontSize = 10;
            
            % Plotting for step longer only
            f0 = subplot(2,6,st+6,'position',posMatrix2by6(st+6,:));
            %                 plot(templ(:,3), divL,'.','Color',xDarkGold);
            %                 f1 = fit(templ(:,3), divL, 'poly1');
            %                 fdata = feval(f1, templ(:,3));
            %                 I = abs(fdata - divL) > 1.5*std(divL);
            %                 outliers = excludedata(templ(:,3), divL, 'indices', I);
            %                 f = fit(templ(:,3), divL, 'poly1', 'Exclude', outliers);
            %                 plot(f, templ(:,3), divL);
            mdlsL{st} = fitlm(templ(:,3), divL, 'linear', 'RobustOpts', 'on');
            ta = anova(mdlsL{st},'summary');
            anovaSL(st) = table2array(ta(2,5));
            f1 = plot(mdlsL{st}); %,'Color',xDarkGold,'Marker','.','MarkerFaceColor',purple);
            
            h = plotAdded(mdlsL{st});
            h(1).Color = darkGold;
            h(1).Marker = '.';
            h(2).Color = xDarkGold;
            h(2).LineWidth = 1.5;
            h(3).Color = xDarkGold;
            h(3).LineWidth = 1.5;
            
            anovaTit = {'*p = 0.012', 'p = 0.185', '*p = 0.012', '**p < 0.0001', '*p = 0.001', '*p = 0.027'};
            
            title(['ST', num2str(st), '  (', anovaTit{st}, ')']);
            xlabel('Speed (m/s)');
%             annotation('textbox','String','y=-0.013504*x','FitBoxToText','on');
            
            hx = ancestor(h,'axes');
            hx{3}.Legend.String{1} = ['One Trial Datapoint'];
            %             hx{3}.Legend.String{2} = ['Fit'];
            hx{3}.Legend.String{3} = ['95% Conf. Bounds'];
%             hx{3}.Legend.Location = 'NorthEast';
            hx{3}.Legend.FontSize = 10;
            if st == 1
                ylabel('STEP LONGER: Norm. \Delta SL', 'Interp','tex');
                yticks([0 0.1 0.2 0.3 0.4 0.5]);
                yticklabels({'0','0.1','0.2','0.3','0.4','0.5'});
            else
                ylabel('');
                yticks([0 0.1 0.2 0.3 0.4 0.5]);
                yticklabels('');
            end
            
            xlim([0.8 1.5]);
            xticks([0.9 1.15 1.4]);
            
            ylim([0 0.5]);
            f0x = ancestor(f0,'axes');
            f0x.FontName = 'Uni Sans Regular';
            f0x.FontSize = 10;
            
        end
    end
    clear temps templ old2temps old2templ;
end
end

%% Result 6 - Qualitative

q1 = [2 3 3 2 4 4 4 2 2 4];
q2 = [1 3 2 3 2 3 2 3 2 3];
q3 = [1 1 2 1 2 3 2 2 1 2];
q4 = [2 3 2 2 4 3 2 4 2 3];
q5 = [4 3 4 4 4 4 3 4 4 4];
q6 = [5 3 3 4 5 3 3 4 4 4];
q7 = [4 3 3 2 4 3 2 4 4 4];

qMean = [mean(q1) mean(q2) mean(q3) mean(q4) mean(q5) mean(q6) mean(q7)];
qStd = [std(q1) std(q2) std(q3) std(q4) std(q5) std(q6) std(q7)];

figure;
boxplot([q1' q2' q3' q4' q5' q6' q7'],'Color','g','widths',width,'boxstyle','filled','Symbol','kx');
hold on;
f1 = plot([0 8],[3 3],'--r');

uistack(f1,'bottom');
ylabel('Participant response (Likert scale)');
xlabel('Question');
xticklabels({'Q1', 'Q2', 'Q3', 'Q4', 'Q5', 'Q6', 'Q7'});
f1x = ancestor(f1, 'axes');
f1x.TitleFontWeight = 'normal';
f1x.FontName = 'Uni Sans Regular';
f1x.FontSize = 10;

qAll = [q1' q2' q3' q4' q5' q6' q7'];