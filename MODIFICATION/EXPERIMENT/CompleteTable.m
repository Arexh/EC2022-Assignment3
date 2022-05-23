%% Add Outside Path
addpath(genpath('../..'));
%% Table 1
%% Init Variables
Caption = 'Low Evaluations, 32 Runs';
LogNames = {'Baseline_Low', 'mPSO_P_Low', 'mPSO_A_Low', 'mPSO_F_Low', 'mPSO_H_Low'};
TitleNames = {'Baseline', 'mPSO-P', 'mPSO-A', 'mPSO-F', 'mPSO-H'};
LabelName = 'lowevaluations';
%% Render Latex Table
LatexTable = Utils.CompleteTable(Caption, LogNames, TitleNames, LabelName);
%% Print Table Content
disp(LatexTable);
%% Write Into File
Utils.WriteFile(fullfile('../../RESULTS', 'LowEvals.tex'), LatexTable);

%% Table 2
%% Init Variables
Caption = 'Mid Evaluations, 32 Runs';
LogNames = {'Baseline_Mid', 'mPSO_P_Mid', 'mPSO_A_Mid', 'mPSO_F_Mid', 'mPSO_H_Mid'};
TitleNames = {'Baseline', 'mPSO-P', 'mPSO-A', 'mPSO-F', 'mPSO-H'};
LabelName = 'midevaluations';
%% Render Latex Table
LatexTable = Utils.CompleteTable(Caption, LogNames, TitleNames, LabelName);
%% Print Table Content
disp(LatexTable);
%% Write Into File
Utils.WriteFile(fullfile('../../RESULTS', 'MidEvals.tex'), LatexTable);

%% Table 3
%% Init Variables
Caption = 'High Evaluations, 32 Runs';
LogNames = {'Baseline_High', 'mPSO_P_High', 'mPSO_A_High', 'mPSO_F_High', 'mPSO_H_High'};
TitleNames = {'Baseline', 'mPSO-P', 'mPSO-A', 'mPSO-F', 'mPSO-H'};
LabelName = 'highevaluations';
%% Render Latex Table
LatexTable = Utils.CompleteTable(Caption, LogNames, TitleNames, LabelName);
%% Print Table Content
disp(LatexTable);
%% Write Into File
Utils.WriteFile(fullfile('../../RESULTS', 'HighEvals.tex'), LatexTable);