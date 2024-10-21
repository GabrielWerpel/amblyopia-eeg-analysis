function compareSkewnessResults(skewnessResults)
    % Initialize arrays to store skewness values for Amblyopia and Control groups
    skewness_0_40_A = [];
    skewness_0_40_C = [];
    skewness_8_12_A = [];
    skewness_8_12_C = [];

    % Iterate over each key and collect the skewness values
    keys = fieldnames(skewnessResults);
    for i = 1:numel(keys)
        key = keys{i};
        group = skewnessResults.(key).group;
        skewness_0_40 = skewnessResults.(key).skewness_0_40;
        skewness_8_12 = skewnessResults.(key).skewness_8_12;

        if strcmp(group, 'Amblyopia')
            skewness_0_40_A = [skewness_0_40_A; skewness_0_40.EC, skewness_0_40.DEC, skewness_0_40.NDEC, skewness_0_40.EO];
            skewness_8_12_A = [skewness_8_12_A; skewness_8_12.EC, skewness_8_12.DEC, skewness_8_12.NDEC, skewness_8_12.EO];
        elseif strcmp(group, 'Control')
            skewness_0_40_C = [skewness_0_40_C; skewness_0_40.EC, skewness_0_40.DEC, skewness_0_40.NDEC, skewness_0_40.EO];
            skewness_8_12_C = [skewness_8_12_C; skewness_8_12.EC, skewness_8_12.DEC, skewness_8_12.NDEC, skewness_8_12.EO];
        end
    end

    % Compute baseline statistics (mean and standard deviation)
    baseline_0_40_A = [mean(skewness_0_40_A); std(skewness_0_40_A)];
    baseline_0_40_C = [mean(skewness_0_40_C); std(skewness_0_40_C)];
    baseline_8_12_A = [mean(skewness_8_12_A); std(skewness_8_12_A)];
    baseline_8_12_C = [mean(skewness_8_12_C); std(skewness_8_12_C)];

    % Display baseline statistics
    fprintf('Baseline Statistics for Skewness (Amblyopia vs Control):\n');
    fprintf('0-40 Hz Frequency Range:\n');
    fprintf('Amblyopia - Mean: %.4f, Std: %.4f\n', baseline_0_40_A(1,1), baseline_0_40_A(2,1));
    fprintf('Control - Mean: %.4f, Std: %.4f\n', baseline_0_40_C(1,1), baseline_0_40_C(2,1));
    fprintf('8-12 Hz Frequency Range:\n');
    fprintf('Amblyopia - Mean: %.4f, Std: %.4f\n', baseline_8_12_A(1,1), baseline_8_12_A(2,1));
    fprintf('Control - Mean: %.4f, Std: %.4f\n', baseline_8_12_C(1,1), baseline_8_12_C(2,1));

    % Perform statistical tests
    [h_0_40_EC, p_0_40_EC] = ttest2(skewness_0_40_A(:, 1), skewness_0_40_C(:, 1));
    [h_0_40_DEC, p_0_40_DEC] = ttest2(skewness_0_40_A(:, 2), skewness_0_40_C(:, 2));
    [h_0_40_NDEC, p_0_40_NDEC] = ttest2(skewness_0_40_A(:, 3), skewness_0_40_C(:, 3));
    [h_0_40_EO, p_0_40_EO] = ttest2(skewness_0_40_A(:, 4), skewness_0_40_C(:, 4));

    [h_8_12_EC, p_8_12_EC] = ttest2(skewness_8_12_A(:, 1), skewness_8_12_C(:, 1));
    [h_8_12_DEC, p_8_12_DEC] = ttest2(skewness_8_12_A(:, 2), skewness_8_12_C(:, 2));
    [h_8_12_NDEC, p_8_12_NDEC] = ttest2(skewness_8_12_A(:, 3), skewness_8_12_C(:, 3));
    [h_8_12_EO, p_8_12_EO] = ttest2(skewness_8_12_A(:, 4), skewness_8_12_C(:, 4));

    % Display the results
    fprintf('Comparison of Skewness (Amblyopia vs Control):\n');
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
    boxplot([skewness_0_40_A(:, 1); skewness_0_40_C(:, 1)], ...
            [repmat({'Amblyopia'}, size(skewness_0_40_A, 1), 1); repmat({'Control'}, size(skewness_0_40_C, 1), 1)]);
    title('EC Skewness (0-40 Hz)');
    ylabel('Skewness');

    subplot(2,2,2);
    boxplot([skewness_0_40_A(:, 2); skewness_0_40_C(:, 2)], ...
            [repmat({'Amblyopia'}, size(skewness_0_40_A, 1), 1); repmat({'Control'}, size(skewness_0_40_C, 1), 1)]);
    title('DEC Skewness (0-40 Hz)');
    ylabel('Skewness');

    subplot(2,2,3);
    boxplot([skewness_0_40_A(:, 3); skewness_0_40_C(:, 3)], ...
            [repmat({'Amblyopia'}, size(skewness_0_40_A, 1), 1); repmat({'Control'}, size(skewness_0_40_C, 1), 1)]);
    title('NDEC Skewness (0-40 Hz)');
    ylabel('Skewness');

    subplot(2,2,4);
    boxplot([skewness_0_40_A(:, 4); skewness_0_40_C(:, 4)], ...
            [repmat({'Amblyopia'}, size(skewness_0_40_A, 1), 1); repmat({'Control'}, size(skewness_0_40_C, 1), 1)]);
    title('EO Skewness (0-40 Hz)');
    ylabel('Skewness');

    figure;
    subplot(2,2,1);
    boxplot([skewness_8_12_A(:, 1); skewness_8_12_C(:, 1)], ...
            [repmat({'Amblyopia'}, size(skewness_8_12_A, 1), 1); repmat({'Control'}, size(skewness_8_12_C, 1), 1)]);
    title('EC Skewness (8-12 Hz)');
    ylabel('Skewness');

    subplot(2,2,2);
    boxplot([skewness_8_12_A(:, 2); skewness_8_12_C(:, 2)], ...
            [repmat({'Amblyopia'}, size(skewness_8_12_A, 1), 1); repmat({'Control'}, size(skewness_8_12_C, 1), 1)]);
    title('DEC Skewness (8-12 Hz)');
    ylabel('Skewness');

    subplot(2,2,3);
    boxplot([skewness_8_12_A(:, 3); skewness_8_12_C(:, 3)], ...
            [repmat({'Amblyopia'}, size(skewness_8_12_A, 1), 1); repmat({'Control'}, size(skewness_8_12_C, 1), 1)]);
    title('NDEC Skewness (8-12 Hz)');
    ylabel('Skewness');

    subplot(2,2,4);
    boxplot([skewness_8_12_A(:, 4); skewness_8_12_C(:, 4)], ...
            [repmat({'Amblyopia'}, size(skewness_8_12_A, 1), 1); repmat({'Control'}, size(skewness_8_12_C, 1), 1)]);
    title('EO Skewness (8-12 Hz)');
    ylabel('Skewness');
end
