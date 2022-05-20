%% Add Outside Path
addpath(genpath('../..'));
%% Table 1
%% Init Variables
Caption = 'Average Peak Ratio and Average Success Ratio, 400000 Evaluations, 32 Runs';
LogNames = {'baseline_400000', 'mPSO_hybrid_400000'};
TitleNames = {'Baseline', 'mPSO-H'};
%% Render Latex Table
LatexTable = Utils.CompareTwoResults(Caption, LogNames, TitleNames);
%% Print Table Content
disp(LatexTable);
%% Write Into File
Utils.WriteFile(fullfile('../../RESULTS', 'BaselineVSmPSOHybrid400000.tex'), LatexTable);

%% Table 2
%% Init Variables
Caption = 'Average Peak Ratio and Average Success Ratio, 400000 Evaluations, 32 Runs';
LogNames = {'mPSO_feasible_400000', 'mPSO_hybrid_400000'};
TitleNames = {'mPSO-F', 'mPSO-H'};
%% Render Latex Table
LatexTable = Utils.CompareTwoResults(Caption, LogNames, TitleNames);
%% Print Table Content
disp(LatexTable);
%% Write Into File
Utils.WriteFile(fullfile('../../RESULTS', 'mPSOFeasibleVSmPSOHybrid400000.tex'), LatexTable);