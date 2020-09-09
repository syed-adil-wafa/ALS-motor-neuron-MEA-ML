%% Multivariate electrophysiological phenotyping of human iPSC-derived motor neurons in ALS using ensemble machine learning

close all % close all figures
clear % clear workspace
clc % clear command window
rng(1); % seed random number generator for reproducibility

%% Multi-electrode array configuration

% Define the # of wells in multi-electrode array plate
mea_config.number_of_wells = 96;

% Define the # of patient-derived cell lines
mea_config.number_of_patient_lines = 2; % 39b and RB9d

% Define the # of genotypes per patient-derived cell line
mea_config.number_of_genotypes_per_line = 2; % 39b and 39b-corrected, RB9d and RB9d-corrected

% Caculate total # of experimental conditions
mea_config.number_of_conditions = ...
    mea_config.number_of_patient_lines * mea_config.number_of_genotypes_per_line;

% Define the electrophysiological feature start and end rows in data files
mea_config.start_row = 30;
mea_config.end_row = 83;

% Filter out wells with 0 active electrodes
% 0: select all wells, 1: select wells with 1 or more active electrodes
mea_config.active_elecs_filter = 0;

%% Plating information

% Change directory to enable helper functions
cd helper-functions

% Define wells for each experimental condition
mea_config.plate = mea_plate(mea_config.number_of_wells);
mea_config.wells_39b = ...
    [mea_config.plate.D(1:4), mea_config.plate.E(1:4), mea_config.plate.F(1:4), mea_config.plate.G(1:4), mea_config.plate.H(1:4)]; % 39b
mea_config.wells_39b_corrected = ...
    [mea_config.plate.A(1:4), mea_config.plate.B(1:4), mea_config.plate.C(1:4)]; % 39b-corrected
mea_config.wells_RB9d = ...
    [mea_config.plate.A(5:8), mea_config.plate.B(5:8), mea_config.plate.C(5:8)]; % RB9d
mea_config.wells_RB9d_corrected = ...
    [mea_config.plate.D(5:8), mea_config.plate.E(5:8), mea_config.plate.F(5:8), mea_config.plate.G(5:8), mea_config.plate.H(5:8)]; % RB9d-corrected

% Define labels for each experimental condition
mea_config.labels_39b = '39b';
mea_config.labels_39b_corrected = '39b-corrected';
mea_config.labels_RB9d = 'RB9d';
mea_config.labels_RB9d_corrected = 'RB9d-corrected';

% Concatenate wells of all experimental conditions
processing.conditions = catpad(1,...
    mea_config.wells_39b,...
    mea_config.wells_39b_corrected,...
    mea_config.wells_RB9d,...
    mea_config.wells_RB9d_corrected);

% Concatenate labels of all experimental conditions
processing.labels = {...
    mea_config.labels_39b,...
    mea_config.labels_39b_corrected,...
    mea_config.labels_RB9d,...
    mea_config.labels_RB9d_corrected};

%% Data extraction

% Change directory to extract data
cd ../data

% Suppress warnings associated with data extraction
w = warning('on', 'all');
id = w.identifier;
warning('off', id);

% Retrieve all folders in the data folder
extraction.folders = dir;

