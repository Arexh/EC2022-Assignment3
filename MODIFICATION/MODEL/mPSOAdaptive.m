classdef mPSOAdaptive < mPSOBase

    properties
        %% Define Varibles
        AdaptiveSwarm; % SwarmModel
    end

    properties (Constant = true)
        UpdateInterval = 4;
        AdaptiveLowerBound = 0;
        AdaptiveUpperBound = 100;
    end

    methods

        function obj = mPSOAdaptive(CurrentSummary, ProblemNumber)
            %% Initialization
            obj = obj@mPSOBase(CurrentSummary, ProblemNumber);
        end

        function Initialization(obj)
            obj.AdaptiveSwarm = SwarmModel(obj.SwarmNumber, 1, 1);
            obj.InitializeAdaptiveSwarm(obj.AdaptiveSwarm);
            for SwarmIndex = 1:obj.SwarmNumber
                obj.SearchSwarms{1, SwarmIndex} = SwarmModel(obj.PopulationSize, obj.Dimension, SwarmIndex);
                obj.InitializeSearchSwarm(obj.SearchSwarms{1, SwarmIndex});
            end
            obj.EvaluateAdaptiveSwarm(obj.AdaptiveSwarm);
            obj.UpdatePbest(obj.AdaptiveSwarm);
            obj.UpdateGbest(obj.AdaptiveSwarm);
        end

        function InitializeAdaptiveSwarm(obj, AdaptiveSwarm)
            obj.InitializeSwarm(AdaptiveSwarm, obj.AdaptiveLowerBound, obj.AdaptiveUpperBound);
            obj.CheckRange(AdaptiveSwarm, obj.AdaptiveLowerBound, obj.AdaptiveUpperBound);
        end

        function EvaluateSearchSwarm(obj, SearchSwarm)
            % Evaluation Swarm for Fitness and Violation
            [SearchSwarm.Fitnesses(:, 1), G, H] = obj.ObjectiveFunction(SearchSwarm.Individuals);
            SearchSwarm.Violations(:, 1) = obj.ViolationFuncion(G, H, obj.Epsim);
            SearchSwarm.Fitnesses(:, 1) = SearchSwarm.Fitnesses(:, 1) + obj.AdaptiveSwarm.Individuals(SearchSwarm.Index, 1) * SearchSwarm.Violations(:, 1);
            % Increase Evalution Time
            obj.EvaluationTime = obj.EvaluationTime + obj.PopulationSize;
        end

        function EvaluateAdaptiveSwarm(obj, AdaptiveSwarm)
            MaxValidFitness = 0;
            for SwarmIndex = 1:obj.SwarmNumber
                CurrentSearchSwarm = obj.SearchSwarms{1, SwarmIndex};
                ValidIndex = CurrentSearchSwarm.Violations == 0;
                if sum(ValidIndex) == 0
                    continue;
                end
                MaxValidFitness = max(MaxValidFitness, max(CurrentSearchSwarm.Fitnesses(ValidIndex, :)));
            end

            for IndividualIndex = 1:obj.SwarmNumber
                CurrentSearchSwarm = obj.SearchSwarms{1, IndividualIndex};
                FeasibleSolutionIndex = CurrentSearchSwarm.Violations == 0;
                FeasibleNumber = sum(FeasibleSolutionIndex);
                if FeasibleNumber > 0
                    % At least one feasible solution
                    AdaptiveSwarm.Fitnesses(IndividualIndex, 1) = sum(CurrentSearchSwarm.Fitnesses(FeasibleSolutionIndex, 1)) / FeasibleNumber - FeasibleNumber;
                else
                    % No feasible solution
                    AdaptiveSwarm.Fitnesses(IndividualIndex, 1) = MaxValidFitness + sum(CurrentSearchSwarm.Violations) / obj.PopulationSize - obj.PopulationSize;
                end
            end
        end

        function UpdateAdaptiveSwarm(obj)
            obj.PSO(obj.AdaptiveSwarm);
            obj.EvaluateAdaptiveSwarm(obj.AdaptiveSwarm);
            obj.CheckRange(obj.AdaptiveSwarm, obj.AdaptiveLowerBound, obj.AdaptiveUpperBound);
            obj.UpdatePbest(obj.AdaptiveSwarm);
            obj.UpdateGbest(obj.AdaptiveSwarm);
        end

        function GenerationFinish(obj)
            %% Update Adaptive Swarm
            if mod(obj.Generation, obj.UpdateInterval) == 0
                obj.UpdateAdaptiveSwarm();
            end
            %% Exclusion
            obj.Exclusion();
            %% Record Current Peak Ratio
            obj.RecordPeakRatio();
            %% Increase Generation Counter
            obj.Generation = obj.Generation + 1;
        end

    end

end