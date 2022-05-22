%% Add Outside Path
addpath(genpath('../..'));
%% Table 1
%% Init Variables
Caption = 'Average Peak Ratio and Success Ratio in All Functions, Low Evaluations, 32 Runs';
LogNames = {'baseline', 'mPSO_penalty', 'mPSO_adaptive', 'mPSO_feasible', 'mPSO_hybrid'};
TitleNames = {'Baseline', 'mPSO-P', 'mPSO-A', 'mPSO-F', 'mPSO-H'};
%% Render Latex Table
LatexTable = Utils.CompareLowEvaluations(Caption, LogNames, TitleNames);
%% Print Table Content
disp(LatexTable);
%% Write Into File
Utils.WriteFile(fullfile('../../RESULTS', 'CompareLowEvaluations.tex'), LatexTable);