% Extract data from each folder
extraction.foldernames = []; % initialize foldernames
for folder = 1:size(extraction.folders, 1)
    
    % Get the name of each individual folder and store them in a vector
    extraction.current_folder = extraction.folders(folder).name;
    extraction.foldernames_temp(:, folder) = cellstr(extraction.current_folder);
    
    % Change directory to each individual folder
    if contains(extraction.foldernames_temp(:, folder), '.') == 1
    else
        extraction.new_dir = char(append(pwd, '/', extraction.foldernames_temp(:, folder)));
        cd(extraction.new_dir);
        
        % Extract required foldernames
        extraction.foldernames = [extraction.foldernames; extraction.foldernames_temp(:, folder)];
        nfolder = size(extraction.foldernames, 1); % number of folders
        
        % Retrieve all .csv files in the current folder
        extraction.files = dir('*.csv');
        
        % Extract data from each file
        for file = 1:size(extraction.files, 1)
            
            % Get the name of each individual file and store them in a vector
            extraction.current_file = extraction.files(file).name;
            extraction.filenames(:, file) = cellstr(extraction.current_file);
            
            % Read data from each file
            extraction.file_data = readcell(...
                [pwd, (append('/', extraction.current_file))]);
            extraction.raw_data(:, :, file, nfolder) = cell2mat(table2cell(cell2table(...
                extraction.file_data(mea_config.start_row:mea_config.end_row,...
                2:mea_config.number_of_wells + 1))));
            
            % Get labels for each electrophysiological feature
            extraction.feature_labels = readcell(...
                [pwd, (append('/', extraction.current_file))]);
            extraction.feature_labels = extraction.feature_labels(...
                mea_config.start_row:mea_config.end_row, 1);
            
            % Extract time-points from filenames
            extraction.time(nfolder, file) = ...
                str2double(regexprep(extraction.filenames(:, file), '[D.csv]', ''));
            
        end
        
        % Sort time-points in ascending order
        [extraction.time(nfolder, :), extraction.timeorder_index(nfolder, :)] = sort(...
            extraction.time(nfolder, :), 'ascend');
        
        % Sort extracted data by time
        extraction.raw_data(:, :, :, nfolder) = ...
            extraction.raw_data(:, :, extraction.timeorder_index(nfolder, :), nfolder);
        
        % Revert back to data folder
        cd ..
        
    end
    
end

% Change directory to enable helper functions
cd ../helper-functions

%% Data processing

% Remove undesired features
undesired_features = [1 3 7 15 16 17 18 19 23 25 27 28 36 37 38 39 40 42 48 50 52];
extraction.raw_data(undesired_features, :, :, :) = [];
extraction.feature_labels(undesired_features) = [];

% Correct feature labels by replacing zeros with whitespace and removing
% leading and trailing whitespaces
extraction.feature_labels = strtrim(regexprep(extraction.feature_labels, '[0]', ' '));

% Process feature labels
extraction.feature_labels = strrep(extraction.feature_labels, 'Number', '#');

% Set the starting time-point as day 1
for time = 1:size(extraction.time, 1)
    if extraction.time(time, 1) ~= 1
        extraction.time_temp(time, 2:size(extraction.time, 2) + 1) = extraction.time(time, :);
        extraction.time_temp(time, 1) = 1;
    end
end
extraction.time = extraction.time_temp;

% Reshape data as well x feature x time x cell line
processing.raw_data = permute(extraction.raw_data, [2, 1, 3, 4]);

% Impute NaN values as 0
processing.raw_data(isnan(processing.raw_data)) = 0;

% Set day 1 values as 0
processing.processed_data(:, :, 2:size(processing.raw_data, 3) + 1, :) =...
    processing.raw_data;
processing.processed_data(:, :, 1, :) = 0;

% For each patient line, create evenly spaced matrices
for pline = 1:mea_config.number_of_patient_lines
    
    % Perform linear interpolation to create an evenly spaced time vector
    processing.time = 1:extraction.time(1, end);
    
    % Perform linear interpolation to create an evenly spaced data matrix
    for feature = 1:size(processing.processed_data, 2)
        
        for well = 1:size(processing.processed_data, 1)
            
            processing.interpolated_well = permute(interp1(...
                extraction.time(pline, :),...
                permute(processing.processed_data(well, feature, :, pline), [1, 3, 2]),...
                processing.time),...
                [1, 3, 2]);
            
            processing.df(well, feature, :, pline) = processing.interpolated_well;
            
        end
        
    end
    
end

%% Data normalization

% Perform feature standardization by transforming values to z-scores
for pline = 1:size(extraction.foldernames, 1)
    if contains(extraction.foldernames(pline, 1), '39b') == 1
        [processing.df_39b_corrected, processing.df_39b] = normalize(...
            processing.df(mea_config.wells_39b_corrected, :, :, pline),...
            processing.df(mea_config.wells_39b, :, :, pline),...
            31);
    else
        [processing.df_RB9d_corrected, processing.df_RB9d] = normalize(...
            processing.df(mea_config.wells_RB9d_corrected, :, :, pline),...
            processing.df(mea_config.wells_RB9d, :, :, pline),...
            31);
    end
end

%% Machine learning

