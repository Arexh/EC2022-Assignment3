%% Add Outside Path
addpath(genpath('../..'));
%% Table 1
%% Init Variables
Caption = 'Average Peak Ratios and Success Ratios Over Five Accuricies';
LowLogNames = {'baseline', 'mPSO_penalty', 'mPSO_feasible', 'mPSO_hybrid'};
MidLogNames = {'baseline_400000', 'mPSO_penalty_400000', 'mPSO_feasible_400000', 'mPSO_hybrid_400000'};
HighLogNames = {'baseline_400000_dim', 'mPSO_penalty_400000_dim', 'mPSO_feasible_400000_dim', 'mPSO_hybrid_400000_dim'};
LogNames = {LowLogNames, MidLogNames, HighLogNames};
TitleNames = {'Baseline', 'mPSO-P', 'mPSO-F', 'mPSO-H'};
ProblemNumbers = [1:18];
%% Render Latex Table
LatexTable = Utils.AverageTable(Caption, LogNames, TitleNames, ProblemNumbers);
%% Print Table Content
disp(LatexTable);
%% Write Into File
Utils.WriteFile(fullfile('../../RESULTS', 'AverageTable.tex'), LatexTable);