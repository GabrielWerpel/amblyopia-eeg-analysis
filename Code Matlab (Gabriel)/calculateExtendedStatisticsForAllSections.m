function extendedStatisticsResults = calculateExtendedStatisticsForAllSections(segmentedResults)
    % Initialize a structure to store the statistics
    extendedStatisticsResults = struct;

    % Get all keys in segmentedResults
    keys = fieldnames(segmentedResults);
    
    % Iterate over each key
    for i = 1:numel(keys)
        key = keys{i};
        
        % Get all sections for the current key
        sections = fieldnames(segmentedResults.(key));
        
        % Initialize a structure to store the statistics for each section
        extendedStatisticsResults.(key) = struct;
        
        % Iterate over each section
        for j = 1:numel(sections)
            section = sections{j};
            
            % Check if the section contains data (and not the header)
            if isnumeric(segmentedResults.(key).(section))
                % Extract the data
                data = segmentedResults.(key).(section);
                
                % Calculate statistics for normal data
                meanValue = round(mean(data), 3);
                stdValue = round(std(data), 3);
                varianceValue = round(var(data), 3);
                skewnessValue = round(skewness(data), 3);
                kurtosisValue = round(kurtosis(data), 3);

                % Store the statistics in the results structure
                extendedStatisticsResults.(key).(section) = struct('normal', struct('mean', meanValue, ...
                                                                                   'variance', varianceValue, ...
                                                                                   'std', stdValue, ...
                                                                                   'skewness', skewnessValue, ...
                                                                                   'kurtosis', kurtosisValue));
            end
        end

        % Calculate difference and ratio metrics between (EC, LC, RC) and EO.
        if isfield(segmentedResults.(key), 'EC') && isfield(segmentedResults.(key), 'EO') && isfield(segmentedResults.(key), 'DEC') && isfield(segmentedResults.(key), 'NDEC')
            EC = segmentedResults.(key).EC;
            DEC = segmentedResults.(key).DEC;
            NDEC = segmentedResults.(key).NDEC;
            EO = segmentedResults.(key).EO;
            
            % Calculate statistics for normal data
            meanValueEC = round(mean(EC), 3);
            stdValueEC = round(std(EC), 3);
            varianceValueEC = round(var(EC), 3);
            skewnessValueEC = round(skewness(EC), 3);
            kurtosisValueEC = round(kurtosis(EC), 3);
            meanValueEO = round(mean(EO), 3);
            stdValueEO = round(std(EO), 3);
            varianceValueEO = round(var(EO), 3);
            skewnessValueEO = round(skewness(EO), 3);
            kurtosisValueEO = round(kurtosis(EO), 3);
            meanValueDEC = round(mean(DEC), 3);
            stdValueDEC = round(std(DEC), 3);
            varianceValueDEC = round(var(DEC), 3);
            skewnessValueDEC = round(skewness(DEC), 3);
            kurtosisValueDEC = round(kurtosis(DEC), 3);
            meanValueNDEC = round(mean(NDEC), 3);
            stdValueNDEC = round(std(NDEC), 3);
            varianceValueNDEC = round(var(NDEC), 3);
            skewnessValueNDEC = round(skewness(NDEC), 3);
            kurtosisValueNDEC = round(kurtosis(NDEC), 3);
            
            
            % Difference metrics
            diff_mean_EC = round(meanValueEO - meanValueEC, 3);
            diff_std_EC = round(stdValueEO - stdValueEC, 3);
            diff_variance_EC = round(varianceValueEO - varianceValueEC, 3);
            diff_skewness_EC = round(skewnessValueEO - skewnessValueEC, 3);
            diff_kurtosis_EC = round(kurtosisValueEO - kurtosisValueEC, 3);

            % Difference metrics
            diff_mean_DEC = round(meanValueEO - meanValueDEC, 3);
            diff_std_DEC = round(stdValueEO - stdValueDEC, 3);
            diff_variance_DEC = round(varianceValueEO - varianceValueDEC, 3);
            diff_skewness_DEC = round(skewnessValueEO - skewnessValueDEC, 3);
            diff_kurtosis_DEC = round(kurtosisValueEO - kurtosisValueDEC, 3);

            % Difference metrics
            diff_mean_NDEC = round(meanValueEO - meanValueNDEC, 3);
            diff_std_NDEC = round(stdValueEO - stdValueNDEC, 3);
            diff_variance_NDEC = round(varianceValueEO - varianceValueNDEC, 3);
            diff_skewness_NDEC = round(skewnessValueEO - skewnessValueNDEC, 3);
            diff_kurtosis_NDEC = round(kurtosisValueEO - kurtosisValueNDEC, 3);

            % Store the difference metrics in the results structure
            extendedStatisticsResults.(key).Difference_EC_EO = struct('normal', struct('mean', diff_mean_EC, ...
                                                                                'std', diff_std_EC, ...
                                                                                'variance', diff_variance_EC, ...
                                                                                'skewness', diff_skewness_EC, ...
                                                                                'kurtosis', diff_kurtosis_EC));

            % Store the difference metrics in the results structure
            extendedStatisticsResults.(key).Difference_DEC_EO = struct('normal', struct('mean', diff_mean_DEC, ...
                                                                                'std', diff_std_DEC, ...
                                                                                'variance', diff_variance_DEC, ...
                                                                                'skewness', diff_skewness_DEC, ...
                                                                                'kurtosis', diff_kurtosis_DEC));
            
            % Store the difference metrics in the results structure
            extendedStatisticsResults.(key).Difference_NDEC_EO = struct('normal', struct('mean', diff_mean_NDEC, ...
                                                                                'std', diff_std_NDEC, ...
                                                                                'variance', diff_variance_NDEC, ...
                                                                                'skewness', diff_skewness_NDEC, ...
                                                                                'kurtosis', diff_kurtosis_NDEC));
            % Ratio metrics
            ratio_mean_EC = round(meanValueEC / meanValueEO, 3);
            ratio_std_EC = round(stdValueEC / stdValueEO, 3);
            ratio_variance_EC = round(varianceValueEC / varianceValueEO, 3);
            ratio_skewness_EC = round(skewnessValueEC / skewnessValueEO, 3);
            ratio_kurtosis_EC = round(kurtosisValueEC / kurtosisValueEO, 3);

            % Store the ratio metrics in the results structure
            extendedStatisticsResults.(key).Ratio_EC_EO = struct('normal', struct('mean', ratio_mean_EC, ...
                                                                           'std', ratio_std_EC, ...
                                                                           'variance', ratio_variance_EC, ...
                                                                           'skewness', ratio_skewness_EC, ...
                                                                           'kurtosis', ratio_kurtosis_EC));
            % Ratio metrics
            ratio_mean_DEC = round(meanValueDEC / meanValueEO, 3);
            ratio_std_DEC = round(stdValueDEC / stdValueEO, 3);
            ratio_variance_DEC = round(varianceValueDEC / varianceValueEO, 3);
            ratio_skewness_DEC = round(skewnessValueDEC / skewnessValueEO, 3);
            ratio_kurtosis_DEC = round(kurtosisValueDEC / kurtosisValueEO, 3);

            % Store the ratio metrics in the results structure
            extendedStatisticsResults.(key).Ratio_DEC_EO = struct('normal', struct('mean', ratio_mean_DEC, ...
                                                                           'std', ratio_std_DEC, ...
                                                                           'variance', ratio_variance_DEC, ...
                                                                           'skewness', ratio_skewness_DEC, ...
                                                                           'kurtosis', ratio_kurtosis_DEC));
            % Ratio metrics
            ratio_mean_NDEC = round(meanValueNDEC / meanValueEO, 3);
            ratio_std_NDEC = round(stdValueNDEC / stdValueEO, 3);
            ratio_variance_NDEC = round(varianceValueNDEC / varianceValueEO, 3);
            ratio_skewness_NDEC = round(skewnessValueNDEC / skewnessValueEO, 3);
            ratio_kurtosis_NDEC = round(kurtosisValueNDEC / kurtosisValueEO, 3);

            % Store the ratio metrics in the results structure
            extendedStatisticsResults.(key).Ratio_NDEC_EO = struct('normal', struct('mean', ratio_mean_NDEC, ...
                                                                           'std', ratio_std_NDEC, ...
                                                                           'variance', ratio_variance_NDEC, ...
                                                                           'skewness', ratio_skewness_NDEC, ...
                                                                           'kurtosis', ratio_kurtosis_NDEC));
        end
    end

    % Create a table to display the statistics
    statisticsTable = [];
    for i = 1:numel(keys)
        key = keys{i};
        sections = fieldnames(extendedStatisticsResults.(key));
        for j = 1:numel(sections)
            section = sections{j};
            normal_stats = extendedStatisticsResults.(key).(section).normal;
            row_normal = {key, section, 'Normal', normal_stats.mean, normal_stats.variance, normal_stats.std, normal_stats.skewness, normal_stats.kurtosis};
            statisticsTable = [statisticsTable; row_normal];%; row_standardized; row_normalized];
        end
    end

    % Convert the statistics table to a MATLAB table for display
    statisticsTable = cell2table(statisticsTable, ...
                                 'VariableNames', {'Key', 'Section', 'DataType', 'Mean', 'Variance', 'StandardDeviation', 'Skewness', 'Kurtosis'});

    % Display the table
    disp(statisticsTable);
    writetable(statisticsTable,"TableA.1.1.csv")
end