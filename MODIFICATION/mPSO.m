function [FinalPopulation] = mPSO(AlgorithmName, CurrentSummary, ProblemNumber)
    %% Create mPSO Instance
    if strcmpi(AlgorithmName, 'mPSO-P')
        mPSOInstance = mPSOPenalty(CurrentSummary, ProblemNumber);
    elseif strcmpi(AlgorithmName, 'mPSO-A')
        mPSOInstance = mPSOAdaptive(CurrentSummary, ProblemNumber);
    elseif strcmpi(AlgorithmName, 'mPSO-F')
        mPSOInstance = mPSOFeasible(CurrentSummary, ProblemNumber);
    else
        mPSOInstance = mPSOHybrid(CurrentSummary, ProblemNumber);
    end
    
    %% Initialize Swarms (both search and adaptive)
    mPSOInstance.Initialization();

    GenerationCounter = 0;
    %% Main loop
    while true
        GenerationCounter = GenerationCounter + 1;
        %% Algorithm Start
        for SwarmIndex = 1:mPSOInstance.SwarmNumber
            %% Apply PSO to CurrentSwarm, then update CurrentSwarm
            mPSOInstance.UpdateSwarm(SwarmIndex);
            %% Check if evaluation times exceed
            if mPSOInstance.IsTerminal()
                break;
            end
        end

        %% Do Exclusion or Update Adaptive Swarm
        mPSOInstance.GenerationFinish();

        %% Check if evaluation times exceed
        if mPSOInstance.IsTerminal()
            break;
        end
    end

    FinalPopulation = mPSOInstance.Output();
end