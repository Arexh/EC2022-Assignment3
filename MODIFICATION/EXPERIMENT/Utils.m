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

        function LatexTable = CompareTwoResults(Caption, LogNames, TitleNames)
            ProblemNumber = 18;
            PeakRatios = NaN(2, ProblemNumber, 5);
            SuccessRatios = NaN(2, ProblemNumber, 5);
            PeakRatioStat = NaN(ProblemNumber, 5);
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
            LatexTable = LatexTable + sprintf('  \\begin{tabular}{|p{4.8mm}|p{4.4mm}|p{4.4mm}|p{4.4mm}|p{4.4mm}|p{4.4mm}|p{4.4mm}|p{4.4mm}|p{4.4mm}|p{4.4mm}|p{4.4mm}|p{4.4mm}|p{4.4mm}|p{4.4mm}|p{4.4mm}|p{4.4mm}|p{4.4mm}|p{4.4mm}|p{4.4mm}|p{4.4mm}|p{4.4mm}|}\n');
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
            LatexTable = LatexTable + sprintf('  \\end{tabular}\n');
            LatexTable = LatexTable + sprintf('  }\n');

            LatexTable = LatexTable + sprintf('  \\noindent\\makebox[\\textwidth]{\n');
            LatexTable = LatexTable + sprintf('  \\begin{tabular}{|p{4.8mm}|p{4.4mm}|p{4.4mm}|p{4.4mm}|p{4.4mm}|p{4.4mm}|p{4.4mm}|p{4.4mm}|p{4.4mm}|p{4.4mm}|p{4.4mm}|p{4.4mm}|p{4.4mm}|p{4.4mm}|p{4.4mm}|p{4.4mm}|p{4.4mm}|p{4.4mm}|p{4.4mm}|p{4.4mm}|p{4.4mm}|}\n');

            for i = 4:4
                LatexTable = LatexTable + sprintf('    \\multirow{3}{*}{$\\epsilon$}');
                for j = (i-1)*5+1:(i-1)*5+3
                    LatexTable = LatexTable + sprintf(' & \\multicolumn{4}{c|}{$F_{%d}$}', j);
                end
                LatexTable = LatexTable + sprintf(' \\\\\n');
                LatexTable = LatexTable + sprintf('\n    \\cline{2-13}\n');
                LatexTable = LatexTable + sprintf('   ');
                for j = 1:3
                    LatexTable = LatexTable + sprintf(' & \\multicolumn{2}{c|}{%s} & \\multicolumn{2}{c|}{%s}', TitleNames{1}, TitleNames{2});
                end
                LatexTable = LatexTable + sprintf(' \\\\\n');
                LatexTable = LatexTable + sprintf('\n    \\cline{2-13}\n');
                LatexTable = LatexTable + sprintf('    ');
                for j = 1:6
                    LatexTable = LatexTable + sprintf(' & \\multicolumn{1}{c|}{PR} & SR');
                end
                LatexTable = LatexTable + sprintf(' \\\\\n');
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
                    LatexTable = LatexTable + sprintf(' \\\\\n');
                end
            end

            LatexTable = LatexTable + sprintf('    \\hline\n');
            LatexTable = LatexTable + sprintf('    \\multicolumn{13}{c}{}\\\\\n');
            LatexTable = LatexTable + sprintf('    \\multicolumn{13}{l}{\\shortstack{$^\\dagger$A significant $t$ value of a two-tailed test with 62 degrees of freedom and $\\alpha=0.05$. Colored values}}\\\\\n');
            LatexTable = LatexTable + sprintf('    \\multicolumn{13}{l}{\\shortstack{indicate that algorithm has a higher SR or PR.}}\\\\\n');
            LatexTable = LatexTable + sprintf('  \\end{tabular}\n');
            LatexTable = LatexTable + sprintf('  }\n');
            LatexTable = LatexTable + sprintf('\\end{table*}');
        end

        function LatexTable = CompleteTable(Caption, LogNames, TitleNames)
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
        end

        function WriteFile(OuputFile, Content)
            f = fopen(OuputFile, 'w');
            fprintf(f, '%s', Content);
            fclose(f);
        end
    end
end