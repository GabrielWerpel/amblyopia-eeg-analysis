function plotBarChart(data, columnName, titleName)
    % Define the custom order for sections and the sections to include
    customOrder = {'EO', 'EC', 'Difference_EC_EO', 'Ratio_EC_EO', 'DEC', 'Difference_DEC_EO', ...
                   'Ratio_DEC_EO', 'NDEC', 'Difference_NDEC_EO', 'Ratio_NDEC_EO'};
    includedSections = {'EC', 'EO', 'DEC', 'NDEC'};

    % Filter rows based on 'Key' starting with 'A' and included sections
    dataA = data(contains(data.Key, 'A') & ismember(data.Section, includedSections), :);
    % Filter rows based on 'Key' starting with 'C' and included sections
    dataC = data(contains(data.Key, 'C') & ismember(data.Section, includedSections), :);

    % Group by 'Section' and calculate mean and standard deviation for the specified column for A
    groupStatsA = varfun(@mean, dataA, 'InputVariables', columnName, ...
                         'GroupingVariables', 'Section');
    groupStatsA.Std = splitapply(@std, dataA.(columnName), findgroups(dataA.Section));
    [~, orderA] = ismember(groupStatsA.Section, customOrder);
    groupStatsA = sortrows([groupStatsA table(orderA)], 'orderA');

    % Group by 'Section' and calculate mean and standard deviation for the specified column for C
    groupStatsC = varfun(@mean, dataC, 'InputVariables', columnName, ...
                         'GroupingVariables', 'Section');
    groupStatsC.Std = splitapply(@std, dataC.(columnName), findgroups(dataC.Section));
    [~, orderC] = ismember(groupStatsC.Section, customOrder);
    groupStatsC = sortrows([groupStatsC table(orderC)], 'orderC');

    % Prepare data for plotting
    meanValuesA = groupStatsA.(sprintf('mean_%s', columnName));
    meanValuesC = groupStatsC.(sprintf('mean_%s', columnName));
    meanValues = [meanValuesA, meanValuesC];
    stdValuesA = groupStatsA.Std;
    stdValuesC = groupStatsC.Std;
    stdValues = [stdValuesA, stdValuesC];

    % Bar chart with error bars
    figure;
    b = bar(meanValues, 'grouped');
    hold on;

    % Calculate x coordinates for the error bars
    nGroups = size(meanValues, 1);
    groupWidth = min(0.8, size(meanValues, 2)/(size(meanValues, 2) + 1.5));
    x = nan(size(meanValues));
    for i = 1:size(meanValues, 2)
        x(:, i) = b(i).XEndPoints;
    end

    % Add error bars
    errorbar(x, meanValues, stdValues, 'k', 'linestyle', 'none');

    hold off;

    % Enhance the plot
    xticks(1:length(groupStatsA.Section));
    xticklabels(groupStatsA.Section);
    ylabel(columnName);
    xlabel('Section');
    legend('Amblyopic', 'Control');
    % title(['Comparison of ', titleName, ' for Amblyopia and Control by Section']);
    grid on;
end