% Concatenate normalized control and patient data
machine_learning.normalized_data = [...
    processing.df_39b;...
    processing.df_39b_corrected;...
    processing.df_RB9d;...
    processing.df_RB9d_corrected];

% Define classification targets
machine_learning.target_class = target_class(...
    processing.conditions(1:2, :), mea_config.number_of_patient_lines);

% For each time-point, build a random forest model and quantify feature importance
[machine_learning.feature_importance, machine_learning.feature_labels] =...
    rf_feature_importance(...
    machine_learning.normalized_data,...
    [machine_learning.target_class; machine_learning.target_class],...
    extraction.feature_labels);

% Plot heatmap of feature importance
figure('units', 'normalized', 'outerposition', [0 0 0.75 0.75]);
imagesc(machine_learning.feature_importance); % plot heatmap
colormap('Jet'); % set the colormap to go from blue to red
caxis([0 1]); % set the range for the colorbar
plots.cbar = colorbar('location', 'EastOutside'); % define the colorbar position
set(get(plots.cbar, 'ylabel'), 'String', 'Relative feature importance');
title('Feature importance in classifying patient and control neurons'); % figure title

% Set the X- and y-axis ticks and labels
xlabel('Time (days after re-plating)');
set(gca, 'XTick', 1:3:size(machine_learning.feature_importance, 2));
set(gca, 'YTick', 1:size(machine_learning.feature_importance, 1));
set(gca, 'YTickLabel', machine_learning.feature_labels);

%% Data visualization

%% Plot figures for 39b and 39b-corrected
figure; hold on
suptitle('Comparison of electrophysiological features of 39b and 39b-corrected');

% Plot # of spikes
subplot(2, 4, 1);
timeplot(processing.df_39b, processing.df_39b_corrected, 1,...
    1, '# of spikes (z-score)',...
    append('39b (n=', num2str(size(processing.df_39b, 1)), ')'),...
    append('39b-corrected (n=', num2str(size(processing.df_39b_corrected, 1)), ')'));

% Plot weighted mean firing rate
subplot(2, 4, 2);
timeplot(processing.df_39b, processing.df_39b_corrected, 1,...
    4, 'weighted mean firing rate (z-score)',...
    append('39b (n=', num2str(size(processing.df_39b, 1)), ')'),...
    append('39b-corrected (n=', num2str(size(processing.df_39b_corrected, 1)), ')'));

% Plot area under normalized cross-correlation
subplot(2, 4, 3);
timeplot(processing.df_39b, processing.df_39b_corrected, 1,...
    30, 'area under normalized cross-correlation (z-score)',...
    append('39b (n=', num2str(size(processing.df_39b, 1)), ')'),...
    append('39b-corrected (n=', num2str(size(processing.df_39b_corrected, 1)), ')'));

% Plot IBI coefficient of variation - avg
subplot(2, 4, 4);
timeplot(processing.df_39b, processing.df_39b_corrected, 1,...
    15, 'IBI coefficient of variation (z-score)',...
    append('39b (n=', num2str(size(processing.df_39b, 1)), ')'),...
    append('39b-corrected (n=', num2str(size(processing.df_39b_corrected, 1)), ')'));

% Plot # of electrodes participating in burst (average)
subplot(2, 4, 5);
timeplot(processing.df_39b, processing.df_39b_corrected, 1,...
    24, '# of elecs participating in burst (z-score)',...
    append('39b (n=', num2str(size(processing.df_39b, 1)), ')'),...
    append('39b-corrected (n=', num2str(size(processing.df_39b_corrected, 1)), ')'));

% Plot burst duration (std)
subplot(2, 4, 6);
timeplot(processing.df_39b, processing.df_39b_corrected, 1,...
    8, 'burst duration (std) (z-score)',...
    append('39b (n=', num2str(size(processing.df_39b, 1)), ')'),...
    append('39b-corrected (n=', num2str(size(processing.df_39b_corrected, 1)), ')'));

% Plot network burst duration (std)
subplot(2, 4, 7);
timeplot(processing.df_39b, processing.df_39b_corrected, 1,...
    20, 'network burst duration (std) (z-score)',...
    append('39b (n=', num2str(size(processing.df_39b, 1)), ')'),...
    append('39b-corrected (n=', num2str(size(processing.df_39b_corrected, 1)), ')'));

