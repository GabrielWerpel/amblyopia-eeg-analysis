function compareKurtosisDifferencesWithBaseline(kurtosisResults)
    % Initialize arrays to store the differences
    diff_EO_EC_0_40 = [];
    diff_EO_DEC_0_40 = [];
    diff_EO_NDEC_0_40 = [];
    
    diff_EO_EC_8_12 = [];
    diff_EO_DEC_8_12 = [];
    diff_EO_NDEC_8_12 = [];

    % Iterate over each key and collect the differences
    keys = fieldnames(kurtosisResults);
    for i = 1:numel(keys)
        key = keys{i};
        kurtosis_0_40 = kurtosisResults.(key).kurtosis_0_40;
        kurtosis_8_12 = kurtosisResults.(key).kurtosis_8_12;

        diff_EO_EC_0_40 = [diff_EO_EC_0_40; kurtosis_0_40.EO - kurtosis_0_40.EC];
        diff_EO_DEC_0_40 = [diff_EO_DEC_0_40; kurtosis_0_40.EO - kurtosis_0_40.DEC];
        diff_EO_NDEC_0_40 = [diff_EO_NDEC_0_40; kurtosis_0_40.EO - kurtosis_0_40.NDEC];

        diff_EO_EC_8_12 = [diff_EO_EC_8_12; kurtosis_8_12.EO - kurtosis_8_12.EC];
        diff_EO_DEC_8_12 = [diff_EO_DEC_8_12; kurtosis_8_12.EO - kurtosis_8_12.DEC];
        diff_EO_NDEC_8_12 = [diff_EO_NDEC_8_12; kurtosis_8_12.EO - kurtosis_8_12.NDEC];
    end

    % Perform statistical tests within each group for 0-40 Hz
    [h_EO_EC_vs_EO_DEC_0_40, p_EO_EC_vs_EO_DEC_0_40] = ttest(diff_EO_EC_0_40, diff_EO_DEC_0_40);
    [h_EO_EC_vs_EO_NDEC_0_40, p_EO_EC_vs_EO_NDEC_0_40] = ttest(diff_EO_EC_0_40, diff_EO_NDEC_0_40);
    [h_EO_DEC_vs_EO_NDEC_0_40, p_EO_DEC_vs_EO_NDEC_0_40] = ttest(diff_EO_DEC_0_40, diff_EO_NDEC_0_40);

    % Perform statistical tests within each group for 8-12 Hz
    [h_EO_EC_vs_EO_DEC_8_12, p_EO_EC_vs_EO_DEC_8_12] = ttest(diff_EO_EC_8_12, diff_EO_DEC_8_12);
    [h_EO_EC_vs_EO_NDEC_8_12, p_EO_EC_vs_EO_NDEC_8_12] = ttest(diff_EO_EC_8_12, diff_EO_NDEC_8_12);
    [h_EO_DEC_vs_EO_NDEC_8_12, p_EO_DEC_vs_EO_NDEC_8_12] = ttest(diff_EO_DEC_8_12, diff_EO_NDEC_8_12);

    % Display the results of statistical tests within each group for 0-40 Hz
    fprintf('Comparison of Differences (0-40 Hz):\n');
    fprintf('EO-EC vs EO-DEC: p-value = %.4f, Significant = %d\n', p_EO_EC_vs_EO_DEC_0_40, h_EO_EC_vs_EO_DEC_0_40);
    fprintf('EO-EC vs EO-NDEC: p-value = %.4f, Significant = %d\n', p_EO_EC_vs_EO_NDEC_0_40, h_EO_EC_vs_EO_NDEC_0_40);
    fprintf('EO-DEC vs EO-NDEC: p-value = %.4f, Significant = %d\n', p_EO_DEC_vs_EO_NDEC_0_40, h_EO_DEC_vs_EO_NDEC_0_40);

    % Display the results of statistical tests within each group for 8-12 Hz
    fprintf('Comparison of Differences (8-12 Hz):\n');
    fprintf('EO-EC vs EO-DEC: p-value = %.4f, Significant = %d\n', p_EO_EC_vs_EO_DEC_8_12, h_EO_EC_vs_EO_DEC_8_12);
    fprintf('EO-EC vs EO-NDEC: p-value = %.4f, Significant = %d\n', p_EO_EC_vs_EO_NDEC_8_12, h_EO_EC_vs_EO_NDEC_8_12);
    fprintf('EO-DEC vs EO-NDEC: p-value = %.4f, Significant = %d\n', p_EO_DEC_vs_EO_NDEC_8_12, h_EO_DEC_vs_EO_NDEC_8_12);

    % Determine common y-axis limits for all plots
    all_differences = [diff_EO_EC_0_40; diff_EO_DEC_0_40; diff_EO_NDEC_0_40; ...
                       diff_EO_EC_8_12; diff_EO_DEC_8_12; diff_EO_NDEC_8_12];
    common_ylim = [min(all_differences), max(all_differences)];

    % Create box plots for visualization for 0-40 Hz
    figure;
    subplot(1,2,1);
    boxplot([diff_EO_EC_0_40; diff_EO_DEC_0_40; diff_EO_NDEC_0_40], ...
            [repmat({'EO-EC'}, size(diff_EO_EC_0_40, 1), 1); repmat({'EO-DEC'}, size(diff_EO_DEC_0_40, 1), 1); repmat({'EO-NDEC'}, size(diff_EO_NDEC_0_40, 1), 1)]);
    title('Differences (0-40 Hz)');
    ylabel('Difference in Kurtosis');
    ylim(common_ylim);

    % Create box plots for visualization for 8-12 Hz
    subplot(1,2,2);
    boxplot([diff_EO_EC_8_12; diff_EO_DEC_8_12; diff_EO_NDEC_8_12], ...
            [repmat({'EO-EC'}, size(diff_EO_EC_8_12, 1), 1); repmat({'EO-DEC'}, size(diff_EO_DEC_8_12, 1), 1); repmat({'EO-NDEC'}, size(diff_EO_NDEC_8_12, 1), 1)]);
    title('Differences (8-12 Hz)');
    ylabel('Difference in Kurtosis');
    ylim(common_ylim);
end
