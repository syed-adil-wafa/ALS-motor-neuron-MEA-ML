% For each time-point, build an ensemble model of weak learners (Breiman's
% random forest algorithm) and quantify feature weights in predicting
% different classes

function [oob_timeseries, oob_labels] = rf_feature_importance(...
    normalized_data, target_class, feature_labels)

% Prepare feature labels by removing spaces and non-alphabetic characters
processed_feature_labels = regexprep(...
    feature_labels, '\s+', ''); % remove spaces
processed_feature_labels = regexprep(...
    processed_feature_labels, '[()-]', ''); % remove other characters

% Set the first label as 'condition', which is the classification target
processed_feature_labels = ...
    ['condition'; processed_feature_labels];

for time = 1:size(normalized_data, 3)
    
    % Set the first column of feature vectors as the class target
    classification_table = array2table(...
        [target_class, normalized_data(:, :, time)]);
    
    % Define the table variable names as the feature vector labels
    classification_table.Properties.VariableNames = processed_feature_labels;
    
    % Build an ensemble model of weak learners
    learners = templateTree(...
        'NumPredictorsToSample', 'all',...
        'PredictorSelection', 'allsplits',...
        'Surrogate', 'on');
    % Set 'NumPredictorsToSample' to 'all' to avoid Breiman's random forest
    % algorithm

    model = fitcensemble(...
        classification_table,...
        'condition',...
        'Method', 'bag',... % set method to bag to invoke Breiman's random forest
        'NumLearningCycles', 100,...
        'Learners', learners,...
        'Type', 'classification'...
        );
    
    % Calculate the out-of-bag feature importance
    oob_feature_importance = predictorImportance(model);
    
    % Get the time-series of out-of-bag feature importance
    oob_timeseries(:, time) = ...
        oob_feature_importance' ./ max(abs(oob_feature_importance'));
    
end

% Set NaN values to 0
oob_timeseries(isnan(oob_timeseries)) = 0;

% Cluster the features via hierarchical clustering
tree = linkage(oob_timeseries, 'ward');
distance = pdist(oob_timeseries, 'euclidean');
leafOrder = optimalleaforder(tree, distance);
oob_timeseries = oob_timeseries(leafOrder', :);
oob_labels = feature_labels(leafOrder', :);

end