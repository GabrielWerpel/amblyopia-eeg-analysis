function compareMetricsByGroupsAndDataTypes(extendedStatisticsResults)
    % Initialize a structure to store comparison results
    comparisonResults = struct;

    % Get all keys from the extendedStatisticsResults
    keys = fieldnames(extendedStatisticsResults);

    % Separate A* and C* keys
    A_keys = {};
    C_keys = {};
    for i = 1:numel(keys)
        key = keys{i};
        if startsWith(key, 'A')
            A_keys{end+1} = key;
        elseif startsWith(key, 'C')
            C_keys{end+1} = key;
        end
    end

    % Initialize the table to store results
    comparisonTable = [];

    % Data types to compare
    dataTypes = {'normal'}; % Include only 'normal'

    % Metrics to compare
    metrics = {'mean', 'variance', 'std', 'skewness', 'kurtosis'};

    % Symbols for different metrics
    symbols = {'o', 's', 'd', '^', 'v'};

    % Iterate over all sections and compare each metric between A* and C* groups
    sections = {'EC', 'EO', 'DEC', 'NDEC', 'Difference_EC_EO','Difference_DEC_EO','Difference_NDEC_EO', 'Ratio_EC_EO','Ratio_DEC_EO','Ratio_NDEC_EO'};
    for i = 1:numel(sections)
        section = sections{i};
        
        for d = 1:numel(dataTypes)
            dataType = dataTypes{d};
            
            for m = 1:numel(metrics)
                metric = metrics{m};
                
                % Initialize variables to store aggregated data for A* and C*
                A_values = [];
                C_values = [];
                
                % Collect values for the metric from A* and C* groups
                for j = 1:numel(A_keys)
                    if isfield(extendedStatisticsResults.(A_keys{j}), section)
                        A_values = [A_values; extendedStatisticsResults.(A_keys{j}).(section).(dataType).(metric)];
                    end
                end
                for k = 1:numel(C_keys)
                    if isfield(extendedStatisticsResults.(C_keys{k}), section)
                        C_values = [C_values; extendedStatisticsResults.(C_keys{k}).(section).(dataType).(metric)];
                    end
                end
                
                % Ensure data is not empty
                if ~isempty(A_values) && ~isempty(C_values)
                    [h_A, p_A] = kstest(A_values);
                    [h_C, p_C] = kstest(C_values);
                    
                    if h_A == 0 && h_C == 0
                        if strcmp(metric, 'mean')
                            % Perform t-test for mean
                            [h, p_value, ci, stats] = ttest2(A_values, C_values);
                        elseif strcmp(metric, 'skewness') || strcmp(metric, 'kurtosis')
                            % Perform Mann-Whitney U test for skewness and kurtosis
                            p_value = ranksum(A_values, C_values);
                            h = p_value < 0.05;
                            ci = [];
                            stats = [];
                        elseif strcmp(metric, 'std') || strcmp(metric, 'variance')
                            % Perform Levene's test for standard deviation and variance
                            p_value = vartest2(A_values, C_values);
                            h = p_value < 0.05;
                            ci = [];
                            stats = [];
                        end
                    else
                        if strcmp(metric, 'mean') || strcmp(metric, 'std') || strcmp(metric, 'variance')
                            % Perform Mann-Whitney U test if data is not normally distributed
                            p_value = ranksum(A_values, C_values);
                            h = p_value < 0.05;
                            ci = [];
                            stats = [];
                        elseif strcmp(metric, 'skewness') || strcmp(metric, 'kurtosis')
                            % Perform Mann-Whitney U test for skewness and kurtosis
                            p_value = ranksum(A_values, C_values);
                            h = p_value < 0.05;
                            ci = [];
                            stats = [];
                        end
                    end

                    % Store the comparison results
                    comparisonResults.(section).(dataType).(metric) = struct('A_values', A_values, ...
                                                                            'C_values', C_values, ...
                                                                            'p_value', p_value, ...
                                                                            'h', h, ...
                                                                            'ci', ci, ...
                                                                            'stats', stats);
                    
                    % Add the results to the comparison table
                    row = {section, dataType, metric, mean(A_values), std(A_values), mean(C_values), std(C_values), p_value, h};
                    comparisonTable = [comparisonTable; row];
                end
            end
        end
    end

    % Convert the comparison table to a MATLAB table for display
    comparisonTable = cell2table(comparisonTable, ...
                                 'VariableNames', {'Section', 'DataType', 'Metric', 'A_Mean', 'A_StdDev', 'C_Mean', 'C_StdDev', 'P_Value', 'H'});

    % Sort the table by P_Value in ascending order
    comparisonTable = sortrows(comparisonTable, 'P_Value');

    % Display the comparison table
    disp(comparisonTable);
    writetable(comparisonTable, 'TableA.1.2.csv');

    % Update the section labels
    sectionLabels = {'EC', 'EO', 'DEC', 'NDEC', 'EC-EO','DEC-EO','NDEC-EO', 'EC/EO','DEC/EO','NDEC/EO'};

    % Plot the results
    figure('Position', [100, 100, 1200, 800]);
    hold on;
    colors = lines(numel(metrics)); % Generate a set of colors

    for i = 1:numel(metrics)
        metric = metrics{i};
        symbol = symbols{i};
        color = colors(i, :);
        data = comparisonTable(strcmp(comparisonTable.Metric, metric), :);
        scatter(categorical(data.Section), data.P_Value, 100, symbol, 'filled', 'MarkerFaceColor', color, 'DisplayName', sprintf('%s (normal)', metric));
    end
    
    % Update x-tick labels
    ax = gca;
    ax.XTickLabel = sectionLabels;

    ylabel('P-Value');
    title('Comparison of Metrics Between Amblyopes and Normal Groups');
    ylim([0 1]);
    legend('Location', 'bestoutside');
    hold off;
end