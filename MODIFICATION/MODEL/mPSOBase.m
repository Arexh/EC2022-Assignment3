classdef mPSOBase < handle

    properties
        %% Define Varibles
        Epsim; % Scalar
        Dimension; % Scalar
        LowerBound; % Scalar
        UpperBound; % Scalar
        EvaluationTime; % Scalar
        ExclusionLimit; % Scalar
        MaxEvaluationTime; % Scalar
        ObjectiveFunction; % Function that given individuals, return fitness
        ViolationFuncion; % Function that given individuals, return sum of violation
        SearchSwarms; % 1 x SwarmNumber SwarmModel (cell)
        Generation; % Scalar
        HistoryFitnesses; % 1 x MaxEvaluationTime matrix
        HistoryViolations; % 1 x MaxEvaluationTime matrix
        HistoryPeakRatio;
        CurrentSummary;
    end

    properties (Constant = true)
        %% Constant Parameters
        X = 0.729843788;
        C1 = 2.05;
        C2 = 2.6;
        SwarmNumber = 15;
        PopulationSize = 8;
        Inertia = 0.93;
    end

    methods

        function obj = mPSOBase(CurrentSummary, ProblemNumber)
            %% Initialization
            obj.Epsim = CurrentSummary.Epsim;
            obj.Dimension = CurrentSummary.Dimensions(1, ProblemNumber);
            obj.LowerBound = CurrentSummary.LowerBound{1, ProblemNumber}(1);
            obj.UpperBound = CurrentSummary.UpperBound{1, ProblemNumber}(1);
            obj.EvaluationTime = 0;
            obj.ExclusionLimit = 1e-9 * ((obj.UpperBound - obj.LowerBound) / ((obj.SwarmNumber) ^ (1 / obj.Dimension)));
            obj.MaxEvaluationTime = CurrentSummary.MaxFitnessEvaluations;
            obj.ObjectiveFunction = CurrentSummary.ObjectiveFunctions{1, ProblemNumber};
            obj.ViolationFuncion = @sum_vio;
            obj.SearchSwarms = cell(1, obj.SwarmNumber);
            obj.Generation = 1;
            obj.HistoryFitnesses = inf(1, obj.MaxEvaluationTime);
            obj.HistoryViolations = inf(1, obj.MaxEvaluationTime);
            obj.HistoryPeakRatio = inf(5, floor(obj.MaxEvaluationTime / (obj.PopulationSize * obj.SwarmNumber)));
            obj.CurrentSummary = CurrentSummary;
        end

        function InitializeSwarm(~, SwarmModel, LowerBound, UpperBound)
            % Individual Initialization: Random Sampling
            SwarmModel.Individuals(:, :) = LowerBound + (UpperBound - LowerBound) .* rand(size(SwarmModel.Individuals));
            % Velocity Initialization: Zero Init
            SwarmModel.Velocities(:, :) = 0;
        end

        function InitializeSearchSwarm(obj, SearchSwarm)
            obj.InitializeSwarm(SearchSwarm, obj.LowerBound, obj.UpperBound);
            obj.CheckRange(SearchSwarm, obj.LowerBound, obj.UpperBound);
            obj.EvaluateSearchSwarm(SearchSwarm);
            obj.UpdatePbest(SearchSwarm);
            obj.UpdateGbest(SearchSwarm);
        end

        function PSO(obj, SwarmModel)
            %% Apply PSO to the Swarm
            % Calculate Velocity
            CurrentShape = size(SwarmModel.Velocities);
            SwarmModel.Velocities(:, :) = obj.X * (obj.Inertia * SwarmModel.Velocities ...
            + (obj.C1 * rand(CurrentShape) .* (SwarmModel.PbestIndividuals - SwarmModel.Individuals) ...
            +  obj.C2 * rand(CurrentShape) .* (reshape(repmat(SwarmModel.GbestIndividual, CurrentShape(1), 1), CurrentShape) -  SwarmModel.Individuals)));
            % Update Population
            SwarmModel.Individuals(:, :) = SwarmModel.Individuals + SwarmModel.Velocities;
        end

        function CheckRange(obj, SwarmModel, LowerBound, UpperBound)
            %% Check Range for Individual and Velocity
            % Dimension that larger than upperbound
            LargerIndex = SwarmModel.Individuals > UpperBound;
            SwarmModel.Individuals(LargerIndex) = UpperBound;
            SwarmModel.Velocities(LargerIndex) = 0;
            % Dimension that smaller than lowerbound
            SmallerIndex = SwarmModel.Individuals < LowerBound;
            SwarmModel.Individuals(SmallerIndex) = LowerBound;
            SwarmModel.Velocities(SmallerIndex) = 0;
        end

        function EvaluateSearchSwarm(obj, SearchSwarm)
            % Evaluation Swarm for Fitness and Violation
            [SearchSwarm.Fitnesses(:, 1), G, H] = obj.ObjectiveFunction(SearchSwarm.Individuals);
            SearchSwarm.Violations(:, 1) = obj.ViolationFuncion(G, H, obj.Epsim);
            SearchSwarm.Fitnesses(:, 1) = SearchSwarm.Fitnesses(:, 1);
            obj.HistoryFitnesses(1, obj.EvaluationTime+1:obj.EvaluationTime+obj.PopulationSize) = SearchSwarm.Fitnesses(:, 1)';
            obj.HistoryViolations(1, obj.EvaluationTime+1:obj.EvaluationTime+obj.PopulationSize) = SearchSwarm.Violations(:, 1)';
            % Increase Evalution Time
            obj.EvaluationTime = obj.EvaluationTime + obj.PopulationSize;
        end

        function UpdatePbest(~, SwarmModel)
            % Intialize personal best: best individual of index-based specie
            UpdateIndex = SwarmModel.Fitnesses(:, 1) < SwarmModel.PbestFitnesses(:, 1);
            SwarmModel.PbestIndividuals(UpdateIndex, :) = SwarmModel.Individuals(UpdateIndex, :);
            SwarmModel.PbestFitnesses(UpdateIndex, 1) = SwarmModel.Fitnesses(UpdateIndex, 1);
            SwarmModel.PbestViolations(UpdateIndex, 1) = SwarmModel.Violations(UpdateIndex, 1);
        end

        function UpdateGbest(~, SwarmModel)
            % Initialize global best: best of all individuals (minimize fitness)
            [SwarmModel.GbestFitness(1, 1), GbestIndex] = min(SwarmModel.PbestFitnesses(:, 1));
            SwarmModel.GbestIndividual(1, :) = SwarmModel.PbestIndividuals(GbestIndex, :);
            SwarmModel.GbestViolation(:, 1) = SwarmModel.PbestViolations(GbestIndex, 1);
        end

        function Exclusion(obj)
            %% If Two Gbest is Too Close, Reinitialize the One with Inferior Fitness
            GbestIndividuals = zeros(obj.SwarmNumber, obj.Dimension);
            for SwarmIndex = 1:obj.SwarmNumber
                GbestIndividuals(SwarmIndex, :) = obj.SearchSwarms{1, SwarmIndex}.GbestIndividual;
            end
            IndexToExclusion = pdist(GbestIndividuals) < obj.ExclusionLimit;
            Count = 1;
            for i = 1:obj.SwarmNumber-1
                for j = i+1:obj.SwarmNumber
                    if IndexToExclusion(Count) == 1
                        if obj.SearchSwarms{1, i}.GbestFitness < obj.SearchSwarms{1, j}.GbestFitness
                            obj.InitializeSearchSwarm(obj.SearchSwarms{1, j});
                        else
                            obj.InitializeSearchSwarm(obj.SearchSwarms{1, i});
                        end
                    end
                    Count = Count + 1;
                end
            end
        end

        %% Interface

        function Initialization(obj)
            for SwarmIndex = 1:obj.SwarmNumber
                obj.SearchSwarms{1, SwarmIndex} = SwarmModel(obj.PopulationSize, obj.Dimension, SwarmIndex);
                obj.InitializeSearchSwarm(obj.SearchSwarms{1, SwarmIndex});
            end
        end

        function UpdateSwarm(obj, SwarmIndex)
            CurrentSwarm = obj.SearchSwarms{1, SwarmIndex};
            obj.PSO(CurrentSwarm);
            obj.CheckRange(CurrentSwarm, obj.LowerBound, obj.UpperBound);
            obj.EvaluateSearchSwarm(CurrentSwarm);
            obj.UpdatePbest(CurrentSwarm);
            obj.UpdateGbest(CurrentSwarm);
        end

        function GenerationFinish(obj)
            %% Exclusion
            obj.Exclusion();
            %% Record Current Peak Ratio
            % obj.RecordPeakRatio();
            %% Increase Generation Counter
            obj.Generation = obj.Generation + 1;
        end

        function [Flag] = IsTerminal(obj)
            Flag = obj.EvaluationTime >= obj.MaxEvaluationTime;
        end

        function [FinalPopulation] = Output(obj)
            FinalPopulation = zeros(obj.SwarmNumber * obj.PopulationSize, obj.Dimension);
            for SwarmIndex = 1:obj.SwarmNumber
                FinalPopulation(1 + (SwarmIndex - 1) * obj.PopulationSize:SwarmIndex * obj.PopulationSize, :) = ...
                    obj.SearchSwarms{1, SwarmIndex}.PbestIndividuals;
            end
        end

        function RecordPeakRatio(obj)
            CurrentPopulation = obj.Output();
            PeakNumber = obj.CurrentSummary.PeakNumbers(1, obj.CurrentSummary.ProblemNumber);
            for AccuricyIndex = 1:length(obj.CurrentSummary.Accuracies)
                [Count, ~] = count_goptima(CurrentPopulation, obj.CurrentSummary.problem, obj.CurrentSummary.Accuracies(1, AccuricyIndex));
                obj.HistoryPeakRatio(AccuricyIndex, obj.Generation) = Count / PeakNumber;
            end
        end

    end

end