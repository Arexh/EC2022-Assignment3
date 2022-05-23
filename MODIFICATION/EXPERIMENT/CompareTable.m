%% Add Outside Path
addpath(genpath('../..'));
%% Table 1
%% Init Variables
Caption = 'Comparasion Betweem mPSO-F and mPSO-H, High Evaluations, 32 Runs';
LogNames = {'mPSO_F_High', 'mPSO_H_High'};
TitleNames = {'mPSO-F', 'mPSO-H'};
LabelName = 'mpsofvsmpsohhigh';
%% Render Latex Table
LatexTable = Utils.CompareTwoResults(Caption, LogNames, TitleNames, LabelName);
%% Print Table Content
disp(LatexTable);
%% Write Into File
Utils.WriteFile(fullfile('../../RESULTS', 'mPSOFeasibleVSmPSOHybridHigh.tex'), LatexTable);

%% Table 2
%% Init Variables
Utils.WriteFile(fullfile('../../RESULTS', 'mPSOFeasibleVSmPSOHybridHigh.tex'), LatexTable);
Caption = 'Comparasion Betweem Baseline and mPSO-H, High Evaluations, 32 Runs';
LogNames = {'Baseline_High', 'mPSO_H_High'};
TitleNames = {'Baseline', 'mPSO-H'};
LabelName = 'baselinevsmpsohhigh';
%% Render Latex Table
LatexTable = Utils.CompareTwoResults(Caption, LogNames, TitleNames, LabelName);
%% Print Table Content
disp(LatexTable);
%% Write Into File
Utils.WriteFile(fullfile('../../RESULTS', 'BaselineVSmPSOHybridHigh.tex'), LatexTable);