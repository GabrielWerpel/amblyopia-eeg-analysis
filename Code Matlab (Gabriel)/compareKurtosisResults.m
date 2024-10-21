function compareKurtosisResults(kurtosisResults)
    % Initialize arrays to store kurtosis values for Amblyopia and Control groups
    kurtosis_0_40_A = [];
    kurtosis_0_40_C = [];
    kurtosis_8_12_A = [];
    kurtosis_8_12_C = [];

    % Iterate over each key and collect the kurtosis values
    keys = fieldnames(kurtosisResults);
    for i = 1:numel(keys)
        key = keys{i};
        group = kurtosisResults.(key).group;
        kurtosis_0_40 = kurtosisResults.(key).kurtosis_0_40;
        kurtosis_8_12 = kurtosisResults.(key).kurtosis_8_12;

        if strcmp(group, 'Amblyopia')
            kurtosis_0_40_A = [kurtosis_0_40_A; kurtosis_0_40.EC, kurtosis_0_40.DEC, kurtosis_0_40.NDEC, kurtosis_0_40.EO];
            kurtosis_8_12_A = [kurtosis_8_12_A; kurtosis_8_12.EC, kurtosis_8_12.DEC, kurtosis_8_12.NDEC, kurtosis_8_12.EO];
        elseif strcmp(group, 'Control')
            kurtosis_0_40_C = [kurtosis_0_40_C; kurtosis_0_40.EC, kurtosis_0_40.DEC, kurtosis_0_40.NDEC, kurtosis_0_40.EO];
            kurtosis_8_12_C = [kurtosis_8_12_C; kurtosis_8_12.EC, kurtosis_8_12.DEC, kurtosis_8_12.NDEC, kurtosis_8_12.EO];
        end
    end

    % Compute baseline statistics (mean and standard deviation)
    baseline_0_40_A = [mean(kurtosis_0_40_A); std(kurtosis_0_40_A)];
    baseline_0_40_C = [mean(kurtosis_0_40_C); std(kurtosis_0_40_C)];
    baseline_8_12_A = [mean(kurtosis_8_12_A); std(kurtosis_8_12_A)];
    baseline_8_12_C = [mean(kurtosis_8_12_C); std(kurtosis_8_12_C)];

    % Display baseline statistics
    fprintf('Baseline Statistics for Kurtosis (Amblyopia vs Control):\n');
    fprintf('0-40 Hz Frequency Range:\n');
    fprintf('Amblyopia - Mean: %.4f, Std: %.4f\n', baseline_0_40_A(1,1), baseline_0_40_A(2,1));
    fprintf('Control - Mean: %.4f, Std: %.4f\n', baseline_0_40_C(1,1), baseline_0_40_C(2,1));
    fprintf('8-12 Hz Frequency Range:\n');
    fprintf('Amblyopia - Mean: %.4f, Std: %.4f\n', baseline_8_12_A(1,1), baseline_8_12_A(2,1));
    fprintf('Control - Mean: %.4f, Std: %.4f\n', baseline_8_12_C(1,1), baseline_8_12_C(2,1));

    % Perform statistical tests
    [h_0_40_EC, p_0_40_EC] = ttest2(kurtosis_0_40_A(:, 1), kurtosis_0_40_C(:, 1));
    [h_0_40_DEC, p_0_40_DEC] = ttest2(kurtosis_0_40_A(:, 2), kurtosis_0_40_C(:, 2));
    [h_0_40_NDEC, p_0_40_NDEC] = ttest2(kurtosis_0_40_A(:, 3), kurtosis_0_40_C(:, 3));
    [h_0_40_EO, p_0_40_EO] = ttest2(kurtosis_0_40_A(:, 4), kurtosis_0_40_C(:, 4));

    [h_8_12_EC, p_8_12_EC] = ttest2(kurtosis_8_12_A(:, 1), kurtosis_8_12_C(:, 1));
    [h_8_12_DEC, p_8_12_DEC] = ttest2(kurtosis_8_12_A(:, 2), kurtosis_8_12_C(:, 2));
    [h_8_12_NDEC, p_8_12_NDEC] = ttest2(kurtosis_8_12_A(:, 3), kurtosis_8_12_C(:, 3));
    [h_8_12_EO, p_8_12_EO] = ttest2(kurtosis_8_12_A(:, 4), kurtosis_8_12_C(:, 4));

    % Display the results
    fprintf('Comparison of Kurtosis (Amblyopia vs Control):\n');
    fprintf('0-40 Hz Frequency Range:\n');
    fprintf('EC: p-value = %.4f, Significant = %d\n', p_0_40_EC, h_0_40_EC);
    fprintf('DEC: p-value = %.4f, Significant = %d\n', p_0_40_DEC, h_0_40_DEC);
    fprintf('NDEC: p-value = %.4f, Significant = %d\n', p_0_40_NDEC, h_0_40_NDEC);
    fprintf('EO: p-value = %.4f, Significant = %d\n', p_0_40_EO, h_0_40_EO);

    fprintf('8-12 Hz Frequency Range:\n');
    fprintf('EC: p-value = %.4f, Significant = %d\n', p_8_12_EC, h_8_12_EC);
    fprintf('DEC: p-value = %.4f, Significant = %d\n', p_8_12_DEC, h_8_12_DEC);
    fprintf('NDEC: p-value = %.4f, Significant = %d\n', p_8_12_NDEC, h_8_12_NDEC);
    fprintf('EO: p-value = %.4f, Significant = %d\n', p_8_12_EO, h_8_12_EO);

    % Create box plots for visualization
    figure;
    subplot(2,2,1);
    boxplot([kurtosis_0_40_A(:, 1); kurtosis_0_40_C(:, 1)], ...
            [repmat({'Amblyopia'}, size(kurtosis_0_40_A, 1), 1); repmat({'Control'}, size(kurtosis_0_40_C, 1), 1)]);
    title('EC Kurtosis (0-40 Hz)');
    ylabel('Kurtosis');

    subplot(2,2,2);
    boxplot([kurtosis_0_40_A(:, 2); kurtosis_0_40_C(:, 2)], ...
            [repmat({'Amblyopia'}, size(kurtosis_0_40_A, 1), 1); repmat({'Control'}, size(kurtosis_0_40_C, 1), 1)]);
    title('DEC Kurtosis (0-40 Hz)');
    ylabel('Kurtosis');

    subplot(2,2,3);
    boxplot([kurtosis_0_40_A(:, 3); kurtosis_0_40_C(:, 3)], ...
            [repmat({'Amblyopia'}, size(kurtosis_0_40_A, 1), 1); repmat({'Control'}, size(kurtosis_0_40_C, 1), 1)]);
    title('NDEC Kurtosis (0-40 Hz)');
    ylabel('Kurtosis');

    subplot(2,2,4);
    boxplot([kurtosis_0_40_A(:, 4); kurtosis_0_40_C(:, 4)], ...
            [repmat({'Amblyopia'}, size(kurtosis_0_40_A, 1), 1); repmat({'Control'}, size(kurtosis_0_40_C, 1), 1)]);
    title('EO Kurtosis (0-40 Hz)');
    ylabel('Kurtosis');

    figure;
    subplot(2,2,1);
    boxplot([kurtosis_8_12_A(:, 1); kurtosis_8_12_C(:, 1)], ...
            [repmat({'Amblyopia'}, size(kurtosis_8_12_A, 1), 1); repmat({'Control'}, size(kurtosis_8_12_C, 1), 1)]);
    title('EC Kurtosis (8-12 Hz)');
    ylabel('Kurtosis');

    subplot(2,2,2);
    boxplot([kurtosis_8_12_A(:, 2); kurtosis_8_12_C(:, 2)], ...
            [repmat({'Amblyopia'}, size(kurtosis_8_12_A, 1), 1); repmat({'Control'}, size(kurtosis_8_12_C, 1), 1)]);
    title('DEC Kurtosis (8-12 Hz)');
    ylabel('Kurtosis');

    subplot(2,2,3);
    boxplot([kurtosis_8_12_A(:, 3); kurtosis_8_12_C(:, 3)], ...
            [repmat({'Amblyopia'}, size(kurtosis_8_12_A, 1), 1); repmat({'Control'}, size(kurtosis_8_12_C, 1), 1)]);
    title('NDEC Kurtosis (8-12 Hz)');
    ylabel('Kurtosis');

    subplot(2,2,4);
    boxplot([kurtosis_8_12_A(:, 4); kurtosis_8_12_C(:, 4)], ...
            [repmat({'Amblyopia'}, size(kurtosis_8_12_A, 1), 1); repmat({'Control'}, size(kurtosis_8_12_C, 1), 1)]);
    title('EO Kurtosis (8-12 Hz)');
    ylabel('Kurtosis');
end
