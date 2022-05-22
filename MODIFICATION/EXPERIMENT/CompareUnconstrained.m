%% Add Outside Path
addpath(genpath('../..'));
%% Init Variables
Caption = 'Comparasion Between mPSO and Baseline on Unconstrained Benchmark, Low Evalutions, $\sigma=0.00001$, 32 Runs';
LogNames = {'baseline_non_constrained', 'mPSO_non_constrained'};
TitleNames = {'Baseline', 'mPSO'};
%% Render Latex Table
LatexTable = Utils.CompareUnconstrained(Caption, LogNames, TitleNames);
%% Print Table Content
disp(LatexTable);
%% Write Into File
Utils.WriteFile(fullfile('../../RESULTS', 'CompareUnconstrained.tex'), LatexTable);