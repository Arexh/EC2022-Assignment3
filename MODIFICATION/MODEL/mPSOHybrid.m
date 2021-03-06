classdef mPSOHybrid < mPSOFeasible

    properties (Constant = true)
        %% Constant Parameters
        C3 = 0.20;
        C4 = 0.20;
        Alpha = 0.4;
    end

    methods

        function obj = mPSOHybrid(CurrentSummary, ProblemNumber)
            %% Initialization
            obj = obj@mPSOFeasible(CurrentSummary, ProblemNumber);
        end

        function Initialization(obj)
            for SwarmIndex = 1:obj.SwarmNumber
                obj.SearchSwarms{1, SwarmIndex} = HybridSwarmModel(obj.PopulationSize, obj.Dimension, SwarmIndex);
                obj.InitializeSearchSwarm(obj.SearchSwarms{1, SwarmIndex});
            end
        end

        function InitializeFeasibleSwarm(obj, HybridSwarmModel, LowerBound, UpperBound)
            InitializeFeasibleSwarm@mPSOFeasible(obj, HybridSwarmModel, LowerBound, UpperBound);
            HybridSwarmModel.PbestFeasibleIndividuals(:, :) = HybridSwarmModel.Individuals(:, :);
            HybridSwarmModel.PbestFeasibleFitnesses(:, :) = HybridSwarmModel.Fitnesses(:, :);
            [HybridSwarmModel.GbestFeasibleFitness(1, 1), GbestIndex] = min(HybridSwarmModel.Fitnesses(:, 1));
            HybridSwarmModel.GbestFeasibleIndividual(1, :) = HybridSwarmModel.Individuals(GbestIndex, :);
        end

        function PSO(obj, HybridSwarmModel)
            %% Apply PSO to the Swarm
            %% Calculate Hybrid Particle Velocity
            EvalutionTimeRatio = 1 - obj.EvaluationTime / obj.MaxEvaluationTime;
            CurrentShape = size(HybridSwarmModel.Velocities);
            CurrentInertia = obj.Inertia;
            FeasibleVector = obj.C1 * rand(CurrentShape) .* (HybridSwarmModel.PbestFeasibleIndividuals - HybridSwarmModel.Individuals) ...
            + obj.C2 * rand(CurrentShape) .* (reshape(repmat(HybridSwarmModel.GbestFeasibleIndividual, CurrentShape(1), 1), CurrentShape) -  HybridSwarmModel.Individuals);
            NonConstrainedVector = obj.C3 * EvalutionTimeRatio * rand(CurrentShape) .* (HybridSwarmModel.PbestIndividuals - HybridSwarmModel.Individuals) ...
            + obj.C4 * EvalutionTimeRatio * rand(CurrentShape) .* (reshape(repmat(HybridSwarmModel.GbestIndividual, CurrentShape(1), 1), CurrentShape) -  HybridSwarmModel.Individuals);
            CombinedVector = FeasibleVector;
            RandomSelect = rand(size(NonConstrainedVector)) < obj.Alpha * EvalutionTimeRatio;
            CombinedVector(RandomSelect) = CombinedVector(RandomSelect) + NonConstrainedVector(RandomSelect);
            HybridSwarmModel.Velocities(:, :) = obj.X * (CurrentInertia * HybridSwarmModel.Velocities + CombinedVector);
            %% Update Population
            HybridSwarmModel.Individuals(:, :) = HybridSwarmModel.Individuals + HybridSwarmModel.Velocities;
        end

        function UpdatePbest(~, HybridSwarmModel)
            %% Intialize personal best: best individual of index-based specie
            %% Update feasible individuals
            UpdateIndex = find((HybridSwarmModel.Violations == 0) & (HybridSwarmModel.Fitnesses < HybridSwarmModel.PbestFeasibleFitnesses));
            HybridSwarmModel.PbestFeasibleIndividuals(UpdateIndex, :) = HybridSwarmModel.Individuals(UpdateIndex, :);
            HybridSwarmModel.PbestFeasibleFitnesses(UpdateIndex, 1) = HybridSwarmModel.Fitnesses(UpdateIndex, 1);
            %% Update non-constrained individuals
            UpdateIndex = find(HybridSwarmModel.Fitnesses < HybridSwarmModel.PbestFitnesses);
            HybridSwarmModel.PbestIndividuals(UpdateIndex, :) = HybridSwarmModel.Individuals(UpdateIndex, :);
            HybridSwarmModel.PbestFitnesses(UpdateIndex, 1) = HybridSwarmModel.Fitnesses(UpdateIndex, 1);
            HybridSwarmModel.PbestViolations(UpdateIndex, 1) = HybridSwarmModel.Violations(UpdateIndex, 1);
        end

        function UpdateGbest(obj, HybridSwarmModel)
            %% Update non-constrained Gbest
            [HybridSwarmModel.GbestFitness(1, 1), GbestIndex] = min(HybridSwarmModel.PbestFitnesses(:, 1));
            HybridSwarmModel.GbestIndividual(1, :) = HybridSwarmModel.PbestIndividuals(GbestIndex, :);
            HybridSwarmModel.GbestViolation(:, 1) = HybridSwarmModel.PbestViolations(GbestIndex, 1);
            %% Update feasible Gbest
            [HybridSwarmModel.GbestFeasibleFitness(1, 1), GbestIndex] = min(HybridSwarmModel.PbestFeasibleFitnesses(:, 1));
            HybridSwarmModel.GbestFeasibleIndividual(1, :) = HybridSwarmModel.PbestFeasibleIndividuals(GbestIndex, :);
        end

        function GenerationFinish(obj)
            %% Exclusion
            obj.Exclusion();
            %% Record Current Peak Ratio
            % obj.RecordPeakRatio();
            %% Increase Generation Counter
            obj.Generation = obj.Generation + 1;
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