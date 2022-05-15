%%
clear
addpath(genpath("benchmark")); 
Dims = [1,2,2,5,5,5,10,10,10,1,2,2,1,1,2,2,3,5];
func = @niching_func_cons;
problem.epsim = 1e-4;
peakNum = [2,2,4,2,8,32,2,8,32,10,4,4,2,10,8,24,16,64];
% where to get these radius?
radius = [0.5*ones(1,9), 0.05*ones(1,9)];
accuracy = [0.1; 0.01; 0.001; 0.0001; 0.00001];

runs=25;
for func_num=1:18
    problem.func_num=func_num;
    peak_num = peakNum(func_num);
    problem.dim = Dims(func_num);
    problem.func = @(x) func(x, func_num);
    problem.max_fes = floor(2000*problem.dim*sqrt(peak_num));
    [problem.lower_bound, problem.upper_bound] = niching_func_bound_cons(func_num, problem.dim );
    problem.radius = radius(func_num);
    for j= 1:runs
        [population] = fNSDE_LSHADE44(problem);
        for i = 1:5
            [count, finalseeds] = count_goptima(population, problem, accuracy(i));
            fprintf('f_%d, the peak ratio of run %d with accuracy=%f is %f!\n', func_num,j,accuracy(i),count/peak_num);
        end
    end
end
