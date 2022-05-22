function [FinalPopulation] = NCDE(CurrentSummary, ProblemNumber)
    Dimension = CurrentSummary.Dimensions(1, ProblemNumber);
    UpperBound = CurrentSummary.UpperBound{1, ProblemNumber}(1);
    LowerBound = CurrentSummary.LowerBound{1, ProblemNumber}(1);
    PopulationSize = floor(60 * sqrt(Dimension));
    CurrentSummary.PopulationForLSHADE = LowerBound + (UpperBound - LowerBound) * rand(PopulationSize, Dimension);
    CurrentSummary.CurrentEvalutionTime = 10000;

    % %% Constant Parameters
    % PopulationSize = 40;
    % F = 0.9;
    % CR = 0.1;
    % SpecieNumber = 10;
    % ObjectiveFunction = CurrentSummary.ObjectiveFunctions{1, ProblemNumber};
    % ViolationFuncion = @sum_vio;
    % MaxEvaluationTime = CurrentSummary.MaxFitnessEvaluations(1, ProblemNumber);

    % Individuals = zeros(PopulationSize, Dimension);
    % Fitnesses = zeros(PopulationSize, 1);
    % Violations = zeros(PopulationSize, 1);

    % Individuals(:, :) = LowerBound + (UpperBound - LowerBound) * rand(PopulationSize, Dimension);
    % [Fitnesses(:, 1), G, H] = ObjectiveFunction(Individuals);
    % Violations(:, 1) = ViolationFuncion(G, H, CurrentSummary.Epsim);
    % EvalutionTime = PopulationSize;

    % Spacies = GetSpecies(Individuals, Fitnesses, Violations, SpecieNumber);
    
    % while true
    %     NextIndividuals = zeros(PopulationSize, Dimension);
    %     NextFitnesses = zeros(PopulationSize, 1);
    %     NextViolations = zeros(PopulationSize, 1);
    %     for IndividualIndex = 1:PopulationSize
    %         SameSpecieIndexes = find(Spacies(IndividualIndex) == Spacies);
    %         SameSpecieIndexes(SameSpecieIndexes == IndividualIndex) = [];
    %         RandomPerm = randperm(length(SameSpecieIndexes));
    %         SameSpecieIndexes = SameSpecieIndexes(RandomPerm);
    %         V = Individuals(SameSpecieIndexes(1), :) + F * (Individuals(SameSpecieIndexes(2), :) - Individuals(SameSpecieIndexes(3), :));
    %         NextIndividuals(IndividualIndex, :) = Individuals(IndividualIndex, :);
    %         RandomSelect = rand(1, Dimension) < CR;
    %         NextIndividuals(IndividualIndex, RandomSelect) = V(1, RandomSelect);
    %     end

    %     [NextFitnesses(:, 1), G, H] = ObjectiveFunction(NextIndividuals);
    %     NextViolations(:, 1) = ViolationFuncion(G, H, CurrentSummary.Epsim);
    %     NextFitnesses(:, 1) = NextFitnesses(:, 1) + 10 * NextViolations(:, 1);

    %     UpdateIndex = find(NextFitnesses < Fitnesses);
    %     Individuals(UpdateIndex) = NextIndividuals(UpdateIndex);
    %     Fitnesses(UpdateIndex) = NextFitnesses(UpdateIndex);

    %     EvalutionTime = EvalutionTime + PopulationSize;

    %     if EvalutionTime > MaxEvaluationTime
    %         break
    %     end
    % end

    FinalPopulation = fNSDE_LSHADE44(CurrentSummary, ProblemNumber);
end

function [Species] = GetSpecies(Individuals, Fitnesses, Violations, SpecieSize)
    PopulationSize = size(Individuals, 1);
    [~, Rank] = sort(Fitnesses(:, 1) + 1e100 * Violations(:, 1));
    Species = zeros(1, PopulationSize);
    SpecieNumber = floor(PopulationSize / SpecieSize);
    Distances = pdist(Individuals);
    for SpecieIndex = 1:SpecieNumber
        BestIndividual = Rank(find(~Species(Rank), 1, 'first')); % find first non-species element with highest score
        Species(BestIndividual) = SpecieIndex;
        for j = 2:SpecieSize
            ValidIndex = find(~Species);
            if isempty(ValidIndex)
                break
            end
            [~, MinimunIndex] = min(Distances(ValidIndex));
            Species(ValidIndex(MinimunIndex)) = SpecieIndex;
        end
    end
    Species(~Species) = SpecieNumber;
end