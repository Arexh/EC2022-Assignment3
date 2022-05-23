%% Add Outside Path
addpath(genpath('../..'));
%% Table 1
%% Init Variables
Caption = 'Average Peak Ratios and Success Ratios Over Five Accuricies';
LowLogNames = {'Baseline_Low', 'mPSO_P_Low', 'mPSO_F_Low', 'mPSO_H_Low'};
MidLogNames = {'Baseline_Mid', 'mPSO_P_Mid', 'mPSO_F_Mid', 'mPSO_H_Mid'};
HighLogNames = {'Baseline_High', 'mPSO_P_High', 'mPSO_F_High', 'mPSO_H_High'};
LogNames = {LowLogNames, MidLogNames, HighLogNames};
TitleNames = {'Baseline', 'mPSO-P', 'mPSO-F', 'mPSO-H'};
ProblemNumbers = [5:10 12 14 15];
LabelName = 'pickfunctions';
%% Render Latex Table
LatexTable = Utils.AverageTable(Caption, LogNames, TitleNames, ProblemNumbers, LabelName);
%% Print Table Content
disp(LatexTable);
%% Write Into File
Utils.WriteFile(fullfile('../../RESULTS', 'AverageTable.tex'), LatexTable);