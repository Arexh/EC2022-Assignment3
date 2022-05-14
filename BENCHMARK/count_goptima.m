% ******************************************************************************
% * Version: 1.0.1
% * Last modified on: 15 June, 2016 
% * Developers: Michael G. Epitropakis, Xiaodong Li.
% *      email: mge_(AT)_cs_(DOT)_stir_(DOT)_ac_(DOT)_uk 
% *           : xiaodong_(DOT)_li_(AT)_rmit_(DOT)_edu_(DOT)_au 
% * ****************************************************************************
function [count, finalseeds] = count_goptima(pop, problem, accuracy)
% pop: NP, D
peakNum = [2,2,4,2,8,32,2,8,32,10,4,4,2,10,8,24,16,64];

no_goptima = peakNum(problem.func_num);
[NP, ~] = size(pop);
% evaluate pop
%[fpop, Vio] = func(pop, func_num);
[fpop, g,h] = problem.func(pop);
Vio = sum_vio(g,h,problem.epsim);
% descent sorting
fitness = [fpop, Vio, [1:NP]'];
fitness = sortrows(fitness, 1);
fitness = sortrows(fitness, 2);
IX = fitness(:,3);
% Sort population based on its fitness values
% do not change the current populatio population. Work on cpop/cpopfits
cpop = pop(IX,:);
cpopfits = fpop(IX);
cpopVio = Vio(IX);
%get seeds
seeds = [];
seedsidx = [];

for i=1:NP
	found=0;
	[sNP,sD] = size(seeds);
	for j=1:sNP
		% Calculate distance from seeds
		dist = sqrt( sum( (seeds(j,:)-cpop(i,:)).^2,2) );
		% If the Euclidean distance is less than the radius
		if (dist < problem.radius-1e-10)
			found = 1;
			break;
		end
	end
	% If it is not similar to any other seed, then it is a new seed
	if (found == 0)
		seeds = [seeds;cpop(i,:)];
		seedsidx = [seedsidx; i];
	end
end

% Based on the accuracy: check which seeds are global optimizers
count = 0; finalseeds = [];
seedsfit = cpopfits(seedsidx);
seedsVio = cpopVio(seedsidx);
[ idx ] = find(seedsfit - get_fgoptima(problem.func_num)<=accuracy & seedsVio == 0);
if (length(idx) > no_goptima )
	idx = idx(1:no_goptima);
end
count = length(idx);
finalseeds = seeds(idx,:);
