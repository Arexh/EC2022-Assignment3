function [FinalPopulation] = mPSO(CurrentSummary, ProblemNumber)
    mPSOInstance = mPSOModel(CurrentSummary, ProblemNumber);

    %% Initialize Swarms (both search and adaptive)
    mPSOInstance.Initialization();

    GenerationCounter = 0;
    %% Main loop
    while true
        GenerationCounter = GenerationCounter + 1;
        %% Algorithm Start
        for SwarmIndex = 1:mPSOInstance.SwarmNumber
            % Apply PSO to CurrentSwarm, then update CurrentSwarm
            CurrentSwarm = mPSOInstance.SearchSwarms{1, SwarmIndex};
            mPSOInstance.PSO(CurrentSwarm);
            mPSOInstance.CheckRange(CurrentSwarm);
            mPSOInstance.EvaluateSearchSwarm(CurrentSwarm);
            mPSOInstance.UpdatePbest(CurrentSwarm);
            mPSOInstance.UpdateGbest(CurrentSwarm);
            % Check if evaluation times exceed
            if mPSOInstance.IsTerminal()
                break;
            end
        end

        % if mPSOInstance.EvaluationTime < mPSOInstance.MaxEvaluationTime * 0.8
        %     AdaptiveSwarm = mPSOInstance.AdaptiveSwarm;
        %     mPSOInstance.PSO(AdaptiveSwarm);
        %     mPSOInstance.EvaluateAdaptiveSwarm(AdaptiveSwarm);
        %     mPSOInstance.UpdatePbest(AdaptiveSwarm);
        %     mPSOInstance.UpdateGbest(AdaptiveSwarm);
        % end
        % disp(AdaptiveSwarm.Individuals);

        % AdaptiveSwarm = mPSOInstance.AdaptiveSwarm;
        % mPSOInstance.PSO(AdaptiveSwarm);
        % mPSOInstance.EvaluateAdaptiveSwarm(AdaptiveSwarm);
        % mPSOInstance.UpdatePbest(AdaptiveSwarm);
        % mPSOInstance.UpdateGbest(AdaptiveSwarm);
        % disp(AdaptiveSwarm.Individuals);

        % if mod(GenerationCounter, 1) == 0
        %     AdaptiveSwarm = mPSOInstance.AdaptiveSwarm;
        %     mPSOInstance.PSO(AdaptiveSwarm);
        %     mPSOInstance.EvaluateAdaptiveSwarm(AdaptiveSwarm);
        %     mPSOInstance.UpdatePbest(AdaptiveSwarm);
        %     mPSOInstance.UpdateGbest(AdaptiveSwarm);
        % end

        %% Exclusion
        mPSOInstance.Exclusion();

        % Check if evaluation times exceed
        if mPSOInstance.IsTerminal()
            break;
        end
    end

    FinalPopulation = mPSOInstance.Output();
end