% Define classification targets for multi-electrode array wells

function [target_class] = target_class(conditions, number_of_conditions)

target_class = [];
for num = 1:number_of_conditions
    
    condition = conditions(num, :);
    condition_length = length(condition(~isnan(condition)));
    class(:, 1:condition_length) = num;
    target_class = [target_class; class'];
    
end