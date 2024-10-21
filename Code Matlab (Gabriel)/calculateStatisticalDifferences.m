function calculateStatisticalDifferences(data, columnName)
    % Define the sections to include and their display names
    sections = {'Difference_EC_EO', 'Difference_DEC_EO', 'Difference_NDEC_EO'};
    displayNames = {'EO-EC', 'EO-DEC', 'EO-NDEC'};

    fprintf('Pairwise Statistical Analysis for %s:\n', columnName);

    % Iterate over pairs of sections for comparison
    for i = 1:length(sections)
        for j = i+1:length(sections)
            section1 = sections{i};
            section2 = sections{j};
            displayName1 = displayNames{i};
            displayName2 = displayNames{j};

            % Filter data for the current sections
            data1 = data.(columnName)(strcmp(data.Section, section1));
            data2 = data.(columnName)(strcmp(data.Section, section2));

            % Perform normality test to decide between t-test and Mann-Whitney U test
            [~, pNormality1] = kstest(data1);
            [~, pNormality2] = kstest(data2);

            % Perform statistical test
            if pNormality1 > 0.05 && pNormality2 > 0.05
                % If both datasets are normally distributed, perform two-sample t-test
                [~, pValue] = ttest2(data1, data2);
            else
                % If at least one dataset is not normally distributed, perform Mann-Whitney U test
                pValue = ranksum(data1, data2);
            end

            fprintf('%s vs %s: p-value = %.4f\n', displayName1, displayName2, pValue);
        end
    end
end
