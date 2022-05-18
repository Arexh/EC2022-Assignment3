classdef mPSOHybridVelocity < handle

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
        SearchSwarms; % 1 x SwarmNumber HybridSwarmModel (cell)
        GbestShiftDistance; % Scalar
    end

    properties (Constant = true)
        %% Constant Parameters
        X = 0.729843788;
        C1 = 2.65;
        C2 = 2.05;
        C3 = 0.25;
        C4 = 0.25;
        SwarmNumber = 15;
        PopulationSize = 8;
        Inertia = 0.93;
    end

    methods

        function obj = mPSOHybridVelocity(CurrentSummary, ProblemNumber)
            %% Initialization
            obj.Epsim = CurrentSummary.Epsim;
            obj.Dimension = CurrentSummary.Dimensions(1, ProblemNumber);
            obj.LowerBound = CurrentSummary.LowerBound{1, ProblemNumber}(1);
            obj.UpperBound = CurrentSummary.UpperBound{1, ProblemNumber}(1);
            obj.EvaluationTime = 0;
            obj.ExclusionLimit = 1e-9 * ((obj.UpperBound - obj.LowerBound) / ((obj.SwarmNumber) ^ (1 / obj.Dimension)));
            obj.MaxEvaluationTime = CurrentSummary.MaxFitnessEvaluations(1, ProblemNumber);
            obj.ObjectiveFunction = CurrentSummary.ObjectiveFunctions{1, ProblemNumber};
            obj.ViolationFuncion = @sum_vio;
            obj.SearchSwarms = cell(1, obj.SwarmNumber);
            obj.GbestShiftDistance = inf;
        end

        function Initialization(obj)
            for SwarmIndex = 1:obj.SwarmNumber
                obj.SearchSwarms{1, SwarmIndex} = HybridSwarmModel(obj.PopulationSize, obj.Dimension, SwarmIndex);
                obj.InitializeSearchSwarm(obj.SearchSwarms{1, SwarmIndex});
            end
        end

        function InitializeSearchSwarm(obj, SearchSwarm)
            obj.InitializeFeasibleSwarm(SearchSwarm, obj.LowerBound, obj.UpperBound);
            obj.UpdatePbest(SearchSwarm);
            obj.UpdateGbest(SearchSwarm);
        end

        function InitializeFeasibleSwarm(obj, HybridSwarmModel, LowerBound, UpperBound)
            %% Individual Initialization: Random Sampling, Until All Individuals are Feasible
            HybridSwarmModel.Violations = ones(size(HybridSwarmModel.Violations));

            while true
                % Find infeasible individuals
                IndividualIndex = find(HybridSwarmModel.Violations > 0);
                % If no infeasible individuals, break loop
                if isempty(IndividualIndex); break; end
                % Random init infeasible individuals
                HybridSwarmModel.Individuals(IndividualIndex, :) = LowerBound + (UpperBound - LowerBound) .* rand(size(HybridSwarmModel.Individuals(IndividualIndex, :)));
                % Evaluate infeasible individuals (updated)
                [HybridSwarmModel.Fitnesses(IndividualIndex, 1), G, H] = obj.ObjectiveFunction(HybridSwarmModel.Individuals(IndividualIndex, :));
                % Update violations
                HybridSwarmModel.Violations(IndividualIndex, 1) = obj.ViolationFuncion(G, H, obj.Epsim);
                % Increase evalution time
                obj.EvaluationTime = obj.EvaluationTime + length(IndividualIndex);
                % If evalution time is run out, then terminate
                if obj.IsTerminal(); break; end
            end

            HybridSwarmModel.PbestFeasibleIndividuals(:, :) = HybridSwarmModel.Individuals(:, :);
            HybridSwarmModel.PbestFeasibleFitnesses(:, :) = HybridSwarmModel.Fitnesses(:, :);
            [HybridSwarmModel.GbestFeasibleFitness(1, 1), GbestIndex] = min(HybridSwarmModel.Fitnesses(:, 1));
            HybridSwarmModel.GbestFeasibleIndividual(1, :) = HybridSwarmModel.Individuals(GbestIndex, :);
            % Velocity Initialization: Zero Init
            HybridSwarmModel.Velocities(:, :) = 0;
        end

        function PSO(obj, HybridSwarmModel)
            %% Apply PSO to the Swarm
            % Calculate Velocity
            EvalutionTimeRatio = 1.2 - obj.EvaluationTime / obj.MaxEvaluationTime;
            CurrentShape = size(HybridSwarmModel.Velocities);
            CurrentInertia = obj.Inertia;
            if obj.GbestShiftDistance < 1e-2
                CurrentInertia = 0.2;
                EvalutionTimeRatio = 0.4;
            end
            FeasibleVector = obj.C1 * rand(CurrentShape) .* (HybridSwarmModel.PbestFeasibleIndividuals - HybridSwarmModel.Individuals) ...
            + obj.C2 * rand(CurrentShape) .* (reshape(repmat(HybridSwarmModel.GbestFeasibleIndividual, CurrentShape(1), 1), CurrentShape) -  HybridSwarmModel.Individuals);
            NonConstrainedVector = obj.C3 * EvalutionTimeRatio * rand(CurrentShape) .* (HybridSwarmModel.PbestIndividuals - HybridSwarmModel.Individuals) ...
            + obj.C4 * EvalutionTimeRatio * rand(CurrentShape) .* (reshape(repmat(HybridSwarmModel.GbestIndividual, CurrentShape(1), 1), CurrentShape) -  HybridSwarmModel.Individuals);
            CombinedVector = FeasibleVector;
            RandomSelect = rand(size(NonConstrainedVector)) < 0.4;
            CombinedVector(RandomSelect) = CombinedVector(RandomSelect) + NonConstrainedVector(RandomSelect);
            HybridSwarmModel.Velocities(:, :) = obj.X * (CurrentInertia * HybridSwarmModel.Velocities + CombinedVector);
            % Update Population
            HybridSwarmModel.Individuals(:, :) = HybridSwarmModel.Individuals + HybridSwarmModel.Velocities;
        end

        function CheckRange(~, HybridSwarmModel, LowerBound, UpperBound)
            %% Check Range for Individual and Velocity
            % Dimension that larger than upperbound
            LargerIndex = HybridSwarmModel.Individuals > UpperBound;
            HybridSwarmModel.Individuals(LargerIndex) = UpperBound;
            HybridSwarmModel.Velocities(LargerIndex) = 0;
            % Dimension that smaller than lowerbound
            SmallerIndex = HybridSwarmModel.Individuals < LowerBound;
            HybridSwarmModel.Individuals(SmallerIndex) = LowerBound;
            HybridSwarmModel.Velocities(SmallerIndex) = 0;
        end

        function EvaluateSearchSwarm(obj, SearchSwarm)
            % Evaluation Swarm for Fitness and Violation
            [SearchSwarm.Fitnesses(:, 1), G, H] = obj.ObjectiveFunction(SearchSwarm.Individuals);
            SearchSwarm.Violations(:, 1) = obj.ViolationFuncion(G, H, obj.Epsim);
            % Increase Evalution Time
            obj.EvaluationTime = obj.EvaluationTime + obj.PopulationSize;
        end

        function UpdatePbest(~, HybridSwarmModel)
            %% Intialize personal best: best individual of index-based specie
            % Update feasible individuals
            UpdateIndex = find((HybridSwarmModel.Violations == 0) & (HybridSwarmModel.Fitnesses < HybridSwarmModel.PbestFeasibleFitnesses));
            HybridSwarmModel.PbestFeasibleIndividuals(UpdateIndex, :) = HybridSwarmModel.Individuals(UpdateIndex, :);
            HybridSwarmModel.PbestFeasibleFitnesses(UpdateIndex, 1) = HybridSwarmModel.Fitnesses(UpdateIndex, 1);
            % Update non-constrained individuals
            UpdateIndex = find(HybridSwarmModel.Fitnesses < HybridSwarmModel.PbestFitnesses);
            HybridSwarmModel.PbestIndividuals(UpdateIndex, :) = HybridSwarmModel.Individuals(UpdateIndex, :);
            HybridSwarmModel.PbestFitnesses(UpdateIndex, 1) = HybridSwarmModel.Fitnesses(UpdateIndex, 1);
            HybridSwarmModel.PbestViolations(UpdateIndex, 1) = HybridSwarmModel.Violations(UpdateIndex, 1);
        end

        function UpdateGbest(obj, HybridSwarmModel)
            % Update non-constrained Gbest
            [HybridSwarmModel.GbestFitness(1, 1), GbestIndex] = min(HybridSwarmModel.PbestFitnesses(:, 1));
            HybridSwarmModel.GbestIndividual(1, :) = HybridSwarmModel.PbestIndividuals(GbestIndex, :);
            HybridSwarmModel.GbestViolation(:, 1) = HybridSwarmModel.PbestViolations(GbestIndex, 1);
            % Update feasible Gbest
            [HybridSwarmModel.GbestFeasibleFitness(1, 1), GbestIndex] = min(HybridSwarmModel.PbestFeasibleFitnesses(:, 1));
            ShiftDistance = pdist2(HybridSwarmModel.GbestFeasibleIndividual(1, :), HybridSwarmModel.PbestFeasibleIndividuals(GbestIndex, :));
            if ~ShiftDistance == 0
                obj.GbestShiftDistance = ShiftDistance;
            end
            HybridSwarmModel.GbestFeasibleIndividual(1, :) = HybridSwarmModel.PbestFeasibleIndividuals(GbestIndex, :);
        end

        function Exclusion(obj)
            GbestIndividuals = zeros(obj.SwarmNumber, obj.Dimension);
            for SwarmIndex = 1:obj.SwarmNumber
                GbestIndividuals(SwarmIndex, :) = obj.SearchSwarms{1, SwarmIndex}.GbestFeasibleIndividual;
            end
            IndexToExclusion = pdist(GbestIndividuals) < obj.ExclusionLimit;
            Count = 1;
            for i = 1:obj.SwarmNumber-1
                for j = i+1:obj.SwarmNumber
                    if IndexToExclusion(Count) == 1
                        if obj.SearchSwarms{1, i}.GbestFeasibleFitness < obj.SearchSwarms{1, j}.GbestFeasibleFitness
                            obj.InitializeSearchSwarm(obj.SearchSwarms{1, j});
                        else
                            obj.InitializeSearchSwarm(obj.SearchSwarms{1, i});
                        end
                        break;
                    end
                    Count = Count + 1;
                end
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

        function GenerationFinish(~)
            %% Do Nothing
        end

        function [Flag] = IsTerminal(obj)
            Flag = obj.EvaluationTime >= obj.MaxEvaluationTime;
        end

        function [FinalPopulation] = Output(obj)
            FinalPopulation = zeros(obj.SwarmNumber * obj.PopulationSize, obj.Dimension);
            for SwarmIndex = 1:obj.SwarmNumber
                FinalPopulation(1 + (SwarmIndex - 1) * obj.PopulationSize:SwarmIndex * obj.PopulationSize, :) = ...
                    obj.SearchSwarms{1, SwarmIndex}.PbestFeasibleIndividuals;
            end
        end

    end

end