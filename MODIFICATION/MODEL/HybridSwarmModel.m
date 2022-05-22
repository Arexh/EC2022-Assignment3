classdef HybridSwarmModel < SwarmModel

    properties
        %% Define Varibles
        PbestFeasibleIndividuals; % Pop x Dim Matrix
        PbestFeasibleFitnesses; % Pop x 1 Matrix
        GbestFeasibleIndividual; % 1 x Dim Matrix
        GbestFeasibleFitness; % 1 x 1 Matrix
    end

    methods

        function obj = HybridSwarmModel(PopulationSize, Dimension, Index)
            obj = obj@SwarmModel(PopulationSize, Dimension, Index);
            obj.PbestFeasibleIndividuals = zeros(PopulationSize, Dimension);
            obj.PbestFeasibleFitnesses = inf(PopulationSize, 1);
            obj.GbestFeasibleIndividual = zeros(1, Dimension);
            obj.GbestFeasibleFitness = zeros(1, 1);
        end

    end

end