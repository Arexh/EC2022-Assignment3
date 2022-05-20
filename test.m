addpath(genpath("benchmark"));
addpath(genpath('modification'));

RunNumber = 32;
CurrentSummary = Summary('mPSO_hybrid_400000', RunNumber);
CurrentSummary.ReadDataFromFiles();

PeakRatios = NaN(CurrentSummary.ProblemTotalNum, length(CurrentSummary.Accuracies));
SuccessRatios = NaN(CurrentSummary.ProblemTotalNum, length(CurrentSummary.Accuracies));
for ProblemNumberIndex = 1:size(PeakRatios, 1)
    for AccuracyIndex = 1:size(PeakRatios, 2)
        PeakRatios(ProblemNumberIndex, AccuracyIndex) = mean(CurrentSummary.FoundedPeaks(ProblemNumberIndex, :, AccuracyIndex));
        SuccessRatios(ProblemNumberIndex, AccuracyIndex) = mean(CurrentSummary.FoundedPeaks(ProblemNumberIndex, :, AccuracyIndex) == 1);
    end
end

disp(PeakRatios);
disp(SuccessRatios);