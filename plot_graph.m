Func = @niching_func_cons;
Dims = [1,2,2,5,5,5,10,10,10,1,2,2,1,1,2,2,3,5];
Sample_Rate = 1000;
addpath(genpath("benchmark"));

problem_num = 11;
problem_dim = Dims(problem_num);
[lower_bound, upper_bound] = niching_func_bound_cons(problem_num, problem_dim);
lower_bound = lower_bound(1);
upper_bound = upper_bound(1);
interval_length = upper_bound - lower_bound;
total_sample_num = interval_length * 100;
sample_axis = zeros(problem_dim, total_sample_num);
for i = 1:problem_dim; sample_axis(i, :) = linspace(lower_bound, upper_bound, interval_length * 100); end
% [sample_x, sample_y] = meshgrid(sample_axis(1, :), sample_axis(2, :));
[f, g, h] = Func([sample_x(:), sample_y(:)], problem_num);
plot3(sample_x(:), sample_y(:), f);
% f = reshape(f, size(sample_x));
% leagal = reshape(sum(g, 2) == 0, size(sample_x));
% f(leagal) = NaN;
% contour(sample_x, sample_y, f, 'ShowText', 'on');


% for index = 1:size(g, 2)
%     constrain = reshape(g(:, index), size(sample_x));
%     【(sample_x, sample_y, constrain);
% end
% set(sur, 'LineStyle', 'none');
% set(sur2, 'LineStyle', 'none');
% sample_x = linspace(lower_bound, upper_bound, interval_length * 100);
% sample_x = sample_x';
% [computed_y, g, h] = Func(sample_x, problem_num);
% hold all;
% plot(sample_x, computed_y);
% plot(sample_x, g);
