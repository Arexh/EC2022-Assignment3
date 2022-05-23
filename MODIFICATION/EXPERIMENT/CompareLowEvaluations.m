%% Add Outside Path
addpath(genpath('../..'));
%% Table 1
%% Init Variables
Caption = 'Low Evaluations, 32 Runs';
LogNames = {'Baseline_Low', 'mPSO_P_Low', 'mPSO_A_Low', 'mPSO_F_Low', 'mPSO_H_Low'};
TitleNames = {'Baseline', 'mPSO-P', 'mPSO-A', 'mPSO-F', 'mPSO-H'};
LabelName = 'lowaverage';
%% Render Latex Table
LatexTable = Utils.CompareLowEvaluations(Caption, LogNames, TitleNames, LabelName);
%% Print Table Content
disp(LatexTable);
%% Write Into File
Utils.WriteFile(fullfile('../../RESULTS', 'CompareLowEvaluations.tex'), LatexTable);