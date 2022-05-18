classdef Summary < handle

    properties
        LogPath;
        DFile;
        RunNumber;
        FoundedPeaks;
        ObjectiveFunctions;
        UpperBound;
        LowerBound;
    end

    properties (Constant = true)
        Dimensions = [1, 2, 2, 5, 5, 5, 10, 10, 10, 1, 2, 2, 1, 1, 2, 2, 3, 5];
        PeakNumbers = [2, 2, 4, 2, 8, 32, 2, 8, 32, 10, 4, 4, 2, 10, 8, 24, 16, 64];
        Radius = [0.5 * ones(1, 9), 0.05 * ones(1, 9)];
        Accuracies = [0.1, 0.01, 0.001, 0.0001, 0.00001];
        MaxFitnessEvaluations = floor(2000 .* Summary.Dimensions .* sqrt(Summary.PeakNumbers));
        ProblemTotalNum = length(Summary.Dimensions);
        Epsim = 1e-4;
        SummaryFileName = 'summary.log';
        MainLogFileName = 'main.log';
        FitnessPlotFolderName = 'fitness_plot';
        PeakRatioFolderName = 'peak_ratio';
    end

    methods

        function obj = Summary(LogPathName, RunNumber)
            obj.LogPath = fullfile('.', 'logs', LogPathName);
            obj.RunNumber = RunNumber;
            obj.DFile = fullfile(obj.LogPath, obj.MainLogFileName);
            obj.FoundedPeaks = NaN(Summary.ProblemTotalNum, RunNumber, length(obj.Accuracies));
            obj.ObjectiveFunctions = cell(1, Summary.ProblemTotalNum);
            obj.UpperBound = cell(1, Summary.ProblemTotalNum);
            obj.LowerBound = cell(1, Summary.ProblemTotalNum);
            for index = 1:Summary.ProblemTotalNum
                obj.ObjectiveFunctions{1, index} = @(x) niching_func_cons(x, index);
                [obj.LowerBound{1, index}, obj.UpperBound{1, index}] = niching_func_bound_cons(index, obj.Dimensions(index));
            end
            obj.InitLogFile();
        end

        function InitLogFile(obj)
            diary off;
            if ~exist(obj.LogPath, 'dir'); mkdir(obj.LogPath); end

            Summary.MakeDirectory(fullfile(obj.LogPath, obj.FitnessPlotFolderName));
            Summary.MakeDirectory(fullfile(obj.LogPath, obj.PeakRatioFolderName));

            if exist(obj.DFile, 'file'); delete(obj.DFile); end
            diary(obj.DFile);
            diary on;
        end

        function Finish(obj)
            diary off;
            obj.WriteAllSummary();
        end

        function WriteAllSummary(obj)
            f = fopen(fullfile(obj.LogPath, 'summary.log'), 'w');

            for index = 1:obj.ProblemTotalNum
                if ~sum(isnan(obj.FoundedPeaks(index, :, :))) == 0; continue; end
                fprintf(f, obj.GetProblemSummary(index));
                fprintf(f, '\n');
                writematrix(reshape(obj.FoundedPeaks(index, :, :) / obj.PeakNumbers(1, index), obj.RunNumber, length(obj.Accuracies)), ...
                    fullfile(obj.LogPath, obj.PeakRatioFolderName, strcat(num2str(index), '.dat')), 'Delimiter', 'tab');
            end

            fprintf(f, '--------------------- Stats ---------------------\n');
            RatioSum = 0.;
            for index = 1:obj.ProblemTotalNum
                if ~sum(isnan(obj.FoundedPeaks(index, :, :))) == 0; continue; end
                CurrentMeanValue = mean(reshape(obj.FoundedPeaks(index, :, :), 1, obj.RunNumber * length(obj.Accuracies)) / obj.PeakNumbers(1, index));
                fprintf(f, 'Problem: %d, Average Peak Ratio: %f\n', index, ...
                    CurrentMeanValue);
                RatioSum = RatioSum + CurrentMeanValue;
            end
            fprintf(f, 'Overall Average Peak Ratio: %f\n', RatioSum / obj.ProblemTotalNum);
            MeanRatio = reshape(mean(obj.FoundedPeaks, 2), obj.ProblemTotalNum, length(obj.Accuracies));
            MeanRatio = MeanRatio ./ repmat(obj.PeakNumbers', 1, length(obj.Accuracies));
            MeanRatio = reshape(mean(MeanRatio, 1), 1, length(obj.Accuracies));
            MeanSuccessRatio = mean(obj.FoundedPeaks == repmat(obj.PeakNumbers', [1, obj.RunNumber, length(obj.Accuracies)]), [1, 2]);
            for index = 1:length(obj.Accuracies)
                fprintf(f, 'Accuracy: %f, Average Peak Ratio: %f\n', obj.Accuracies(1, index), MeanRatio(1, index));
            end
            for index = 1:length(obj.Accuracies)
                fprintf(f, 'Accuracy: %f, Average Success Ratio: %f\n', obj.Accuracies(1, index), MeanSuccessRatio(1, index));
            end
            fprintf(f, '--------------------- Stats ---------------------\n');
            fclose(f);
        end
        
        function PlotAllOfflineError(obj, ProblemNum, RunCounter, AllOfflineError)
            figure('visible', 'off');
            plot(AllOfflineError);
            print(obj.GetAllOfflineErrorPlotFile(ProblemNum, RunCounter), '-dpng');
        end

        function [SummaryString] = GetProblemSummary(obj, ProblemNum)
            FormatString = '--------------------- Problem %d ---------------------\n';
            for index = 1:length(obj.Accuracies)
                PeakRatio = obj.FoundedPeaks(ProblemNum, :, index) / obj.PeakNumbers(ProblemNum);
                AccuraySummaryString = '---- Accuracy: %f ----\n';
                AccuraySummaryString = append(AccuraySummaryString, 'PR Best: %f\n');
                AccuraySummaryString = append(AccuraySummaryString, 'PR Worst: %f\n');
                AccuraySummaryString = append(AccuraySummaryString, 'PR Average: %f\n');
                AccuraySummaryString = append(AccuraySummaryString, 'PR Median: %f\n');
                AccuraySummaryString = append(AccuraySummaryString, 'PR Standard Deviation: %f\n');
                AccuraySummaryString = append(AccuraySummaryString, 'SR: %f\n');
                AccuraySummaryString = append(AccuraySummaryString, '---- Accuracy: %f ----\n');
                AccuraySummaryString = sprintf(AccuraySummaryString, obj.Accuracies(index), ...
                                        max(PeakRatio), min(PeakRatio), ...
                                        mean(PeakRatio), median(PeakRatio), ...
                                        std(PeakRatio) / sqrt(obj.RunNumber), ...
                                        sum(PeakRatio == 1.0) / obj.RunNumber, obj.Accuracies(index));
                FormatString = append(FormatString, AccuraySummaryString);
            end
            FormatString = append(FormatString, '--------------------- Problem %d ---------------------\n');
            SummaryString = sprintf(FormatString, ProblemNum, ProblemNum);
        end

    end

    methods (Static)
        %% Util Function
        function WriteFile(OuputFile, Content)
            f = fopen(OuputFile, 'w');
            fprintf(f, '%f ', Content);
            fclose(f);
        end

        function MakeDirectory(Path)
              if ~exist(Path, 'dir'); mkdir(Path); end
        end
    end

end