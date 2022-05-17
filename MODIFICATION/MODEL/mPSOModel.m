classdef mPSOModel < handle

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
        AdaptiveSwarm; % SwarmModel
        SearchSwarms; % 1 x SwarmNumber SwarmModel (cell)
    end

    properties (Constant = true)
        %% Constant Parameters
        X = 0.729843788;
        C1 = 2.05;
        C2 = 2.05;
        SwarmNumber = 10;
        PopulationSize = 20;
        PenaltyFactor = 1000;
    end

    methods

        function obj = mPSOModel(CurrentSummary, ProblemNumber)
            %% Initialization
            obj.Epsim = CurrentSummary.Epsim;
            obj.Dimension = CurrentSummary.Dimensions(1, ProblemNumber);
            obj.LowerBound = CurrentSummary.LowerBound{1, ProblemNumber}(1);
            obj.UpperBound = CurrentSummary.UpperBound{1, ProblemNumber}(1);
            obj.EvaluationTime = 0;
            obj.ExclusionLimit = 1e-9 * ((obj.UpperBound - obj.LowerBound) / ((obj.SwarmNumber) ^ (1 / obj.Dimension)));
            obj.MaxEvaluationTime = CurrentSummary.MaxFitnessEvaluations(1, ProblemNumber);
            obj.ObjectiveFunction = @(Individuals) CurrentSummary.ObjectiveFunctions{1, ProblemNumber}(reshape(Individuals, obj.PopulationSize, obj.Dimension));
            obj.ViolationFuncion = @sum_vio;
            obj.SearchSwarms = cell(1, obj.SwarmNumber);
        end

        function Initialization(obj)
            for SwarmIndex = 1:obj.SwarmNumber
                obj.SearchSwarms{1, SwarmIndex} = SwarmModel(obj.PopulationSize, obj.Dimension);
                obj.InitializeSwarm(obj.SearchSwarms{1, SwarmIndex});
            end
        end

        function InitializeSwarm(obj, SwarmModel)
            % Individual Initialization: Random Sampling
            SwarmModel.Individuals(:, :) = obj.LowerBound + (obj.UpperBound - obj.LowerBound) .* rand(obj.PopulationSize, obj.Dimension);
            % Velocity Initialization: Zero Init
            SwarmModel.Velocities(:, :) = 0;
            obj.CheckRange(SwarmModel);
            obj.Evaluate(SwarmModel);
            obj.UpdatePbest(SwarmModel);
            obj.UpdateGbest(SwarmModel);
        end

        function PSO(obj, SwarmModel)
            %% Apply PSO to the Swarm
            % Calculate Velocity
            CurrentShape = size(SwarmModel.Velocities);
            SwarmModel.Velocities(:, :) = obj.X * (SwarmModel.Velocities ...
            + (obj.C1 * rand(CurrentShape) .* (SwarmModel.PbestIndividuals - SwarmModel.Individuals) ...
            +  obj.C2 * rand(CurrentShape) .* (reshape(repmat(SwarmModel.GbestIndividual, obj.PopulationSize, 1), CurrentShape) -   SwarmModel.Individuals)));
            % Update Population
            SwarmModel.Individuals(:, :) = SwarmModel.Individuals + SwarmModel.Velocities;
        end

        function CheckRange(obj, SwarmModel)
            %% Check Range for Individual and Velocity
            % Dimension that larger than upperbound
            LargerIndex = SwarmModel.Individuals > obj.UpperBound;
            SwarmModel.Individuals(LargerIndex) = obj.UpperBound;
            SwarmModel.Velocities(LargerIndex) = 0;
            % Dimension that smaller than lowerbound
            SmallerIndex = SwarmModel.Individuals < obj.LowerBound;
            SwarmModel.Individuals(SmallerIndex) = obj.LowerBound;
            SwarmModel.Velocities(SmallerIndex) = 0;
        end

        function Evaluate(obj, SwarmModel)
            % Evaluation Swarm for Fitness and Violation
            [SwarmModel.Fitnesses(:, 1), G, H] = obj.ObjectiveFunction(SwarmModel.Individuals);
            SwarmModel.Violations(:, 1) = obj.ViolationFuncion(G, H, obj.Epsim);
            SwarmModel.Fitnesses(:, 1) = SwarmModel.Fitnesses(:, 1) + obj.PenaltyFactor * SwarmModel.Violations(:, 1);
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
                            obj.InitializeSwarm(obj.SearchSwarms{1, j});
                        else
                            obj.InitializeSwarm(obj.SearchSwarms{1, i});
                        end
                    end
                    Count = Count + 1;
                end
            end
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

    end

end