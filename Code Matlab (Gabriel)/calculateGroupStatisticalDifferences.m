function calculateGroupStatisticalDifferences(data, columnName)
    % Define the sections to include and their display names
    sections = {'Difference_EC_EO', 'Difference_DEC_EO', 'Difference_NDEC_EO'};
    displayNames = {'EO-EC', 'EO-DEC', 'EO-NDEC'};

    fprintf('Group Statistical Analysis for %s (Amblyopia vs Control):\n', columnName);

    for i = 1:length(sections)
        section = sections{i};
        displayName = displayNames{i};

        % Filter data for the current section and groups
        dataA = data.(columnName)(strcmp(data.Section, section) & contains(data.Key, 'A'));
        dataC = data.(columnName)(strcmp(data.Section, section) & contains(data.Key, 'C'));

        % Perform normality test to decide between t-test and Mann-Whitney U test
        [~, pNormalityA] = kstest(dataA);
        [~, pNormalityC] = kstest(dataC);

        % Perform statistical test
        if pNormalityA > 0.05 && pNormalityC > 0.05
            % If both datasets are normally distributed, perform two-sample t-test
            [~, pValue] = ttest2(dataA, dataC);
        else
            % If at least one dataset is not normally distributed, perform Mann-Whitney U test
            pValue = ranksum(dataA, dataC);
        end

        fprintf('%s (Amblyopia vs Control): p-value = %.4f\n', displayName, pValue);
    end
end
