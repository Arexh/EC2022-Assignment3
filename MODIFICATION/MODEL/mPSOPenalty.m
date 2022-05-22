classdef mPSOPenalty < mPSOBase

    properties (Constant = true)
        %% Constant Parameters
        PenaltyFactor = 10;
    end

    methods

        function obj = mPSOPenalty(CurrentSummary, ProblemNumber)
            %% Initialization
            obj = obj@mPSOBase(CurrentSummary, ProblemNumber);
        end

        function EvaluateSearchSwarm(obj, SearchSwarm)
            %% Evaluation Swarm for Fitness and Violation
            [SearchSwarm.Fitnesses(:, 1), G, H] = obj.ObjectiveFunction(SearchSwarm.Individuals);
            SearchSwarm.Violations(:, 1) = obj.ViolationFuncion(G, H, obj.Epsim);
            %% Penalize Fitness by Adding Violation
            SearchSwarm.Fitnesses(:, 1) = SearchSwarm.Fitnesses(:, 1) + obj.PenaltyFactor * SearchSwarm.Violations(:, 1);
            %% Increase Evalution Time
            obj.EvaluationTime = obj.EvaluationTime + obj.PopulationSize;
        end

    end

end