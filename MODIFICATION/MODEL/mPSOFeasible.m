classdef mPSOFeasible < mPSOBase

    methods

        function obj = mPSOFeasible(CurrentSummary, ProblemNumber)
            %% Initialization
            obj = obj@mPSOBase(CurrentSummary, ProblemNumber);
        end

        function InitializeSearchSwarm(obj, SearchSwarm)
            obj.InitializeFeasibleSwarm(SearchSwarm, obj.LowerBound, obj.UpperBound);
            obj.UpdatePbest(SearchSwarm);
            obj.UpdateGbest(SearchSwarm);
        end

        function InitializeFeasibleSwarm(obj, SwarmModel, LowerBound, UpperBound)
            %% Individual Initialization: Random Sampling, Until All Individuals are Feasible
            SwarmModel.Violations = ones(size(SwarmModel.Violations));

            while true
                % Find infeasible individuals
                IndividualIndex = find(SwarmModel.Violations > 0);
                % If no infeasible individuals, break loop
                if isempty(IndividualIndex); break; end
                % Random init infeasible individuals
                SwarmModel.Individuals(IndividualIndex, :) = LowerBound + (UpperBound - LowerBound) .* rand(size(SwarmModel.Individuals(IndividualIndex, :)));
                % Evaluate infeasible individuals (updated)
                [SwarmModel.Fitnesses(IndividualIndex, 1), G, H] = obj.ObjectiveFunction(SwarmModel.Individuals(IndividualIndex, :));
                % Update violations
                SwarmModel.Violations(IndividualIndex, 1) = obj.ViolationFuncion(G, H, obj.Epsim);
                % Increase evalution time
                obj.EvaluationTime = obj.EvaluationTime + length(IndividualIndex);
                % If evalution time is run out, then terminate
                if obj.IsTerminal(); break; end
            end

            % Velocity Initialization: Zero Init
            SwarmModel.Velocities(:, :) = 0;
        end

        function UpdatePbest(~, SwarmModel)
            %% Intialize personal best: best individual of index-based specie
            % Find feasible individuals
            UpdateIndex = find((SwarmModel.Violations == 0) & (SwarmModel.Fitnesses < SwarmModel.PbestFitnesses));
            SwarmModel.PbestIndividuals(UpdateIndex, :) = SwarmModel.Individuals(UpdateIndex, :);
            SwarmModel.PbestFitnesses(UpdateIndex, 1) = SwarmModel.Fitnesses(UpdateIndex, 1);
            SwarmModel.PbestViolations(UpdateIndex, 1) = SwarmModel.Violations(UpdateIndex, 1);
        end

    end

end