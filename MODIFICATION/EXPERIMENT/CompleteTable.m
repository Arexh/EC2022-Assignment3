%% Add Outside Path
addpath(genpath('../..'));
%% Table 1
%% Init Variables
Caption = 'Low Evaluations, 32 Runs';
LogNames = {'baseline', 'mPSO_penalty', 'mPSO_adaptive', 'mPSO_feasible', 'mPSO_hybrid'};
TitleNames = {'Baseline', 'mPSO-P', 'mPSO-A', 'mPSO-F', 'mPSO-H'};
%% Render Latex Table
LatexTable = Utils.CompleteTable(Caption, LogNames, TitleNames);
%% Print Table Content
disp(LatexTable);
%% Write Into File
Utils.WriteFile(fullfile('../../RESULTS', 'LowEvals.tex'), LatexTable);

%% Table 2
%% Init Variables
Caption = 'Mid Evaluations, 32 Runs';
LogNames = {'baseline_400000', 'mPSO_penalty_400000', 'mPSO_adaptive_400000', 'mPSO_feasible_400000', 'mPSO_hybrid_400000'};
TitleNames = {'Baseline', 'mPSO-P', 'mPSO-A', 'mPSO-F', 'mPSO-H'};
%% Render Latex Table
LatexTable = Utils.CompleteTable(Caption, LogNames, TitleNames);
%% Print Table Content
disp(LatexTable);
%% Write Into File
Utils.WriteFile(fullfile('../../RESULTS', 'MidEvals.tex'), LatexTable);

%% Table 3
%% Init Variables
Caption = 'High Evaluations, 32 Runs';
LogNames = {'baseline_400000_dim', 'mPSO_penalty_400000_dim', 'mPSO_adaptive_400000_dim', 'mPSO_feasible_400000_dim', 'mPSO_hybrid_400000_dim'};
TitleNames = {'Baseline', 'mPSO-P', 'mPSO-A', 'mPSO-F', 'mPSO-H'};
%% Render Latex Table
LatexTable = Utils.CompleteTable(Caption, LogNames, TitleNames);
%% Print Table Content
disp(LatexTable);
%% Write Into File
Utils.WriteFile(fullfile('../../RESULTS', 'HighEvals.tex'), LatexTable);