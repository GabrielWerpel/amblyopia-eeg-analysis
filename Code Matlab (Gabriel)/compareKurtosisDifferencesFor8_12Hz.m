function compareKurtosisDifferencesFor8_12Hz(kurtosisResults)
    % Initialize arrays to store the differences for Amblyopia and Control groups
    diff_EO_EC_8_12_A = [];
    diff_EO_DEC_8_12_A = [];
    diff_EO_NDEC_8_12_A = [];
    
    diff_EO_EC_8_12_C = [];
    diff_EO_DEC_8_12_C = [];
    diff_EO_NDEC_8_12_C = [];

    % Iterate over each key and collect the differences
    keys = fieldnames(kurtosisResults);
    for i = 1:numel(keys)
        key = keys{i};
        group = kurtosisResults.(key).group;
        kurtosis_8_12 = kurtosisResults.(key).kurtosis_8_12;

        diff_EO_EC_8_12 = kurtosis_8_12.EO - kurtosis_8_12.EC;
        diff_EO_DEC_8_12 = kurtosis_8_12.EO - kurtosis_8_12.DEC;
        diff_EO_NDEC_8_12 = kurtosis_8_12.EO - kurtosis_8_12.NDEC;

        if strcmp(group, 'Amblyopia')
            diff_EO_EC_8_12_A = [diff_EO_EC_8_12_A; diff_EO_EC_8_12];
            diff_EO_DEC_8_12_A = [diff_EO_DEC_8_12_A; diff_EO_DEC_8_12];
            diff_EO_NDEC_8_12_A = [diff_EO_NDEC_8_12_A; diff_EO_NDEC_8_12];
        elseif strcmp(group, 'Control')
            diff_EO_EC_8_12_C = [diff_EO_EC_8_12_C; diff_EO_EC_8_12];
            diff_EO_DEC_8_12_C = [diff_EO_DEC_8_12_C; diff_EO_DEC_8_12];
            diff_EO_NDEC_8_12_C = [diff_EO_NDEC_8_12_C; diff_EO_NDEC_8_12];
        end
    end

    % Perform statistical tests between conditions within each group for 8-12 Hz
    [h_EO_EC_vs_EO_DEC_A, p_EO_EC_vs_EO_DEC_A] = ttest(diff_EO_EC_8_12_A, diff_EO_DEC_8_12_A);
    [h_EO_EC_vs_EO_NDEC_A, p_EO_EC_vs_EO_NDEC_A] = ttest(diff_EO_EC_8_12_A, diff_EO_NDEC_8_12_A);
    [h_EO_DEC_vs_EO_NDEC_A, p_EO_DEC_vs_EO_NDEC_A] = ttest(diff_EO_DEC_8_12_A, diff_EO_NDEC_8_12_A);

    [h_EO_EC_vs_EO_DEC_C, p_EO_EC_vs_EO_DEC_C] = ttest(diff_EO_EC_8_12_C, diff_EO_DEC_8_12_C);
    [h_EO_EC_vs_EO_NDEC_C, p_EO_EC_vs_EO_NDEC_C] = ttest(diff_EO_EC_8_12_C, diff_EO_NDEC_8_12_C);
    [h_EO_DEC_vs_EO_NDEC_C, p_EO_DEC_vs_EO_NDEC_C] = ttest(diff_EO_DEC_8_12_C, diff_EO_NDEC_8_12_C);

    % Perform statistical tests between groups for each condition for 8-12 Hz
    [h_diff_EO_EC, p_diff_EO_EC] = ttest2(diff_EO_EC_8_12_A, diff_EO_EC_8_12_C);
    [h_diff_EO_DEC, p_diff_EO_DEC] = ttest2(diff_EO_DEC_8_12_A, diff_EO_DEC_8_12_C);
    [h_diff_EO_NDEC, p_diff_EO_NDEC] = ttest2(diff_EO_NDEC_8_12_A, diff_EO_NDEC_8_12_C);

    % Display the results of statistical tests between conditions within each group for 8-12 Hz
    fprintf('Comparison of Differences Within Each Group (Amblyopia, 8-12 Hz):\n');
    fprintf('EO - EC vs EO - DEC: p-value = %.4f, Significant = %d\n', p_EO_EC_vs_EO_DEC_A, h_EO_EC_vs_EO_DEC_A);
    fprintf('EO - EC vs EO - NDEC: p-value = %.4f, Significant = %d\n', p_EO_EC_vs_EO_NDEC_A, h_EO_EC_vs_EO_NDEC_A);
    fprintf('EO - DEC vs EO - NDEC: p-value = %.4f, Significant = %d\n', p_EO_DEC_vs_EO_NDEC_A, h_EO_DEC_vs_EO_NDEC_A);

    fprintf('Comparison of Differences Within Each Group (Control, 8-12 Hz):\n');
    fprintf('EO - EC vs EO - DEC: p-value = %.4f, Significant = %d\n', p_EO_EC_vs_EO_DEC_C, h_EO_EC_vs_EO_DEC_C);
    fprintf('EO - EC vs EO - NDEC: p-value = %.4f, Significant = %d\n', p_EO_EC_vs_EO_NDEC_C, h_EO_EC_vs_EO_NDEC_C);
    fprintf('EO - DEC vs EO - NDEC: p-value = %.4f, Significant = %d\n', p_EO_DEC_vs_EO_NDEC_C, h_EO_DEC_vs_EO_NDEC_C);

    % Display the results of statistical tests between groups for each condition for 8-12 Hz
    fprintf('Comparison of Differences Between Groups (8-12 Hz):\n');
    fprintf('EO - EC: p-value = %.4f, Significant = %d\n', p_diff_EO_EC, h_diff_EO_EC);
    fprintf('EO - DEC: p-value = %.4f, Significant = %d\n', p_diff_EO_DEC, h_diff_EO_DEC);
    fprintf('EO - NDEC: p-value = %.4f, Significant = %d\n', p_diff_EO_NDEC, h_diff_EO_NDEC);

    % Prepare data for box plot
    includedSections = {'EO-EC', 'EO-DEC', 'EO-NDEC'};
    groupLabels_A = repmat({'Amblyopia'}, numel(diff_EO_EC_8_12_A), 1);
    groupLabels_C = repmat({'Control'}, numel(diff_EO_EC_8_12_C), 1);

    dataA = [repmat({'EO-EC'}, size(diff_EO_EC_8_12_A)); repmat({'EO-DEC'}, size(diff_EO_DEC_8_12_A)); repmat({'EO-NDEC'}, size(diff_EO_NDEC_8_12_A))];
    dataC = [repmat({'EO-EC'}, size(diff_EO_EC_8_12_C)); repmat({'EO-DEC'}, size(diff_EO_DEC_8_12_C)); repmat({'EO-NDEC'}, size(diff_EO_NDEC_8_12_C))];

    combinedData = table([dataA; dataC], ...
                         [diff_EO_EC_8_12_A; diff_EO_DEC_8_12_A; diff_EO_NDEC_8_12_A; diff_EO_EC_8_12_C; diff_EO_DEC_8_12_C; diff_EO_NDEC_8_12_C], ...
                         [groupLabels_A; groupLabels_A; groupLabels_A; groupLabels_C; groupLabels_C; groupLabels_C], ...
                         'VariableNames', {'Section', 'Difference', 'Group'});

    % Convert to categorical for ordering
    combinedData.Section = categorical(combinedData.Section, includedSections);
    combinedData.Group = categorical(combinedData.Group);

    % Determine common y-axis limits for the plot
    all_differences = [diff_EO_EC_8_12_A; diff_EO_DEC_8_12_A; diff_EO_NDEC_8_12_A; ...
                       diff_EO_EC_8_12_C; diff_EO_DEC_8_12_C; diff_EO_NDEC_8_12_C];
    common_ylim = [min(all_differences), max(all_differences)];

    % Box plot
    figure;
    boxchart(combinedData.Section, combinedData.Difference, 'GroupByColor', combinedData.Group);
    hold on;

    % Enhance the plot
    ylabel('Difference in Kurtosis');
    xlabel('Section');
    legend('Amblyopia', 'Control', 'Location', 'southeast');  % Updated legend location
    title('Comparison of Kurtosis Differences for Amblyopia and Control (8-12 Hz)');
    grid on;
    ylim(common_ylim);
end
