clear all
%% Clear suffix
% List of 3-digit elements to look for in variable names
suffixes = {'468', '477', '484'};

% Get the list of variables in the workspace
workspaceVars = who;

% Loop through each variable in the workspace
for k = 1:length(workspaceVars)
    varName = workspaceVars{k};
    
    % Check if variable name contains any of the specified elements
    shouldClear = false;
    for i = 1:length(suffixes)
        if contains(varName, suffixes{i})
            shouldClear = true;
            break;
        end
    end
    
    % If the variable name contains one of the specified elements, clear the variable
    if shouldClear
        clear(varName);
        fprintf('Variable %s has been cleared from the workspace.\n', varName);
    end
end

% Clear temporary variables
clear workspaceVars varName shouldClear k i suffixes;


%% Load files with certain suffixes
% Specify the directory containing the .mat files
folderPath = 'C:\Users\trb938\OneDrive - University of Copenhagen\MATLAB\saved_data\RR_intervals';

% List of 3-digit elements to look for in file names
suffixes = {'588'};
%'115', '122', '124', '201', '205', '207', '209', '203', '420',

% Get a list of all files in the folder and subfolders with the .mat extension
matFiles = dir(fullfile(folderPath, '**', '*.mat'));  % '**' enables recursive search in subfolders

% Loop through each file
for k = 1:length(matFiles)
    fileName = matFiles(k).name;
    
    % Check if file name contains any of the specified elements
    shouldLoad = false;
    for i = 1:length(suffixes)
        if contains(fileName, suffixes{i})
            shouldLoad = true;
            break;
        end
    end
    
    % If the file name contains one of the specified elements, load the file
    if shouldLoad
        filePath = fullfile(matFiles(k).folder, matFiles(k).name);
        data = load(filePath);
        
        % Assuming each .mat file contains only one variable and can be converted to a double
        varNames = fieldnames(data);  % Get the name of the variable in the .mat file
        if length(varNames) == 1  % Check if there's exactly one variable in the file
            varData = data.(varNames{1});  % Extract that variable
            
            % Check if the data can be converted to a double
            if isnumeric(varData) || islogical(varData)
                varData = double(varData);  % Convert to double if not already
                % Store it in a variable dynamically named according to the file without the loop index
                eval([varNames{1}, ' = varData;']);  % Remove num2str(k) to prevent indexing by load order
            else
                warning('%s contains data that cannot be converted to double.', matFiles(k).name);
            end
        else
            warning('%s does not contain exactly one variable.', matFiles(k).name);
        end
    end
end

clear matFiles filePath folderPath varNames varData data k shouldLoad i suffixes fileName



%% Load all
% Specify the directory containing the .mat files
folderPath = 'C:\Users\trb938\OneDrive - University of Copenhagen\MATLAB\saved_data';

% Get a list of all files in the folder and subfolders with the .mat extension
matFiles = dir(fullfile(folderPath, '**', '*.mat'));  % '**' enables recursive search in subfolders

% Loop through each file and load it
for k = 1:length(matFiles)
    filePath = fullfile(matFiles(k).folder, matFiles(k).name);
    data = load(filePath);
    
    % Assuming each .mat file contains only one variable and can be converted to a double
    varNames = fieldnames(data);  % Get the name of the variable in the .mat file
    if length(varNames) == 1  % Check if there's exactly one variable in the file
        varData = data.(varNames{1});  % Extract that variable
        
        % Check if the data can be converted to a double
        if isnumeric(varData) || islogical(varData)
            varData = double(varData);  % Convert to double if not already
            % Store it in a variable dynamically named according to the file without the loop index
            eval([varNames{1}, ' = varData;']);  % Remove num2str(k) to prevent indexing by load order
        else
            warning('%s contains data that cannot be converted to double.', matFiles(k).name);
        end
    else
        warning('%s does not contain exactly one variable.', matFiles(k).name);
    end
end
clear matFiles filePath folderPath varNames varData data k
%% 
% Specify the directory containing the .mat files
folderPath = 'C:\Users\trb938\OneDrive - University of Copenhagen\MATLAB\potential_data';

% Get a list of all files in the folder and subfolders with the .mat extension
matFiles = dir(fullfile(folderPath, '**', '*.mat'));  % '**' enables recursive search in subfolders

% Loop through each file and load it
for k = 1:length(matFiles)
    filePath = fullfile(matFiles(k).folder, matFiles(k).name);
    data = load(filePath);
    
    % Assuming each .mat file contains only one variable and can be converted to a double
    varNames = fieldnames(data);  % Get the name of the variable in the .mat file
    if length(varNames) == 1  % Check if there's exactly one variable in the file
        varData = data.(varNames{1});  % Extract that variable
        
        % Check if the data can be converted to a double
        if isnumeric(varData) || islogical(varData)
            varData = double(varData);  % Convert to double if not already
            % Store it in a variable dynamically named according to the file without the loop index
            eval([varNames{1}, ' = varData;']);  % Remove num2str(k) to prevent indexing by load order
        else
            warning('%s contains data that cannot be converted to double.', matFiles(k).name);
        end
    else
        warning('%s does not contain exactly one variable.', matFiles(k).name);
    end
