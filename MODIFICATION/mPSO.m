function [FinalPopulation] = mPSO(CurrentSummary, ProblemNumber)
    mPSOInstance = mPSOModel(CurrentSummary, ProblemNumber);

    %% Initialize Swarms
    mPSOInstance.Initialization();

    %% Main loop
    while true
        %% Algorithm Start
        for SwarmIndex = 1:mPSOInstance.SwarmNumber
            % Apply PSO to CurrentSwarm, then update CurrentSwarm
            CurrentSwarm = mPSOInstance.SearchSwarms{1, SwarmIndex};
            mPSOInstance.PSO(CurrentSwarm);
            mPSOInstance.CheckRange(CurrentSwarm);
            mPSOInstance.Evaluate(CurrentSwarm);
            mPSOInstance.UpdatePbest(CurrentSwarm);
            mPSOInstance.UpdateGbest(CurrentSwarm);
            % Check if evaluation times exceed
            if mPSOInstance.IsTerminal()
                break;
            end
        end

        %% Exclusion
        mPSOInstance.Exclusion();

        % Check if evaluation times exceed
        if mPSOInstance.IsTerminal()
            break;
        end
    end

    FinalPopulation = mPSOInstance.Output();
end