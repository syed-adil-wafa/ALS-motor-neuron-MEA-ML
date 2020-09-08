function timeplot(df1, df2, colors, feature, feature_label, df1_label, df2_label)

% Extract time
time = 1:size(df1, 3);

% Impute NaN values as 0
df1(isnan(df1)) = 0;
df2(isnan(df2)) = 0;

% Limit data to required feature and reshape the vector
df1 = reshape(df1(:, feature, :), [size(df1, 1), size(df1, 3)]);
df2 = reshape(df2(:, feature, :), [size(df2, 1), size(df2, 3)]);

% Calculate the mean, mean + SEM (upper limit), mean - SEM (lower limit)
% for each matrix
df1_mean = nanmean(df1);
df1_lower_limit = df1_mean - (nanstd(df1) ./ sqrt(size(df1, 1) - 1));
df1_upper_limit = df1_mean + (nanstd(df1) ./ sqrt(size(df1, 1) - 1));

df2_mean = nanmean(df2);
df2_lower_limit = df2_mean - (nanstd(df2) ./ sqrt(size(df2, 1) - 1));
df2_upper_limit = df2_mean + (nanstd(df2) ./ sqrt(size(df2, 1) - 1));

% Define colors for plotting
blue = [0, 0.45, 0.74]; % Face alpha = 0.65
lblue = [0.73, 0.83, 0.96];
orange = [0.85, 0.33, 0.1]; % Face alpha = 0.65
lorange = [0.95, 0.87, 0.73];
purple = [0.49, 0.18, 0.56]; % Face alpha = 0.35
lpurple = [210/255, 131/255, 248/255];
green = [0, 0.5, 0]; % Face alpha = 0.325
lgreen = [119/255, 255/255, 75/255];

% Limit colors and face alpha
if colors == 1
    cols = [blue; lblue; orange; lorange];
    facealpha = [0.65, 0.65];
else
    cols = [purple; lpurple; green; lgreen];
    facealpha = [0.35, 0.325];
end

% Define figure configurations
hold on; box off
set(gca, 'TickDir', 'out');
xlim([1 time(:, end)]); % x-axis limits
set(gca, 'XTick', 1:5:time(:, end)); % x-axis ticks
xlabel('Time (days after re-plating)'); % x-label
ylabel(feature_label); % y-label

% Plot upper and lower limits for df1 and fill the region in between
plot(time, df1_lower_limit, 'color', cols(2, :)); 
plot(time, df1_upper_limit, 'color', cols(2, :));
fill([time, fliplr(time)],[df1_lower_limit, fliplr(df1_upper_limit)],...
    cols(2, :), 'edgecolor', cols(2, :), 'Facealpha', facealpha(:, 1));

% Plot upper and lower limits for df2 and fill the region in between
plot(time, df2_lower_limit, 'color', cols(4, :));
plot(time, df2_upper_limit, 'color', cols(4, :));
fill([time, fliplr(time)],[df2_lower_limit, fliplr(df2_upper_limit)],...
    cols(4, :), 'edgecolor', cols(4, :), 'Facealpha', facealpha(:, 2));

% Plot the mean of df1 and df2
fig1 = plot(time, df1_mean, 'color', cols(1, :), 'LineWidth', 1.5);
fig2 = plot(time, df2_mean, 'color', cols(3, :), 'LineWidth', 1.5);

% Legend configurations
legend([fig1, fig2], [df1_label], [df2_label], 'location', 'northwest');

end