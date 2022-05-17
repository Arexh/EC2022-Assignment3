function [FinalPopulation] = mPSO(CurrentSummary, ProblemNumber)
    %% Constant Parameters
    x = 0.729843788;
    c1 = 2.05;
    c2 = 2.05;
    SwarmNumber = 10;
    PopulationSize = 20;
    PenaltyFactor = 1000;
    Dimension = CurrentSummary.Dimensions(1, ProblemNumber);
    UpperBound = CurrentSummary.UpperBound{1, ProblemNumber}(1);
    LowerBound = CurrentSummary.LowerBound{1, ProblemNumber}(1);
    ExclusionLimit = 1e-9 * ((UpperBound - LowerBound) / ((SwarmNumber) ^ (1 / Dimension)));
    ObjectiveFunction = @(Individual) CurrentSummary.ObjectiveFunctions{1, ProblemNumber}(reshape(Individual, PopulationSize, Dimension));
    ViolationFuncion = @sum_vio;
    MaxEvaluationTime = CurrentSummary.MaxFitnessEvaluations(1, ProblemNumber);

    %% Population Variables
    % Indiviudal
    Individual = zeros(SwarmNumber, PopulationSize, Dimension); 
    PbestIndividual = zeros(SwarmNumber, PopulationSize, Dimension); 
    GbestIndividual = zeros(SwarmNumber, Dimension);
    % Fitness
    Fitness = zeros(SwarmNumber, PopulationSize);
    PbestFitness = zeros(SwarmNumber, PopulationSize);
    GbestFitness = zeros(SwarmNumber);
    % Velocity
    Velocity = zeros(SwarmNumber, PopulationSize, Dimension);
    % Violation
    Violation = zeros(SwarmNumber, PopulationSize);
    % Swarm to initialize
    SwarmToInitialize = ones(1, SwarmNumber);
    % Evaluation times
    EvaluationTime = 0;

    %% Main loop
    while true
        %% Initialization
        for SwarmIndex = 1:SwarmNumber
            % If already initialize, then continue
            if ~SwarmToInitialize(1, SwarmIndex); continue; end
            SwarmToInitialize(1, SwarmIndex) = 0;
            % Individual Initialization: Random Sampling
            Individual(SwarmIndex, :, :) = LowerBound + (UpperBound - LowerBound) .* rand(PopulationSize, Dimension);
            % Velocity Initialization: Zero Init
            Velocity(SwarmIndex, :, :) = 0;
            % Evaluation Init Individuals
            [Fitness(SwarmIndex, :), G, H] = ObjectiveFunction(Individual(SwarmIndex, :, :));
            Violation(SwarmIndex, :) = ViolationFuncion(G, H, CurrentSummary.Epsim);
            Fitness(SwarmIndex, :) = Fitness(SwarmIndex, :) + PenaltyFactor * Violation(SwarmIndex, :);
            % Increase Evalution Time
            EvaluationTime = EvaluationTime + PopulationSize;
            % Intialize personal best: best individual of index-based specie
            PbestIndividual(SwarmIndex, :, :) = Individual(SwarmIndex, :, :);
            PbestFitness(SwarmIndex, :) = Fitness(SwarmIndex, :);
            % Initialize global best: best of all individuals (minimize fitness)
            [GbestFitness(SwarmIndex), GbestIndex] = min(PbestFitness(SwarmIndex, :));
            GbestIndividual(SwarmIndex, :) = Individual(SwarmIndex, GbestIndex, :);
        end

        %% Algorithm Start
        for SwarmIndex = 1:SwarmNumber
            %% PSO
            % Calculate Velocity
            CurrentShape = size(Velocity(SwarmIndex, :, :));
            Velocity(SwarmIndex, :, :) = x * (Velocity(SwarmIndex, :, :) ...
            + (c1 * rand(CurrentShape) .* (PbestIndividual(SwarmIndex, :, :) - Individual(SwarmIndex, :, :)) ...
            +  c2 * rand(CurrentShape) .* (reshape(repmat(GbestIndividual(SwarmIndex, :), PopulationSize, 1), CurrentShape) - Individual(SwarmIndex, :, :))));
            % Update Population
            Individual(SwarmIndex, :, :) = Individual(SwarmIndex, :, :) + Velocity(SwarmIndex, :, :);

            %% Check Range
            % Dimension that larger than upperbound
            LargerIndex = Individual(SwarmIndex, :, :) > UpperBound;
            Individual(SwarmIndex, LargerIndex) = UpperBound;
            Velocity(SwarmIndex, LargerIndex) = 0;
            % Dimension that smaller than lowerbound
            SmallerIndex = Individual(SwarmIndex, :, :) < LowerBound;
            Individual(SwarmIndex, SmallerIndex) = LowerBound;
            Velocity(SwarmIndex, SmallerIndex) = 0;

            %% Evaluate population
            [Fitness(SwarmIndex, :), G, H] = ObjectiveFunction(Individual(SwarmIndex, :, :));
            Violation(SwarmIndex, :) = ViolationFuncion(G, H, CurrentSummary.Epsim);
            Fitness(SwarmIndex, :) = Fitness(SwarmIndex, :) + PenaltyFactor * Violation(SwarmIndex, :);
            % Increase Evalution Time
            EvaluationTime = EvaluationTime + PopulationSize;

            %% Update Pbest (minimize fitness)
            UpdateIndex = Fitness(SwarmIndex, :) < PbestFitness(SwarmIndex, :);
            PbestFitness(SwarmIndex, UpdateIndex) = Fitness(SwarmIndex, UpdateIndex);
            PbestIndividual(SwarmIndex, UpdateIndex, :) = Individual(SwarmIndex, UpdateIndex, :);

            %% Update Gbest
            [GbestFitness(SwarmIndex), GbestIndex] = min(PbestFitness(SwarmIndex, :));
            GbestIndividual(SwarmIndex, :) = PbestIndividual(SwarmIndex, GbestIndex, :);

            %% Check if evaluation times exceed
            if EvaluationTime > MaxEvaluationTime
                break;
            end
        end

        %% Exclusion
        IndexToExclusion = pdist(GbestIndividual) < ExclusionLimit;
        Count = 1;
        for i = 1:SwarmNumber-1
            for j = i+1:SwarmNumber
                if IndexToExclusion(Count) == 1
                    if GbestFitness(i) < GbestFitness(j)
                        SwarmToInitialize(1, j) = 1;
                    else
                        SwarmToInitialize(1, i) = 1;
                    end
                end
                Count = Count + 1;
            end
        end

        %% Check if evaluation times exceed
        if EvaluationTime > MaxEvaluationTime
            break;
        end
    end

    FinalPopulation = reshape(PbestIndividual, PopulationSize * SwarmNumber, Dimension);
end