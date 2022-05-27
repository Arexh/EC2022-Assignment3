%%
clc;
addpath(genpath("benchmark")); 
addpath(genpath('modification'));
%% Parameters
RunNumber = 32;
IfParallel = true;
EvaluationTimes = {'Mid'};
AlgorithmNames = {'mPSO-H'};
%% To Run All Experiments, Use These Two Lines
% EvaluationTimes = {'Low', 'Mid', 'High'};
% AlgorithmNames = {'Baseline', 'mPSO-P', 'mPSO-A', 'mPSO-F', 'mPSO-H'};
%% Prestart Parfor
parfor i = 1:8; end

for EvalutionTimeIndex = 1:length(EvaluationTimes)
    for AlgorithmIndex = 1:length(AlgorithmNames)
    EvaluationTime = EvaluationTimes{EvalutionTimeIndex};
        AlgorithmName = AlgorithmNames{AlgorithmIndex};
        LogPathName = strrep([AlgorithmName, '-', EvaluationTime], '-', '_');
        RunAlgorithm(LogPathName, AlgorithmName, EvaluationTime, RunNumber, IfParallel);
    end
end

function RunAlgorithm(LogPathName, AlgorithmName, EvaluationTime, RunNumber, IfParallel)
    TStart = tic;
    %% Create Summary object to record
    CurrentSummary = Summary(LogPathName, RunNumber);
    CurrentSummary.InitLogFile();

    %% Main Function
    for ProblemIndex = 1:18
        ProblemRun(ProblemIndex, AlgorithmName, CurrentSummary, IfParallel, EvaluationTime);
    end

    disp(['Total time: ', num2str(toc(TStart))]);

    CurrentSummary.Finish();
end

%% Helper Funcion
function ProblemRun(ProblemNumber, AlgorithmName, CurrentSummary, IfParallel, EvaluationTime)
    function UpdateExperimentalResult(CurrentSummary, x)
        ProblemNum = x{1};
        RunCounter = x{2};
        PeakNumber = x{3};
        CurrentSummary.FoundedPeaks(ProblemNum, RunCounter, :) = PeakNumber;
        CurrentSummary.WriteAllSummary();
    end

    Dims = [1,2,2,5,5,5,10,10,10,1,2,2,1,1,2,2,3,5];
    func = @niching_func_cons;
    peakNum = [2,2,4,2,8,32,2,8,32,10,4,4,2,10,8,24,16,64];
    radius = [0.5*ones(1,9), 0.05*ones(1,9)];
    accuracy = [0.1; 0.01; 0.001; 0.0001; 0.00001];

    %% Prepare Parameters
    CurrentSummary.problem = [];
    CurrentSummary.problem.epsim = 1e-4;
    CurrentSummary.problem.func_num=ProblemNumber;
    CurrentSummary.problem.dim = Dims(ProblemNumber);
    CurrentSummary.problem.func = @(x) func(x, ProblemNumber);
    if strcmpi(EvaluationTime, 'low')
        CurrentSummary.problem.max_fes = floor(2000*CurrentSummary.problem.dim*sqrt(peakNum(ProblemNumber)));
        CurrentSummary.MaxFitnessEvaluations = floor(2000*CurrentSummary.problem.dim*sqrt(peakNum(ProblemNumber)));
    elseif strcmpi(EvaluationTime, 'mid')
        CurrentSummary.problem.max_fes = 400000;
        CurrentSummary.MaxFitnessEvaluations = 400000;
    else
        CurrentSummary.problem.max_fes = floor(400000*CurrentSummary.problem.dim);
        CurrentSummary.MaxFitnessEvaluations = floor(400000*CurrentSummary.problem.dim);
    end
    [CurrentSummary.problem.lower_bound, CurrentSummary.problem.upper_bound] = niching_func_bound_cons(ProblemNumber, CurrentSummary.problem.dim);
    CurrentSummary.problem.radius = radius(ProblemNumber);
    CurrentSummary.ProblemNumber = ProblemNumber;

    if IfParallel
        %% Parallel Evaluate
        D = parallel.pool.DataQueue;
        afterEach(D, @(x) UpdateExperimentalResult(CurrentSummary, x));
        parfor RunNumber = 1:CurrentSummary.RunNumber
            rng('shuffle');
            if strcmpi(AlgorithmName, 'baseline')
                [population] = fNSDE_LSHADE44(CurrentSummary, ProblemNumber);
            else
                [population] = mPSO(AlgorithmName, CurrentSummary, ProblemNumber);
            end
            Results = NaN(1, 5);
            for AccuricyIndex = 1:length(CurrentSummary.Accuracies)
                [count, ~] = count_goptima(population, CurrentSummary.problem, CurrentSummary.Accuracies(AccuricyIndex));
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
        %% Non-Parallel Evaluate
        for RunNumber = 1:CurrentSummary.RunNumber
            if strcmpi(AlgorithmName, 'baseline')
                [population] = fNSDE_LSHADE44(CurrentSummary, ProblemNumber);
            else
                [population] = mPSO(AlgorithmName, CurrentSummary, ProblemNumber);
            end
            for AccuricyIndex = 1:length(CurrentSummary.Accuracies)
                [count, ~] = count_goptima(population, CurrentSummary.problem, CurrentSummary.Accuracies(AccuricyIndex));
                peak_num = CurrentSummary.PeakNumbers(1, ProblemNumber);
                fprintf('f_%d, the peak ratio of run %d with accuracy=%f is %f!\n', ProblemNumber, RunNumber, CurrentSummary.Accuracies(1, AccuricyIndex), count/peak_num);
                CurrentSummary.FoundedPeaks(ProblemNumber, RunNumber, AccuricyIndex) = count;
            end
            CurrentSummary.WriteAllSummary();
        end
    end
end
