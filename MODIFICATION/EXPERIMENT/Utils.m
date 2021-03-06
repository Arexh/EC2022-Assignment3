%% Util Functions
classdef Utils
    methods(Static)
        function CurrentSummary = GetSummary(LogPathName)
            RunNumber = 32;
            CurrentSummary = Summary(LogPathName, RunNumber);
            CurrentSummary.LogPath = fullfile('..', '..', 'logs', LogPathName);
            CurrentSummary.DFile = fullfile(CurrentSummary.LogPath, 'main.log');
            diary off;
        end

        function LatexTable = CompareTwoResults(Caption, LogNames, TitleNames, LabelName)
            ProblemNumber = 18;
            PeakRatios = NaN(2, ProblemNumber, 5);
            SuccessRatios = NaN(2, ProblemNumber, 5);
            PeakRatioStat = NaN(ProblemNumber, 5);
            AveragePeakRatios = NaN(2, 5);
            AverageSuccessRatios = NaN(2, 5);
            CurrentSummarys = cell(1, 2);
            for LogIndex = 1:length(LogNames)
                CurrentSummary = Utils.GetSummary(LogNames{LogIndex});
                CurrentSummary.ReadDataFromFiles();
                CurrentSummarys{1, LogIndex} = CurrentSummary;
                for ProblemNumberIndex = 1:size(PeakRatios, 2)
                    for AccuracyIndex = 1:size(PeakRatios, 3)
                        PeakRatios(LogIndex, ProblemNumberIndex, AccuracyIndex) = mean(CurrentSummary.FoundedPeaks(ProblemNumberIndex, :, AccuracyIndex));
                        SuccessRatios(LogIndex, ProblemNumberIndex, AccuracyIndex) = mean(CurrentSummary.FoundedPeaks(ProblemNumberIndex, :, AccuracyIndex) == 1);
                    end
                end
                for AccuracyIndex = 1:size(PeakRatios, 3)
                    AveragePeakRatios(LogIndex, AccuracyIndex) = mean(CurrentSummary.FoundedPeaks(:, :, AccuracyIndex), 'all');
                    AverageSuccessRatios(LogIndex, AccuracyIndex) = mean(CurrentSummary.FoundedPeaks(:, :, AccuracyIndex) == 1, 'all');
                end
            end
            for ProblemNumberIndex = 1:size(PeakRatios, 2)
                for AccuracyIndex = 1:size(PeakRatios, 3)
                    [PeakRatioStat(ProblemNumberIndex, AccuracyIndex), ~, ~, stat] = ttest2(CurrentSummarys{1, 1}.FoundedPeaks(ProblemNumberIndex, :, AccuracyIndex), CurrentSummarys{1, 2}.FoundedPeaks(ProblemNumberIndex, :, AccuracyIndex), 0.05, 'both');
                end
            end

            %% Print Latex Table
            LatexTable = "";
            LatexTable = LatexTable + sprintf('\\begin{table*}[h]\n');
            LatexTable = LatexTable + sprintf('  \\scriptsize\n');
            LatexTable = LatexTable + sprintf('  \\caption{%s}\n', Caption);
            LatexTable = LatexTable + sprintf('  \\noindent\\makebox[\\textwidth]{\n');
            LatexTable = LatexTable + sprintf('  \\begin{tabular}{|p{4.8mm}|p{4.6mm}|p{4.6mm}|p{4.6mm}|p{4.6mm}|p{4.6mm}|p{4.6mm}|p{4.6mm}|p{4.6mm}|p{4.6mm}|p{4.6mm}|p{4.6mm}|p{4.6mm}|p{4.6mm}|p{4.6mm}|p{4.6mm}|p{4.6mm}|p{4.6mm}|p{4.6mm}|p{4.6mm}|p{4.6mm}|}\n');
            for i = 1:3
                LatexTable = LatexTable + sprintf('    \\hline\n');
                LatexTable = LatexTable + sprintf('    \\multirow{3}{*}{$\\epsilon$}');
                for j = (i-1)*5+1:i*5
                    LatexTable = LatexTable + sprintf(' & \\multicolumn{4}{c|}{$F_{%d}$}', j);
                end
                LatexTable = LatexTable + sprintf(' \\\\\n');
                LatexTable = LatexTable + sprintf('\n    \\cline{2-21}\n');
                LatexTable = LatexTable + sprintf('   ');
                for j = 1:5
                    LatexTable = LatexTable + sprintf(' & \\multicolumn{2}{c|}{%s} & \\multicolumn{2}{c|}{%s}', TitleNames{1}, TitleNames{2});
                end
                LatexTable = LatexTable + sprintf(' \\\\\n');
                LatexTable = LatexTable + sprintf('\n    \\cline{2-21}\n');
                LatexTable = LatexTable + sprintf('    ');
                for j = 1:10
                    LatexTable = LatexTable + sprintf(' & \\multicolumn{1}{c|}{PR} & SR');
                end
                LatexTable = LatexTable + sprintf(' \\\\\n');
                LatexTable = LatexTable + sprintf('    \\hline\n');
                for j = 1:5
                    LatexTable = LatexTable + sprintf('    1E-%d', j);
                    for k = 1:5
                        CurrentProblemIndex = (i - 1) * 5 + k;
                        if PeakRatios(1, CurrentProblemIndex, j) > PeakRatios(2, CurrentProblemIndex, j)
                            DaggerText = '';
                            if PeakRatioStat(CurrentProblemIndex, j) == 1
                                DaggerText = '$^\dagger$';
                            end
                            LatexTable = LatexTable + sprintf(' & \\textcolor{customred}{\\textbf{%.2f%s}}', PeakRatios(1, CurrentProblemIndex, j), DaggerText);
                        else
                            LatexTable = LatexTable + sprintf(' & %.2f', PeakRatios(1, CurrentProblemIndex, j));
                        end
                        if SuccessRatios(1, CurrentProblemIndex, j) > SuccessRatios(2, CurrentProblemIndex, j)
                            LatexTable = LatexTable + sprintf(' & \\textcolor{customred}{\\textbf{%.2f}}', SuccessRatios(1, CurrentProblemIndex, j));
                        else
                            LatexTable = LatexTable + sprintf(' & %.2f', SuccessRatios(1, CurrentProblemIndex, j));
                        end
                        if PeakRatios(2, CurrentProblemIndex, j) > PeakRatios(1, CurrentProblemIndex, j)
                            DaggerText = '';
                            if PeakRatioStat(CurrentProblemIndex, j) == 1
                                DaggerText = '$^\dagger$';
                            end
                            LatexTable = LatexTable + sprintf(' & \\textcolor{customblue}{\\textbf{%.2f%s}}', PeakRatios(2, CurrentProblemIndex, j), DaggerText);
                        else
                            LatexTable = LatexTable + sprintf(' & %.2f', PeakRatios(2, CurrentProblemIndex, j));
                        end
                        if SuccessRatios(2, CurrentProblemIndex, j) > SuccessRatios(1, CurrentProblemIndex, j)
                            LatexTable = LatexTable + sprintf(' & \\textcolor{customblue}{\\textbf{%.2f}}', SuccessRatios(2, CurrentProblemIndex, j));
                        else
                            LatexTable = LatexTable + sprintf(' & %.2f', SuccessRatios(2, CurrentProblemIndex, j));
                        end
                    end
                    LatexTable = LatexTable + sprintf(' \\\\\n');
                end
            end
            LatexTable = LatexTable + sprintf('    \\hline\n');
            for i = 4:4
                LatexTable = LatexTable + sprintf('    \\multirow{3}{*}{$\\epsilon$}');
                for j = (i-1)*5+1:(i-1)*5+3
                    LatexTable = LatexTable + sprintf(' & \\multicolumn{4}{c|}{$F_{%d}$}', j);
                end
                LatexTable = LatexTable + sprintf(' & \\multicolumn{6}{c|}{Average} & \\multicolumn{2}{c|}{Comparasion} \\\\\n');
                LatexTable = LatexTable + sprintf('\n    \\cline{2-21}\n');
                LatexTable = LatexTable + sprintf('   ');
                for j = 1:4
                    LatexTable = LatexTable + sprintf(' & \\multicolumn{2}{c|}{%s} & \\multicolumn{2}{c|}{%s}', TitleNames{1}, TitleNames{2});
                end
                LatexTable = LatexTable + sprintf(' & PR & SR & \\multicolumn{2}{c|}{$-/\\sim/+$} \\\\\n');
                LatexTable = LatexTable + sprintf('\n    \\cline{2-17}\\cline{20-21}\n');
                LatexTable = LatexTable + sprintf('    ');
                for j = 1:8
                    LatexTable = LatexTable + sprintf(' & \\multicolumn{1}{c|}{PR} & SR');
                end
                LatexTable = LatexTable + sprintf(' & Diff & Diff & \\multicolumn{1}{c|}{PR} & \\multicolumn{1}{c|}{SR} \\\\\n');
                LatexTable = LatexTable + sprintf('    \\hline\n');
                for j = 1:5
                    LatexTable = LatexTable + sprintf('    1E-%d', j);
                    for k = 1:3
                        CurrentProblemIndex = (i - 1) * 5 + k;
                        if PeakRatios(1, CurrentProblemIndex, j) > PeakRatios(2, CurrentProblemIndex, j)
                            DaggerText = '';
                            if PeakRatioStat(CurrentProblemIndex, j) == 1
                                DaggerText = '$^\dagger$';
                            end
                            LatexTable = LatexTable + sprintf(' & \\textcolor{customred}{\\textbf{%.2f%s}}', PeakRatios(1, CurrentProblemIndex, j), DaggerText);
                        else
                            LatexTable = LatexTable + sprintf(' & %.2f', PeakRatios(1, CurrentProblemIndex, j));
                        end
                        if SuccessRatios(1, CurrentProblemIndex, j) > SuccessRatios(2, CurrentProblemIndex, j)
                            LatexTable = LatexTable + sprintf(' & \\textcolor{customred}{\\textbf{%.2f}}', SuccessRatios(1, CurrentProblemIndex, j));
                        else
                            LatexTable = LatexTable + sprintf(' & %.2f', SuccessRatios(1, CurrentProblemIndex, j));
                        end
                        if PeakRatios(2, CurrentProblemIndex, j) > PeakRatios(1, CurrentProblemIndex, j)
                            DaggerText = '';
                            if PeakRatioStat(CurrentProblemIndex, j) == 1
                                DaggerText = '$^\dagger$';
                            end
                            LatexTable = LatexTable + sprintf(' & \\textcolor{customblue}{\\textbf{%.2f%s}}', PeakRatios(2, CurrentProblemIndex, j), DaggerText);
                        else
                            LatexTable = LatexTable + sprintf(' & %.2f', PeakRatios(2, CurrentProblemIndex, j));
                        end
                        if SuccessRatios(2, CurrentProblemIndex, j) > SuccessRatios(1, CurrentProblemIndex, j)
                            LatexTable = LatexTable + sprintf(' & \\textcolor{customblue}{\\textbf{%.2f}}', SuccessRatios(2, CurrentProblemIndex, j));
                        else
                            LatexTable = LatexTable + sprintf(' & %.2f', SuccessRatios(2, CurrentProblemIndex, j));
                        end
                    end
                    for k = 1:2
                        LatexTable = LatexTable + sprintf(' & %.2f', AveragePeakRatios(k, j));
                        LatexTable = LatexTable + sprintf(' & %.2f', AverageSuccessRatios(k, j));
                    end
                    if AveragePeakRatios(1, j) < AveragePeakRatios(2, j)
                        LatexTable = LatexTable + sprintf(' & \\textbf{\\textcolor{customblue}{+%d\\%%}}', ceil(100 * ((AveragePeakRatios(2, j) - AveragePeakRatios(1, j)) / AveragePeakRatios(1, j))));
                    else
                        LatexTable = LatexTable + sprintf(' & \\textbf{\\textcolor{red}{-%d\\%%}}', ceil(100 * ((AveragePeakRatios(1, j) - AveragePeakRatios(2, j)) / AveragePeakRatios(2, j))));
                    end
                    if AverageSuccessRatios(1, j) < AverageSuccessRatios(2, j)
                        LatexTable = LatexTable + sprintf(' & \\textbf{\\textcolor{customblue}{+%d\\%%}}', ceil(100 * ((AverageSuccessRatios(2, j) - AverageSuccessRatios(1, j)) / AverageSuccessRatios(1, j))));
                    else
                        LatexTable = LatexTable + sprintf(' & \\textbf{\\textcolor{red}{-%d\\%%}}', ceil(100 * ((AverageSuccessRatios(1, j) - AverageSuccessRatios(2, j)) / AverageSuccessRatios(2, j))));
                    end
                    LatexTable = LatexTable + sprintf(' & %d/%d/%d & %d/%d/%d \\\\\n', ...
                    sum(PeakRatios(1, :, j) > PeakRatios(2, :, j)), ...
                    sum(PeakRatios(1, :, j) == PeakRatios(2, :, j)), ...
                    sum(PeakRatios(2, :, j) > PeakRatios(1, :, j)), ...
                    sum(SuccessRatios(1, :, j) > SuccessRatios(2, :, j)), ...
                    sum(SuccessRatios(1, :, j) == SuccessRatios(2, :, j)), ...
                    sum(SuccessRatios(2, :, j) > SuccessRatios(1, :, j)));
                end
            end

            LatexTable = LatexTable + sprintf('    \\hline\n');
            LatexTable = LatexTable + sprintf('    \\multicolumn{13}{c}{}\\\\\n');
            LatexTable = LatexTable + sprintf('    \\multicolumn{13}{l}{\\shortstack{*Colored values indicate that algorithm has a higher SR or PR under the corresponding accuracy.}}\\\\\n');
            LatexTable = LatexTable + sprintf('    \\multicolumn{13}{l}{\\shortstack{$^\\dagger$A significant $t$ value of a two-tailed test with 62 degrees of freedom and $\\alpha=0.05$.}}\\\\\n');
            LatexTable = LatexTable + sprintf('  \\end{tabular}\n');
            LatexTable = LatexTable + sprintf('  }\n');
            LatexTable = LatexTable + sprintf('  \\label{table:%s}\n', LabelName);
            LatexTable = LatexTable + sprintf('\\end{table*}');
        end

        function LatexTable = CompleteTable(Caption, LogNames, TitleNames, LabelName)
            ProblemNumber = 18;
            PeakRatios = NaN(5, ProblemNumber, 5);
            SuccessRatios = NaN(5, ProblemNumber, 5);
            for LogIndex = 1:length(LogNames)
                CurrentSummary = Utils.GetSummary(LogNames{LogIndex});
                CurrentSummary.ReadDataFromFiles();
                for ProblemNumberIndex = 1:size(PeakRatios, 2)
                    for AccuracyIndex = 1:size(PeakRatios, 3)
                        PeakRatios(LogIndex, ProblemNumberIndex, AccuracyIndex) = mean(CurrentSummary.FoundedPeaks(ProblemNumberIndex, :, AccuracyIndex));
                        SuccessRatios(LogIndex, ProblemNumberIndex, AccuracyIndex) = mean(CurrentSummary.FoundedPeaks(ProblemNumberIndex, :, AccuracyIndex) == 1);
                    end
                end
            end

            %% Print Latex Table
            LatexTable = "";
            LatexTable = LatexTable + sprintf('\\begin{table*}[h]\n');
            LatexTable = LatexTable + sprintf('  \\scriptsize\n');
            LatexTable = LatexTable + sprintf('  \\caption{%s}\n', Caption);
            LatexTable = LatexTable + sprintf('  \\noindent\\makebox[\\textwidth]{\n');
            LatexTable = LatexTable + sprintf('  \\begin{tabular}{p{2.2mm}|p{5mm}|p{4mm}|p{4mm}|p{4mm}|p{4mm}|p{4mm}|p{4mm}|p{4mm}|p{4mm}|p{4mm}|p{4mm}|p{3.4mm}|p{4mm}|p{4mm}|p{4mm}|p{4mm}|p{4mm}|p{4mm}|p{4mm}|p{4mm}|p{4mm}|p{4mm}}\n');
            LatexTable = LatexTable + sprintf('    \\hline\n');

            LatexTable = LatexTable + sprintf('    \\multirow{2}{*}{$F$} & \\multirow{2}{*}{$\\epsilon$}');
            LatexTable = LatexTable + sprintf(' & \\multicolumn{2}{c|}{%s} & \\multicolumn{2}{c|}{%s} & \\multicolumn{2}{c|}{%s} & \\multicolumn{2}{c|} {%s} & \\multicolumn{2}{c|} {%s}', TitleNames{1}, TitleNames{2}, TitleNames{3}, TitleNames{4}, TitleNames{5});
            LatexTable = LatexTable + sprintf(' & \\multirow{2}{*}{$F$}');
            LatexTable = LatexTable + sprintf(' & \\multicolumn{2}{c|}{%s} & \\multicolumn{2}{c|}{%s} & \\multicolumn{2}{c|}{%s} & \\multicolumn{2}{c|}{%s} & \\multicolumn{2}{c} {%s} \\\\\n', TitleNames{1}, TitleNames{2}, TitleNames{3}, TitleNames{4}, TitleNames{5});

            LatexTable = LatexTable + sprintf('    \\cline{3-12}\\cline{14-23}\n');
            LatexTable = LatexTable + sprintf('    &');
            for i = 1:5
                LatexTable = LatexTable + sprintf(' & \\multicolumn{1}{c|}{PR} & \\multicolumn{1}{c|}{SR}');
            end
            LatexTable = LatexTable + sprintf(' &');
            for i = 1:4
                LatexTable = LatexTable + sprintf(' & \\multicolumn{1}{c|}{PR} & \\multicolumn{1}{c|}{SR}');
            end
            LatexTable = LatexTable + sprintf(' & \\multicolumn{1}{c|}{PR} & \\multicolumn{1}{c}{SR}');
            LatexTable = LatexTable + sprintf(' \\\\\n');

            LatexTable = LatexTable + sprintf('    \\hline\n');

            for i = 1:9
                LeftProblemIndex = i;
                RightProblemIndex = 9 + i;
                for j = 1:5
                    LeftProblemMaxPeakRatio = max(PeakRatios(:, LeftProblemIndex, j));
                    LeftProblemMaxSuccessRatio = max(SuccessRatios(:, LeftProblemIndex, j));
                    RightProblemMaxPeakRatio = max(PeakRatios(:, RightProblemIndex, j));
                    RightProblemMaxSuccessRatio = max(SuccessRatios(:, RightProblemIndex, j));
                    LatexTable = LatexTable + sprintf('    ');
                    if j == 1
                        LatexTable = LatexTable + sprintf(' \\multirow{5}{*}{$F_{%d}$}', LeftProblemIndex);
                    end
                    LatexTable = LatexTable + sprintf(' & 1E-%d', j);
                    for k = 1:5
                        if PeakRatios(k, LeftProblemIndex, j) == LeftProblemMaxPeakRatio && LeftProblemMaxPeakRatio ~= 0
                            LatexTable = LatexTable + sprintf(' & \\textbf{%.2f}', PeakRatios(k, LeftProblemIndex, j));
                        else
                            LatexTable = LatexTable + sprintf(' & %.2f', PeakRatios(k, LeftProblemIndex, j));
                        end
                        if SuccessRatios(k, LeftProblemIndex, j) == LeftProblemMaxSuccessRatio && LeftProblemMaxSuccessRatio ~= 0
                            LatexTable = LatexTable + sprintf(' & \\textbf{%.2f}', SuccessRatios(k, LeftProblemIndex, j));
                        else
                            LatexTable = LatexTable + sprintf(' & %.2f', SuccessRatios(k, LeftProblemIndex, j));
                        end
                    end
                    if j == 1
                        LatexTable = LatexTable + sprintf(' & \\multirow{5}{*}{$F_{%d}$}', RightProblemIndex);
                    else
                        LatexTable = LatexTable + sprintf(' & ');
                    end
                    for k = 1:5
                        if PeakRatios(k, RightProblemIndex, j) == RightProblemMaxPeakRatio && RightProblemMaxPeakRatio ~= 0
                            LatexTable = LatexTable + sprintf(' & \\textbf{%.2f}', PeakRatios(k, RightProblemIndex, j));
                        else
                            LatexTable = LatexTable + sprintf(' & %.2f', PeakRatios(k, RightProblemIndex, j));
                        end
                        if SuccessRatios(k, RightProblemIndex, j) == RightProblemMaxSuccessRatio && RightProblemMaxSuccessRatio ~= 0
                            LatexTable = LatexTable + sprintf(' & \\textbf{%.2f}', SuccessRatios(k, RightProblemIndex, j));
                        else
                            LatexTable = LatexTable + sprintf(' & %.2f', SuccessRatios(k, RightProblemIndex, j));
                        end
                    end
                    LatexTable = LatexTable + sprintf(' \\\\\n');
                end
                LatexTable = LatexTable + sprintf('    \\hline\n');
            end
            LatexTable = LatexTable + sprintf('    \\multicolumn{23}{c}{}\\\\\n');
            LatexTable = LatexTable + sprintf('    \\multicolumn{23}{l}{\\shortstack{*Bold values indicate that algorithm has a higher SR or PR under the corresponding accuracy.}}\\\\\n');
            LatexTable = LatexTable + sprintf('  \\end{tabular}\n');
            LatexTable = LatexTable + sprintf('  }\n');
            LatexTable = LatexTable + sprintf('  \\label{table:%s}\n', LabelName);
            LatexTable = LatexTable + sprintf('\\end{table*}');
        end

        function LatexTable = AverageTable(Caption, LogNames, TitleNames, ProblemNumbers, LabelName)
            ProblemNumber = length(ProblemNumbers);
            AlgorithmNumber = 4;
            EvalutionTimeNumber = 3;
            AveragePeakRatios = NaN(AlgorithmNumber, ProblemNumber, EvalutionTimeNumber);
            AverageSuccessRatios = NaN(AlgorithmNumber, ProblemNumber, EvalutionTimeNumber);
            for EvaluationTimeIndex = 1:EvalutionTimeNumber
                CurrentLogNames = LogNames{EvaluationTimeIndex};
                for AlgorithmIndex = 1:AlgorithmNumber
                    CurrentSummary = Utils.GetSummary(CurrentLogNames{AlgorithmIndex});
                    CurrentSummary.ReadDataFromFiles();
                    for ProblemNumberIndex = 1:ProblemNumber
                        CurrentProblemNumber = ProblemNumbers(ProblemNumberIndex);
                        AveragePeakRatios(AlgorithmIndex, ProblemNumberIndex, EvaluationTimeIndex) = mean(reshape(CurrentSummary.FoundedPeaks(CurrentProblemNumber, :, :), 1, []));
                        AverageSuccessRatios(AlgorithmIndex, ProblemNumberIndex, EvaluationTimeIndex) = mean(reshape(CurrentSummary.FoundedPeaks(CurrentProblemNumber, :, :), 1, []) == 1);
                    end
                end
            end

            %% Print Latex Table
            LatexTable = "";
            LatexTable = LatexTable + sprintf('\\begin{table*}[h]\n');
            LatexTable = LatexTable + sprintf('  \\centering\n');
            LatexTable = LatexTable + sprintf('  \\caption{%s}\n', Caption);
            LatexTable = LatexTable + sprintf('  \\begin{tabular}{|c|c|ccc|ccc|ccc|ccc|}\n');
            LatexTable = LatexTable + sprintf('    \\hline\n');
            LatexTable = LatexTable + sprintf('    \\multicolumn{2}{|c|}{Algorithm} & \\multicolumn{3}{c|}{%s} & \\multicolumn{3}{c|}{%s} & \\multicolumn{3}{c|}{%s} & \\multicolumn{3}{c|}{%s} \\\\\n', TitleNames{1}, TitleNames{2}, TitleNames{3}, TitleNames{4});
            LatexTable = LatexTable + sprintf('    \\hline\n');
            LatexTable = LatexTable + sprintf('    \\multicolumn{2}{|c|}{Evaluation} & Low & Mid & High & Low & Mid & High & Low & Mid & High & Low & Mid & High \\\\\n');
            LatexTable = LatexTable + sprintf('    \\hline\n');

            for i = 1:ProblemNumber
                CurrentProblemNumber = ProblemNumbers(i);
                LatexTable = LatexTable + sprintf('    \\multirow{2}{*}{$F_{%d}$} & PR', CurrentProblemNumber);
                for j = 1:AlgorithmNumber
                    LatexTable = LatexTable + sprintf(' & %.2f & %.2f & %.2f', AveragePeakRatios(j, i, 1), AveragePeakRatios(j, i, 2), AveragePeakRatios(j, i, 3));
                end
                LatexTable = LatexTable + sprintf(' \\\\\n');
                LatexTable = LatexTable + sprintf('    & SR');
                for j = 1:AlgorithmNumber
                    LatexTable = LatexTable + sprintf(' & %.2f & %.2f & %.2f', AverageSuccessRatios(j, i, 1), AverageSuccessRatios(j, i, 2), AverageSuccessRatios(j, i, 3));
                end
                LatexTable = LatexTable + sprintf(' \\\\\n');
                LatexTable = LatexTable + sprintf('    \\hline\n');
            end

            % LatexTable = LatexTable + sprintf('    \\multirow{2}{*}{Average} & PR');
            % for j = 1:AlgorithmNumber
            %     LatexTable = LatexTable + sprintf(' & %.2f & %.2f & %.2f', mean(AveragePeakRatios(j, :, 1)), mean(AveragePeakRatios(j, :, 2)), mean(AveragePeakRatios(j, :, 3)));
            % end
            % LatexTable = LatexTable + sprintf(' \\\\\n');
            % LatexTable = LatexTable + sprintf('    & SR');
            % for j = 1:AlgorithmNumber
            %     LatexTable = LatexTable + sprintf(' & %.2f & %.2f & %.2f', mean(AverageSuccessRatios(j, :, 1)), mean(AverageSuccessRatios(j, :, 2)), mean(AverageSuccessRatios(j, :, 3)));
            % end
            % LatexTable = LatexTable + sprintf(' \\\\\n');
            % LatexTable = LatexTable + sprintf('    \\hline\n');
            LatexTable = LatexTable + sprintf('  \\end{tabular}\n');
            LatexTable = LatexTable + sprintf('  \\label{table:%s}\n', LabelName);
            LatexTable = LatexTable + sprintf('\\end{table*}');
        end
        
        function LatexTable = CompareUnconstrained(Caption, LogNames, TitleNames, LabelName)
            ProblemNumber = 18;
            PeakRatioIndex = 5;
            PeakRatios = NaN(2, ProblemNumber);
            SuccessRatios = NaN(2, ProblemNumber);
            for LogIndex = 1:length(LogNames)
                CurrentSummary = Utils.GetSummary(LogNames{LogIndex});
                CurrentSummary.ReadDataFromFiles();
                for ProblemNumberIndex = 1:ProblemNumber
                    PeakRatios(LogIndex, ProblemNumberIndex) = mean(CurrentSummary.FoundedPeaks(ProblemNumberIndex, :, PeakRatioIndex));
                    SuccessRatios(LogIndex, ProblemNumberIndex) = mean(CurrentSummary.FoundedPeaks(ProblemNumberIndex, :, PeakRatioIndex) == 1);
                end
            end

            %% Print Latex Table
            LatexTable = "";
            LatexTable = LatexTable + sprintf('\\begin{table}[h]\n');
            LatexTable = LatexTable + sprintf('  \\centering\n');
            LatexTable = LatexTable + sprintf('  \\caption{%s}\n', Caption);
            LatexTable = LatexTable + sprintf('  \\begin{tabular}{|c|c|c|c|c|}\n');
            LatexTable = LatexTable + sprintf('    \\hline\n');
            LatexTable = LatexTable + sprintf('    Metric & \\multicolumn{2}{c|}{PR} & \\multicolumn{2}{c|}{SR} \\\\\n');
            LatexTable = LatexTable + sprintf('    \\hline\n');
            LatexTable = LatexTable + sprintf('    Algorithm & %s & %s & %s & %s \\\\\n', TitleNames{1}, TitleNames{2}, TitleNames{1}, TitleNames{2});
            LatexTable = LatexTable + sprintf('    \\hline\n');
            for i = 1:18
                LatexTable = LatexTable + sprintf('    $F_{%d}$', i);
                if PeakRatios(1, i) > PeakRatios(2, i)
                    LatexTable = LatexTable + sprintf(' & \\textbf{%.2f}', PeakRatios(1, i));
                else
                    LatexTable = LatexTable + sprintf(' & %.2f', PeakRatios(1, i));
                end
                if PeakRatios(2, i) > PeakRatios(1, i)
                    LatexTable = LatexTable + sprintf(' & \\textbf{%.2f}', PeakRatios(2, i));
                else
                    LatexTable = LatexTable + sprintf(' & %.2f', PeakRatios(2, i));
                end
                if SuccessRatios(1, i) > SuccessRatios(2, i)
                    LatexTable = LatexTable + sprintf(' & \\textbf{%.2f}', SuccessRatios(1, i));
                else
                    LatexTable = LatexTable + sprintf(' & %.2f', SuccessRatios(1, i));
                end
                if SuccessRatios(2, i) > SuccessRatios(1, i)
                    LatexTable = LatexTable + sprintf(' & \\textbf{%.2f}', SuccessRatios(2, i));
                else
                    LatexTable = LatexTable + sprintf(' & %.2f', SuccessRatios(2, i));
                end
                LatexTable = LatexTable + sprintf('\\\\\n');
                LatexTable = LatexTable + sprintf('    \\hline\n');
            end
            LatexTable = LatexTable + sprintf('  \\end{tabular}\n');
            LatexTable = LatexTable + sprintf('  \\label{table:%s}\n', LabelName);
            LatexTable = LatexTable + sprintf('\\end{table}');
        end

        function LatexTable = CompareLowEvaluations(Caption, LogNames, TitleNames, LabelName)
            ProblemNumber = 18;
            AccuracyNumber = 5;
            AveragePeakRatios = NaN(5, 5);
            AverageSuccessRatios = NaN(5, 5);
            for LogIndex = 1:length(LogNames)
                CurrentSummary = Utils.GetSummary(LogNames{LogIndex});
                CurrentSummary.ReadDataFromFiles();
                for AccuracyIndex = 1:AccuracyNumber
                    AveragePeakRatios(LogIndex, AccuracyIndex) = mean(CurrentSummary.FoundedPeaks(:, :, AccuracyIndex), 'all');
                    AverageSuccessRatios(LogIndex, AccuracyIndex) = mean(CurrentSummary.FoundedPeaks(:, :, AccuracyIndex) == 1, 'all');
                end
            end

            %% Print Latex Table
            LatexTable = "";
            LatexTable = LatexTable + sprintf('\\begin{table}[h]\n');
            LatexTable = LatexTable + sprintf('  \\centering\n');
            LatexTable = LatexTable + sprintf('  \\caption{%s}\n', Caption);
            LatexTable = LatexTable + sprintf('  \\begin{tabular}{c|c|c|c|c|c|c}\n');
            LatexTable = LatexTable + sprintf('    \\specialrule{.1em}{.05em}{.05em}\n');
            LatexTable = LatexTable + sprintf('    & $\\epsilon$ & %s & %s & %s & %s & %s \\\\\n', ...
                TitleNames{1}, TitleNames{2}, TitleNames{3}, TitleNames{4}, TitleNames{5});
            LatexTable = LatexTable + sprintf('    \\hline\n');
            for i = 1:5
                LatexTable = LatexTable + sprintf('    ');
                if i == 1
                    LatexTable = LatexTable + sprintf('\\multirow{5}{*}{PR}');
                end
                LatexTable = LatexTable + sprintf('& 1E-%d', i);
                MaxPeakRatio = max(AveragePeakRatios(:, i));
                for j = 1:5
                    if MaxPeakRatio == AveragePeakRatios(j, i)
                        LatexTable = LatexTable + sprintf(' & \\textbf{%.2f}', AveragePeakRatios(j, i));
                    else
                        LatexTable = LatexTable + sprintf(' & %.2f', AveragePeakRatios(j, i));
                    end
                end
                LatexTable = LatexTable + sprintf('\\\\\n');
            end
            LatexTable = LatexTable + sprintf('    \\specialrule{.1em}{.05em}{.05em}\n');
            for i = 1:5
                LatexTable = LatexTable + sprintf('    ');
                if i == 1
                    LatexTable = LatexTable + sprintf('\\multirow{5}{*}{SR}');
                end
                LatexTable = LatexTable + sprintf(' & 1E-%d', i);
                MaxSuccessRatio = max(AverageSuccessRatios(:, i));
                for j = 1:5
                    if MaxSuccessRatio == AverageSuccessRatios(j, i)
                        LatexTable = LatexTable + sprintf(' & \\textbf{%.2f}', AverageSuccessRatios(j, i));
                    else
                        LatexTable = LatexTable + sprintf(' & %.2f', AverageSuccessRatios(j, i));
                    end
                end
                LatexTable = LatexTable + sprintf('\\\\\n');
            end
            LatexTable = LatexTable + sprintf('    \\specialrule{.1em}{.05em}{.05em}\n');
            LatexTable = LatexTable + sprintf('  \\end{tabular}\n');
            LatexTable = LatexTable + sprintf('  \\label{table:%s}\n', LabelName);
            LatexTable = LatexTable + sprintf('\\end{table}');
        end

        function WriteFile(OuputFile, Content)
            f = fopen(OuputFile, 'w');
            fprintf(f, '%s', Content);
            fclose(f);
        end
    end
end