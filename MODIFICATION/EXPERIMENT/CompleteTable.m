%% Add Outside Path
addpath(genpath('../..'));
%% Table 1
%% Init Variables
Caption = '400000 Evaluations, 32 Runs';
LogNames = {'baseline_400000', 'mPSO_penalty_400000', 'mPSO_adaptive_400000', 'mPSO_feasible_400000', 'mPSO_hybrid_400000'};
TitleNames = {'Baseline', 'mPSO-P', 'mPSO-A', 'mPSO-F', 'mPSO-H'};
%% Render Latex Table
LatexTable = Utils.CompleteTable(Caption, LogNames, TitleNames);
%% Print Table Content
disp(LatexTable);
%% Write Into File
% Utils.WriteFile(fullfile('../../RESULTS', 'BaselineVSmPSOHybrid400000.tex'), LatexTable);