function [FinalPopulation] = mPSO(CurrentSummary, ProblemNumber)
    %% Constant Parameters
    x = 0.729843788;
    c1 = 2.05;
    c2 = 2.05;
    SwarmNumber = 60;
    PopulationSize = 10;
    PenaltyFactor = 1000;
    Dimension = CurrentSummary.Dimensions(1, ProblemNumber);
    UpperBound = CurrentSummary.UpperBound{1, ProblemNumber}(1);
    LowerBound = CurrentSummary.LowerBound{1, ProblemNumber}(1);
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

    %% Initialization
    EvaluationTime = 0;
    for SwarmIndex = 1:SwarmNumber
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

    %% Main loop
    while true
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

        %% Check if evaluation times exceed
        if EvaluationTime > MaxEvaluationTime
            break;
        end
    end

    FinalPopulation = reshape(PbestIndividual, PopulationSize * SwarmNumber, Dimension);
end