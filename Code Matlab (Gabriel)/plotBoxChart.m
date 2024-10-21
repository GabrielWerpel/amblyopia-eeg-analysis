function plotBoxChart(data, columnName, titleName)
    % Define the custom order for sections and the sections to include
    %customOrder = {'EO', 'EC', 'EO-EC', 'Ratio_EC_EO', 'DEC', 'EO-DEC', ...
    %               'Ratio_DEC_EO', 'NDEC', 'EO-NDEC', 'Ratio_NDEC_EO'};
    customOrder = {'EO-EC', 'EO-DEC', 'EO-NDEC'};
    includedSections = {'Difference_EC_EO', 'Difference_DEC_EO', 'Difference_NDEC_EO'};

    % Filter rows based on 'Key' starting with 'A' and included sections
    dataA = data(contains(data.Key, 'A') & ismember(data.Section, includedSections), :);
    % Filter rows based on 'Key' starting with 'C' and included sections
    dataC = data(contains(data.Key, 'C') & ismember(data.Section, includedSections), :);

    % Create a new table for box plot
    boxDataA = dataA(:, {'Section', columnName});
    boxDataA.Group = repmat({'Amblyopia'}, size(boxDataA, 1), 1);

    boxDataC = dataC(:, {'Section', columnName});
    boxDataC.Group = repmat({'Control'}, size(boxDataC, 1), 1);

    combinedData = [boxDataA; boxDataC];

    % Rename the sections for plotting
    combinedData.Section = renameSections(combinedData.Section);
    
    % Convert to categorical for ordering
    combinedData.Section = categorical(combinedData.Section, customOrder);
    combinedData.Group = categorical(combinedData.Group);

    % Box plot
    figure;
    boxchart(combinedData.Section, combinedData.(columnName), 'GroupByColor', combinedData.Group);
    hold on;

    % Enhance the plot
    ylabel(columnName);
    xlabel('Section');
    legend('Amblyopia', 'Control');
    % title(['Comparison of ', titleName, ' for Amblyopia and Control']);
    grid on;
end

function newSections = renameSections(sections)
    % This function renames the sections to the desired names for plotting
    newSections = cell(size(sections));
    for i = 1:length(sections)
        if strcmp(sections{i}, 'Difference_EC_EO')
            newSections{i} = 'EO-EC';
        elseif strcmp(sections{i}, 'Difference_DEC_EO')
            newSections{i} = 'EO-DEC';
        elseif strcmp(sections{i}, 'Difference_NDEC_EO')
            newSections{i} = 'EO-NDEC';
        else
            newSections{i} = sections{i};
        end
    end
end
