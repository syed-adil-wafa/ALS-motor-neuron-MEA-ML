%% Construct multi-electrode array plate template

% Depending on type of plate, define the # of rows and columns for template
% 12-well plates have 3 rows and 4 columns
% 48-well plates have 6 rows and 8 columns
% 96-well plates have 8 rows and 12 columns
function [mea_plate] = mea_plate(number_of_wells)

if number_of_wells == 12
    template.rows = 3;
    template.columns = 4;
elseif number_of_wells == 48
    template.rows = 6;
    template.columns = 8;
elseif number_of_wells == 96
    template.rows = 8;
    template.columns = 12;
end

% Construct the entire template plate
template.plate = 1:number_of_wells;
template.plate = (reshape...
    (template.plate, [template.columns, template.rows]))';

% Define letters for each template row for well selection by user
% 12-well plates have 3 rows labeled A to C
% 48-well plates have 6 rows labeled A to F
% 96-well plates have 8 tows labeled A to H
mea_plate.A = template.plate(1,:);
mea_plate.B = template.plate(2,:);
mea_plate.C = template.plate(3,:);

if number_of_wells == 48 || number_of_wells == 96
    mea_plate.D = template.plate(4,:);
    mea_plate.E = template.plate(5,:);
    mea_plate.F = template.plate(6,:);
end

if number_of_wells == 96
    mea_plate.G = template.plate(7,:);
    mea_plate.H = template.plate(8,:);
end

end