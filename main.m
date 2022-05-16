%%
clc;
addpath(genpath("benchmark")); 
%% Parameters
RunNumber = 32;
TStart = tic;
IfParallel = true;
addpath(genpath('modification'));
%% Create Summary object to record
CurrentSummary = Summary('baseline', RunNumber);

%% Main Function
for ProblemIndex = 1:18
    ProblemRun(ProblemIndex, CurrentSummary, IfParallel);
end

CurrentSummary.Finish();

disp(['Total time: ', num2str(toc(TStart))]);
%% Helper Funcion
function ProblemRun(ProblemNumber, CurrentSummary, IfParallel)
    function UpdateExperimentalResult(CurrentSummary, x)
        ProblemNum = x{1};
        RunCounter = x{2};
        PeakNumber = x{3};
        CurrentSummary.FoundedPeaks(ProblemNum, RunCounter, :) = PeakNumber;
        disp(['Offline Error Updated (Run: ', num2str(RunCounter), ').']);
        CurrentSummary.WriteAllSummary();
    end

    if IfParallel
        D = parallel.pool.DataQueue;
        afterEach(D, @(x) UpdateExperimentalResult(CurrentSummary, x));
        parfor RunNumber = 1:CurrentSummary.RunNumber
            rng('shuffle');
            [population] = fNSDE_LSHADE44(CurrentSummary, ProblemNumber);
            Results = NaN(1, 5);
            for AccuricyIndex = 1:length(CurrentSummary.Accuracies)
                [count, ~] = count_goptima(population, CurrentSummary, ProblemNumber, CurrentSummary.Accuracies(1, AccuricyIndex));
                peak_num = CurrentSummary.PeakNumbers(1, ProblemNumber);
                fprintf('f_%d, the peak ratio of run %d with accuracy=%f is %f!\n', ProblemNumber, RunNumber, CurrentSummary.Accuracies(1, AccuricyIndex), count/peak_num);
                Results(1, AccuricyIndex) = count;
            end
            MessagePackage = cell(1, 3);
            MessagePackage{1, 1} = ProblemNumber;
            MessagePackage{1, 2} = RunNumber;
            MessagePackage{1, 3} = Results;
            send(D, MessagePackage);
        end
    else
        for RunNumber = 1:CurrentSummary.RunNumber
            [population] = fNSDE_LSHADE44(CurrentSummary, ProblemNumber);
            for AccuricyIndex = 1:length(CurrentSummary.Accuracies)
                [count, ~] = count_goptima(population, CurrentSummary, ProblemNumber, CurrentSummary.Accuracies(1, AccuricyIndex));
                peak_num = CurrentSummary.PeakNumbers(1, ProblemNumber);
                fprintf('f_%d, the peak ratio of run %d with accuracy=%f is %f!\n', ProblemNumber, RunNumber, CurrentSummary.Accuracies(1, AccuricyIndex), count/peak_num);
                CurrentSummary.FoundedPeaks(ProblemNumber, RunNumber, AccuricyIndex) = count;
            end
            CurrentSummary.WriteAllSummary();
        end
    end
end
