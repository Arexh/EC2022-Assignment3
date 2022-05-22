%% Add Outside Path
addpath(genpath('../..'));
%% Table 1
%% Init Variables
Caption = 'Comparasion Betweem mPSO-F and mPSO-H, High Evaluations, 32 Runs';
LogNames = {'mPSO_feasible_400000_dim', 'mPSO_hybrid_400000_dim'};
TitleNames = {'mPSO-F', 'mPSO-H'};
%% Render Latex Table
LatexTable = Utils.CompareTwoResults(Caption, LogNames, TitleNames);
%% Print Table Content
disp(LatexTable);
%% Write Into File
Utils.WriteFile(fullfile('../../RESULTS', 'mPSOFeasibleVSmPSOHybrid400000.tex'), LatexTable);

%% Table 2
%% Init Variables
Utils.WriteFile(fullfile('../../RESULTS', 'mPSOFeasibleVSmPSOHybrid400000.tex'), LatexTable);
Caption = 'Comparasion Betweem Baseline and mPSO-H, High Evaluations, 32 Runs';
LogNames = {'baseline_400000_dim', 'mPSO_hybrid_400000_dim'};
TitleNames = {'Baseline', 'mPSO-H'};
%% Render Latex Table
LatexTable = Utils.CompareTwoResults(Caption, LogNames, TitleNames);
%% Print Table Content
disp(LatexTable);
%% Write Into File
Utils.WriteFile(fullfile('../../RESULTS', 'BaselineVSmPSOHybrid400000.tex'), LatexTable);