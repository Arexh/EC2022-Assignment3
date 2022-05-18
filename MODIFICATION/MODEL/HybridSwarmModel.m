classdef HybridSwarmModel < handle

    properties
        %% Define Varibles
        PopulationSize; % Scalar
        Dimension; % Scalar
        Epsim; % Scalar
        Individuals; % Pop x Dim Matrix
        Velocities; % Pop x Dim Matrix
        Fitnesses; % Pop x 1 Matrix
        Violations; % Pop x 1 Matrix
        PbestIndividuals; % Pop x Dim Matrix
        PbestFitnesses; % Pop x 1 Matrix
        PbestViolations; % Pop x 1 Matrix
        GbestIndividual; % 1 x Dim Matrix
        GbestFitness; % 1 x 1 Matrix
        GbestViolation; % 1 x 1 Matrix
        PbestFeasibleIndividuals; % Pop x Dim Matrix
        PbestFeasibleFitnesses; % Pop x 1 Matrix
        GbestFeasibleIndividual; % 1 x Dim Matrix
        GbestFeasibleFitness; % 1 x 1 Matrix
        Index; % Scalar
    end

    methods

        function obj = HybridSwarmModel(PopulationSize, Dimension, Index)
            %% Initialization of Population Variables
            obj.Individuals = zeros(PopulationSize, Dimension);
            obj.Velocities = zeros(PopulationSize, Dimension);
            obj.Fitnesses = zeros(PopulationSize, 1);
            obj.Violations = zeros(PopulationSize, 1);
            obj.PbestIndividuals = zeros(PopulationSize, Dimension);
            obj.PbestFitnesses = inf(PopulationSize, 1);
            obj.PbestViolations = zeros(PopulationSize, 1);
            obj.GbestIndividual = zeros(1, Dimension);
            obj.GbestFitness = zeros(1, 1);
            obj.GbestViolation = zeros(1, 1);
            obj.PbestFeasibleIndividuals = zeros(PopulationSize, Dimension);
            obj.PbestFeasibleFitnesses = inf(PopulationSize, 1);
            obj.GbestFeasibleIndividual = zeros(1, Dimension);
            obj.GbestFeasibleFitness = zeros(1, 1);
            obj.Index = Index;
        end

    end

end