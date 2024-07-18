function [AUC_table, PeakFrequency_table] = process_group_NE_AUC(group, max_hz)
    sampling_hz = 0.0002;
    dataDirectory = 'C:\Users\trb938\OneDrive - University of Copenhagen\MATLAB\chr2_yfp\Figure_4_data';
    fsDirectory = 'C:\Users\trb938\OneDrive - University of Copenhagen\MATLAB\chr2_yfp\Traces';

    % Initialize empty cell arrays to store the results
    AUC_results = {};
    PeakFrequency_results = {};

    for s = 1:length(group)
        suffix = group{s};

        % Load sampling frequency
        variable_name_fs = sprintf('signal_fs_%s', suffix);
        if evalin('base', ['exist(''', variable_name_fs, ''', ''var'')'])
            fs = evalin('base', variable_name_fs);
        else
            filename_NE = fullfile(fsDirectory, sprintf('%s.mat', variable_name_fs));
            if exist(filename_NE, 'file')
                fs = load(filename_NE);
                fs = fs.(variable_name_fs);
            else
                disp(['File not found: ', filename_NE]);
                continue;
            end
        end

        % Loop through each laser level
        for laser_level = 1:5
            variable_name = sprintf('NE_laser_%d_NREM_%s', laser_level, suffix);
            if evalin('base', ['exist(''', variable_name, ''', ''var'')'])
                NE_values = evalin('base', variable_name);
            else
                filename = fullfile(dataDirectory, sprintf('%s.mat', variable_name));
                if exist(filename, 'file')
                    NE_values = load(filename);
                    NE_values = NE_values.(variable_name);
                else
                    disp(['File not found: ', filename]);
                    continue;
                end
            end

            % Loop through each bout
            for i = 1:size(NE_values, 1)
                bout_data = NE_values(i, :);

                % Detrend (and center around 0)
                [p, s, mu] = polyfit((1:numel(bout_data))', bout_data, 5);
                f_y = polyval(p, (1:numel(bout_data))', [], mu);
                detrend_data = bout_data - f_y'; % Detrend data

                [pxx, f] = pwelch(detrend_data, [], [], [0:sampling_hz:max_hz], fs); % Calculate PSD
                AUC = trapz(f, pxx); % Calculate area under the curve
                
                % Find the frequency with the maximum power
                [~, maxIdx] = max(pxx);
                peak_frequency = f(maxIdx);
                
                % Store the AUC value, peak frequency, suffix, and laser level in the results cell arrays
                AUC_results{end+1, 1} = AUC;
                AUC_results{end, 2} = suffix;
                AUC_results{end, 3} = laser_level;

                PeakFrequency_results{end+1, 1} = peak_frequency;
                PeakFrequency_results{end, 2} = suffix;
                PeakFrequency_results{end, 3} = laser_level;
            end
        end
    end

    % Convert the results cell arrays to tables
    AUC_table = cell2table(AUC_results, 'VariableNames', {'AUC', 'Suffix', 'LaserLevel'});
    PeakFrequency_table = cell2table(PeakFrequency_results, 'VariableNames', {'PeakFrequency', 'Suffix', 'LaserLevel'});
end