% Plot # of spikes per network burst (std)
subplot(2, 4, 8);
timeplot(processing.df_39b, processing.df_39b_corrected, 1,...
    22, '# of spikes per network burst (std) (z-score)',...
    append('39b (n=', num2str(size(processing.df_39b, 1)), ')'),...
    append('39b-corrected (n=', num2str(size(processing.df_39b_corrected, 1)), ')'));

%% Plot figures for RB9d and RB9d-corrected
figure; hold on
suptitle('Comparison of electrophysiological features of RB9d and RB9d-corrected');

% Plot # of spikes
subplot(2, 4, 1);
timeplot(processing.df_RB9d, processing.df_RB9d_corrected, 2,...
    1, '# of spikes (z-score)',...
    append('RB9d (n=', num2str(size(processing.df_RB9d, 1)), ')'),...
    append('RB9d-corrected (n=', num2str(size(processing.df_RB9d_corrected, 1)), ')'));

% Plot weighted mean firing rate
subplot(2, 4, 2);
timeplot(processing.df_RB9d, processing.df_RB9d_corrected, 2,...
    4, 'weighted mean firing rate (z-score)',...
    append('RB9d (n=', num2str(size(processing.df_RB9d, 1)), ')'),...
    append('RB9d-corrected (n=', num2str(size(processing.df_RB9d_corrected, 1)), ')'));

% Plot area under normalized cross-correlation
subplot(2, 4, 3);
timeplot(processing.df_RB9d, processing.df_RB9d_corrected, 2,...
    30, 'area under normalized cross-correlation (z-score)',...
    append('RB9d (n=', num2str(size(processing.df_RB9d, 1)), ')'),...
    append('RB9d-corrected (n=', num2str(size(processing.df_RB9d_corrected, 1)), ')'));

% Plot IBI coefficient of variation - avg
subplot(2, 4, 4);
timeplot(processing.df_RB9d, processing.df_RB9d_corrected, 2,...
    15, 'IBI coefficient of variation (z-score)',...
    append('RB9d (n=', num2str(size(processing.df_RB9d, 1)), ')'),...
    append('RB9d-corrected (n=', num2str(size(processing.df_RB9d_corrected, 1)), ')'));

% Plot # of electrodes participating in burst (average)
subplot(2, 4, 5);
timeplot(processing.df_RB9d, processing.df_RB9d_corrected, 2,...
    24, '# of elecs participating in burst (z-score)',...
    append('RB9d (n=', num2str(size(processing.df_RB9d, 1)), ')'),...
    append('RB9d-corrected (n=', num2str(size(processing.df_RB9d_corrected, 1)), ')'));

% Plot burst duration (std)
subplot(2, 4, 6);
timeplot(processing.df_RB9d, processing.df_RB9d_corrected, 2,...
    8, 'burst duration (std) (z-score)',...
    append('RB9d (n=', num2str(size(processing.df_RB9d, 1)), ')'),...
    append('RB9d-corrected (n=', num2str(size(processing.df_RB9d_corrected, 1)), ')'));

% Plot network burst duration (std)
subplot(2, 4, 7);
timeplot(processing.df_RB9d, processing.df_RB9d_corrected, 2,...
    20, 'network burst duration (std) (z-score)',...
    append('RB9d (n=', num2str(size(processing.df_RB9d, 1)), ')'),...
    append('RB9d-corrected (n=', num2str(size(processing.df_RB9d_corrected, 1)), ')'));

% Plot # of spikes per network burst (std)
subplot(2, 4, 8);
timeplot(processing.df_RB9d, processing.df_RB9d_corrected, 2,...
    22, '# of spikes per network burst (std) (z-score)',...
    append('RB9d (n=', num2str(size(processing.df_RB9d, 1)), ')'),...
    append('RB9d-corrected (n=', num2str(size(processing.df_RB9d_corrected, 1)), ')'));

%% End of script

% Remove unneeded variables from workspace
remove_variables = {'feature',...
    'file',...
    'folder',...
    'id',...
    'nfolder',...
    'pline',...
    'time',...
    'undesired_features',...
    'well'};
clear(remove_variables{1, :})
clear 'remove_variables'