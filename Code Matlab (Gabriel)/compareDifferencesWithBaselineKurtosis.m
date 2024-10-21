function compareDifferencesWithBaselineKurtosis(kurtosisResults)
    % Initialize arrays to store the differences for Amblyopia and Control groups
    diff_EO_EC_0_40_A = [];
    diff_EO_DEC_0_40_A = [];
    diff_EO_NDEC_0_40_A = [];
    diff_EO_EC_0_40_C = [];
    diff_EO_DEC_0_40_C = [];
    diff_EO_NDEC_0_40_C = [];
    
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
        kurtosis_0_40 = kurtosisResults.(key).kurtosis_0_40;
        kurtosis_8_12 = kurtosisResults.(key).kurtosis_8_12;

        diff_EO_EC_0_40 = kurtosis_0_40.EO - kurtosis_0_40.EC;
        diff_EO_DEC_0_40 = kurtosis_0_40.EO - kurtosis_0_40.DEC;
        diff_EO_NDEC_0_40 = kurtosis_0_40.EO - kurtosis_0_40.NDEC;

        diff_EO_EC_8_12 = kurtosis_8_12.EO - kurtosis_8_12.EC;
        diff_EO_DEC_8_12 = kurtosis_8_12.EO - kurtosis_8_12.DEC;
        diff_EO_NDEC_8_12 = kurtosis_8_12.EO - kurtosis_8_12.NDEC;

        if strcmp(group, 'Amblyopia')
            diff_EO_EC_0_40_A = [diff_EO_EC_0_40_A; diff_EO_EC_0_40];
            diff_EO_DEC_0_40_A = [diff_EO_DEC_0_40_A; diff_EO_DEC_0_40];
            diff_EO_NDEC_0_40_A = [diff_EO_NDEC_0_40_A; diff_EO_NDEC_0_40];
            
            diff_EO_EC_8_12_A = [diff_EO_EC_8_12_A; diff_EO_EC_8_12];
            diff_EO_DEC_8_12_A = [diff_EO_DEC_8_12_A; diff_EO_DEC_8_12];
            diff_EO_NDEC_8_12_A = [diff_EO_NDEC_8_12_A; diff_EO_NDEC_8_12];
        elseif strcmp(group, 'Control')
            diff_EO_EC_0_40_C = [diff_EO_EC_0_40_C; diff_EO_EC_0_40];
            diff_EO_DEC_0_40_C = [diff_EO_DEC_0_40_C; diff_EO_DEC_0_40];
            diff_EO_NDEC_0_40_C = [diff_EO_NDEC_0_40_C; diff_EO_NDEC_0_40];
            
            diff_EO_EC_8_12_C = [diff_EO_EC_8_12_C; diff_EO_EC_8_12];
            diff_EO_DEC_8_12_C = [diff_EO_DEC_8_12_C; diff_EO_DEC_8_12];
            diff_EO_NDEC_8_12_C = [diff_EO_NDEC_8_12_C; diff_EO_NDEC_8_12];
        end
    end

    % Perform statistical tests within each group for 0-40 Hz
    [h_EO_EC_0_40_A, p_EO_EC_0_40_A] = ttest(diff_EO_EC_0_40_A);
    [h_EO_DEC_0_40_A, p_EO_DEC_0_40_A] = ttest(diff_EO_DEC_0_40_A);
    [h_EO_NDEC_0_40_A, p_EO_NDEC_0_40_A] = ttest(diff_EO_NDEC_0_40_A);

    [h_EO_EC_0_40_C, p_EO_EC_0_40_C] = ttest(diff_EO_EC_0_40_C);
    [h_EO_DEC_0_40_C, p_EO_DEC_0_40_C] = ttest(diff_EO_DEC_0_40_C);
    [h_EO_NDEC_0_40_C, p_EO_NDEC_0_40_C] = ttest(diff_EO_NDEC_0_40_C);

    % Perform statistical tests between groups for 0-40 Hz
    [h_diff_EO_EC_0_40, p_diff_EO_EC_0_40] = ttest2(diff_EO_EC_0_40_A, diff_EO_EC_0_40_C);
    [h_diff_EO_DEC_0_40, p_diff_EO_DEC_0_40] = ttest2(diff_EO_DEC_0_40_A, diff_EO_DEC_0_40_C);
    [h_diff_EO_NDEC_0_40, p_diff_EO_NDEC_0_40] = ttest2(diff_EO_NDEC_0_40_A, diff_EO_NDEC_0_40_C);

    % Perform statistical tests within each group for 8-12 Hz
    [h_EO_EC_8_12_A, p_EO_EC_8_12_A] = ttest(diff_EO_EC_8_12_A);
    [h_EO_DEC_8_12_A, p_EO_DEC_8_12_A] = ttest(diff_EO_DEC_8_12_A);
    [h_EO_NDEC_8_12_A, p_EO_NDEC_8_12_A] = ttest(diff_EO_NDEC_8_12_A);

    [h_EO_EC_8_12_C, p_EO_EC_8_12_C] = ttest(diff_EO_EC_8_12_C);
    [h_EO_DEC_8_12_C, p_EO_DEC_8_12_C] = ttest(diff_EO_DEC_8_12_C);
    [h_EO_NDEC_8_12_C, p_EO_NDEC_8_12_C] = ttest(diff_EO_NDEC_8_12_C);

    % Perform statistical tests between groups for 8-12 Hz
    [h_diff_EO_EC_8_12, p_diff_EO_EC_8_12] = ttest2(diff_EO_EC_8_12_A, diff_EO_EC_8_12_C);
    [h_diff_EO_DEC_8_12, p_diff_EO_DEC_8_12] = ttest2(diff_EO_DEC_8_12_A, diff_EO_DEC_8_12_C);
    [h_diff_EO_NDEC_8_12, p_diff_EO_NDEC_8_12] = ttest2(diff_EO_NDEC_8_12_A, diff_EO_NDEC_8_12_C);

    % Display the results of statistical tests within each group for 0-40 Hz
    fprintf('Comparison of Differences Within Each Group (Amblyopia, 0-40 Hz):\n');
    fprintf('EO - EC: p-value = %.4f, Significant = %d\n', p_EO_EC_0_40_A, h_EO_EC_0_40_A);
    fprintf('EO - DEC: p-value = %.4f, Significant = %d\n', p_EO_DEC_0_40_A, h_EO_DEC_0_40_A);
    fprintf('EO - NDEC: p-value = %.4f, Significant = %d\n', p_EO_NDEC_0_40_A, h_EO_NDEC_0_40_A);

    fprintf('Comparison of Differences Within Each Group (Control, 0-40 Hz):\n');
    fprintf('EO - EC: p-value = %.4f, Significant = %d\n', p_EO_EC_0_40_C, h_EO_EC_0_40_C);
    fprintf('EO - DEC: p-value = %.4f, Significant = %d\n', p_EO_DEC_0_40_C, h_EO_DEC_0_40_C);
    fprintf('EO - NDEC: p-value = %.4f, Significant = %d\n', p_EO_NDEC_0_40_C, h_EO_NDEC_0_40_C);

    fprintf('Comparison of Differences Between Groups (0-40 Hz):\n');
    fprintf('EO - EC: p-value = %.4f, Significant = %d\n', p_diff_EO_EC_0_40, h_diff_EO_EC_0_40);
    fprintf('EO - DEC: p-value = %.4f, Significant = %d\n', p_diff_EO_DEC_0_40, h_diff_EO_DEC_0_40);
    fprintf('EO - NDEC: p-value = %.4f, Significant = %d\n', p_diff_EO_NDEC_0_40, h_diff_EO_NDEC_0_40);

    % Display the results of statistical tests within each group for 8-12 Hz
    fprintf('Comparison of Differences Within Each Group (Amblyopia, 8-12 Hz):\n');
    fprintf('EO - EC: p-value = %.4f, Significant = %d\n', p_EO_EC_8_12_A, h_EO_EC_8_12_A);
    fprintf('EO - DEC: p-value = %.4f, Significant = %d\n', p_EO_DEC_8_12_A, h_EO_DEC_8_12_A);
    fprintf('EO - NDEC: p-value = %.4f, Significant = %d\n', p_EO_NDEC_8_12_A, h_EO_NDEC_8_12_A);

    fprintf('Comparison of Differences Within Each Group (Control, 8-12 Hz):\n');
    fprintf('EO - EC: p-value = %.4f, Significant = %d\n', p_EO_EC_8_12_C, h_EO_EC_8_12_C);
    fprintf('EO - DEC: p-value = %.4f, Significant = %d\n', p_EO_DEC_8_12_C, h_EO_DEC_8_12_C);
    fprintf('EO - NDEC: p-value = %.4f, Significant = %d\n', p_EO_NDEC_8_12_C, h_EO_NDEC_8_12_C);

    fprintf('Comparison of Differences Between Groups (8-12 Hz):\n');
    fprintf('EO - EC: p-value = %.4f, Significant = %d\n', p_diff_EO_EC_8_12, h_diff_EO_EC_8_12);
    fprintf('EO - DEC: p-value = %.4f, Significant = %d\n', p_diff_EO_DEC_8_12, h_diff_EO_DEC_8_12);
    fprintf('EO - NDEC: p-value = %.4f, Significant = %d\n', p_diff_EO_NDEC_8_12, h_diff_EO_NDEC_8_12);

    % Create box plots for visualization for 0-40 Hz
    figure;
    subplot(2,3,1);
    boxplot([diff_EO_EC_0_40_A; diff_EO_EC_0_40_C], ...
            [repmat({'Amblyopia'}, size(diff_EO_EC_0_40_A, 1), 1); repmat({'Control'}, size(diff_EO_EC_0_40_C, 1), 1)]);
    title('Difference (EO - EC, 0-40 Hz)');
    ylabel('Difference in Kurtosis');

    subplot(2,3,2);
    boxplot([diff_EO_DEC_0_40_A; diff_EO_DEC_0_40_C], ...
            [repmat({'Amblyopia'}, size(diff_EO_DEC_0_40_A, 1), 1); repmat({'Control'}, size(diff_EO_DEC_0_40_C, 1), 1)]);
    title('Difference (EO - DEC, 0-40 Hz)');
    ylabel('Difference in Kurtosis');

    subplot(2,3,3);
    boxplot([diff_EO_NDEC_0_40_A; diff_EO_NDEC_0_40_C], ...
            [repmat({'Amblyopia'}, size(diff_EO_NDEC_0_40_A, 1), 1); repmat({'Control'}, size(diff_EO_NDEC_0_40_C, 1), 1)]);
    title('Difference (EO - NDEC, 0-40 Hz)');
    ylabel('Difference in Kurtosis');

    % Create box plots for visualization for 8-12 Hz
    subplot(2,3,4);
    boxplot([diff_EO_EC_8_12_A; diff_EO_EC_8_12_C], ...
            [repmat({'Amblyopia'}, size(diff_EO_EC_8_12_A, 1), 1); repmat({'Control'}, size(diff_EO_EC_8_12_C, 1), 1)]);
    title('Difference (EO - EC, 8-12 Hz)');
    ylabel('Difference in Kurtosis');

    subplot(2,3,5);
    boxplot([diff_EO_DEC_8_12_A; diff_EO_DEC_8_12_C], ...
            [repmat({'Amblyopia'}, size(diff_EO_DEC_8_12_A, 1), 1); repmat({'Control'}, size(diff_EO_DEC_8_12_C, 1), 1)]);
    title('Difference (EO - DEC, 8-12 Hz)');
    ylabel('Difference in Kurtosis');

    subplot(2,3,6);
    boxplot([diff_EO_NDEC_8_12_A; diff_EO_NDEC_8_12_C], ...
            [repmat({'Amblyopia'}, size(diff_EO_NDEC_8_12_A, 1), 1); repmat({'Control'}, size(diff_EO_NDEC_8_12_C, 1), 1)]);
    title('Difference (EO - NDEC, 8-12 Hz)');
    ylabel('Difference in Kurtosis');
end