end
clear matFiles filePath folderPath varNames varData data k
%% 


% Specify the directory containing the .mat files
folderPath = 'C:\Users\trb938\OneDrive - University of Copenhagen\MATLAB\saved_data\Traces';

% Get a list of all files in the folder with the .mat extension
matFiles = dir(fullfile(folderPath, '*.mat'));

% Loop through each file and load it
for k = 1:length(matFiles)
    filePath = fullfile(folderPath, matFiles(k).name);
    data = load(filePath);
    
    % Assuming each .mat file contains only one variable and can be converted to a double
    varNames = fieldnames(data);  % Get the name of the variable in the .mat file
    if length(varNames) == 1  % Check if there's exactly one variable in the file
        varData = data.(varNames{1});  % Extract that variable
        
        % Check if the data can be converted to a double
        if isnumeric(varData) || islogical(varData)
            varData = double(varData);  % Convert to double if not already
            % Store it in a variable dynamically named according to the file without the loop index
            eval([varNames{1}, ' = varData;']);  % Remove num2str(k) to prevent indexing by load order
        else
            warning('%s contains data that cannot be converted to double.', matFiles(k).name);
        end
    else
        warning('%s does not contain exactly one variable.', matFiles(k).name);
    end
end

% Specify the directory containing the .mat files
folderPath = 'C:\Users\trb938\OneDrive - University of Copenhagen\MATLAB\saved_data\Troughs';

% Get a list of all files in the folder with the .mat extension
matFiles = dir(fullfile(folderPath, '*.mat'));

% Loop through each file and load it
for k = 1:length(matFiles)
    filePath = fullfile(folderPath, matFiles(k).name);
    data = load(filePath);
    
    % Assuming each .mat file contains only one variable and can be converted to a double
    varNames = fieldnames(data);  % Get the name of the variable in the .mat file
    if length(varNames) == 1  % Check if there's exactly one variable in the file
        varData = data.(varNames{1});  % Extract that variable
        
        % Check if the data can be converted to a double
        if isnumeric(varData) || islogical(varData)
            varData = double(varData);  % Convert to double if not already
            % Store it in a variable dynamically named according to the file without the loop index
            eval([varNames{1}, ' = varData;']);  % Remove num2str(k) to prevent indexing by load order
        else
            warning('%s contains data that cannot be converted to double.', matFiles(k).name);
        end
    else
        warning('%s does not contain exactly one variable.', matFiles(k).name);
    end
end

% Specify the directory containing the .mat files
folderPath = 'C:\Users\trb938\OneDrive - University of Copenhagen\MATLAB\saved_data\RR_intervals';

% Get a list of all files in the folder with the .mat extension
matFiles = dir(fullfile(folderPath, '*.mat'));

% Loop through each file and load it
for k = 1:length(matFiles)
    filePath = fullfile(folderPath, matFiles(k).name);
    data = load(filePath);
    
    % Assuming each .mat file contains only one variable and can be converted to a double
    varNames = fieldnames(data);  % Get the name of the variable in the .mat file
    if length(varNames) == 1  % Check if there's exactly one variable in the file
        varData = data.(varNames{1});  % Extract that variable
        
        % Check if the data can be converted to a double
        if isnumeric(varData) || islogical(varData)
            varData = double(varData);  % Convert to double if not already
            % Store it in a variable dynamically named according to the file without the loop index
            eval([varNames{1}, ' = varData;']);  % Remove num2str(k) to prevent indexing by load order
        else
            warning('%s contains data that cannot be converted to double.', matFiles(k).name);
        end
    else
        warning('%s does not contain exactly one variable.', matFiles(k).name);
    end
end

% Specify the directory containing the .mat files
folderPath = 'C:\Users\trb938\OneDrive - University of Copenhagen\MATLAB\saved_data\Sleep';

% Get a list of all files in the folder with the .mat extension
matFiles = dir(fullfile(folderPath, '*.mat'));

% Loop through each file and load it
for k = 1:length(matFiles)
    filePath = fullfile(folderPath, matFiles(k).name);
    data = load(filePath);
    
    % Assuming each .mat file contains only one variable and can be converted to a double
    varNames = fieldnames(data);  % Get the name of the variable in the .mat file
    if length(varNames) == 1  % Check if there's exactly one variable in the file
        varData = data.(varNames{1});  % Extract that variable
        
        % Check if the data can be converted to a double
        if isnumeric(varData) || islogical(varData)
            varData = double(varData);  % Convert to double if not already
            % Store it in a variable dynamically named according to the file without the loop index
            eval([varNames{1}, ' = varData;']);  % Remove num2str(k) to prevent indexing by load order
        else
            warning('%s contains data that cannot be converted to double.', matFiles(k).name);
        end
    else
        warning('%s does not contain exactly one variable.', matFiles(k).name);
    end
end
clear matFiles filePath folderPath varNames varData data