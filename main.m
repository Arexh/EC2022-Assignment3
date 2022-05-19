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

    Dims = [1,2,2,5,5,5,10,10,10,1,2,2,1,1,2,2,3,5];
    func = @niching_func_cons;
    peakNum = [2,2,4,2,8,32,2,8,32,10,4,4,2,10,8,24,16,64];
    radius = [0.5*ones(1,9), 0.05*ones(1,9)];
    accuracy = [0.1; 0.01; 0.001; 0.0001; 0.00001];

    if IfParallel
        D = parallel.pool.DataQueue;
        afterEach(D, @(x) UpdateExperimentalResult(CurrentSummary, x));
        parfor RunNumber = 1:CurrentSummary.RunNumber
            problem = [];
            problem.epsim = 1e-4;
            problem.func_num=ProblemNumber;
            peak_num = peakNum(ProblemNumber);
            problem.dim = Dims(ProblemNumber);
            problem.func = @(x) func(x, ProblemNumber);
            problem.max_fes = floor(2000*problem.dim*sqrt(peak_num));
            [problem.lower_bound, problem.upper_bound] = niching_func_bound_cons(ProblemNumber, problem.dim );
            problem.radius = radius(ProblemNumber);
            rng('shuffle');
            [population] = fNSDE_LSHADE44(CurrentSummary, ProblemNumber);
            Results = NaN(1, 5);
            for AccuricyIndex = 1:length(CurrentSummary.Accuracies)
                [count, ~] = count_goptima(population, problem, accuracy(AccuricyIndex));
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
        problem.epsim = 1e-4;
        problem.func_num=ProblemNumber;
        peak_num = peakNum(ProblemNumber);
        problem.dim = Dims(ProblemNumber);
        problem.func = @(x) func(x, ProblemNumber);
        problem.max_fes = floor(2000*problem.dim*sqrt(peak_num));
        [problem.lower_bound, problem.upper_bound] = niching_func_bound_cons(ProblemNumber, problem.dim );
        problem.radius = radius(ProblemNumber);
        for RunNumber = 1:CurrentSummary.RunNumber
            [population] = fNSDE_LSHADE44(CurrentSummary, ProblemNumber);
            for AccuricyIndex = 1:length(CurrentSummary.Accuracies)
                [count, ~] = count_goptima(population, problem, accuracy(AccuricyIndex));
                peak_num = CurrentSummary.PeakNumbers(1, ProblemNumber);
                fprintf('f_%d, the peak ratio of run %d with accuracy=%f is %f!\n', ProblemNumber, RunNumber, CurrentSummary.Accuracies(1, AccuricyIndex), count/peak_num);
                CurrentSummary.FoundedPeaks(ProblemNumber, RunNumber, AccuricyIndex) = count;
            end
            CurrentSummary.WriteAllSummary();
        end
    end
end
