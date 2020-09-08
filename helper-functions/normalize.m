% For each pair of matrices, normalize data using the z-score
% transformation based on the final time-point of control data

function [normalized_control_data, normalized_patient_data] = normalize(...
    control_data, patient_data, final_day)

% Extract the final time-point data from controls
fdf = control_data(:, :, final_day);

% Calculate the mean and standard deviation of the final time-point for
% each feature
fdf_mean = nanmean(fdf);
fdf_std = nanstd(fdf);

% Compute z-scores for all data
normalized_control_data = (control_data(:, :, 1:final_day) - fdf_mean) ./ fdf_std;
normalized_patient_data = (patient_data(:, :, 1:final_day) - fdf_mean) ./ fdf_std;

end