function plotReactivityScatterPlots2(reactivityResults, segmentedData, columnName, titleName)
    % Initialize variables to store keys and data
    keys = fieldnames(reactivityResults);  % Get all keys like 'A1', 'A2', etc.
    
    % Prepare variables for table
    keyColumn = {};
    sectionColumn = {};
    reactivityColumn = [];  % Rename the variable for clarity
    linesDifferenceColumn = [];  % Include LinesDifference column
    
    % Loop over all keys to populate the table data
    for i = 1:numel(keys)
        % Get the section names that start with 'reactivity'
        sections = fieldnames(reactivityResults.(keys{i}));
        reactivitySections = sections(startsWith(sections, 'reactivity'));
    
        % Loop through each 'reactivity' section to extract data
        for j = 1:numel(reactivitySections)
            keyColumn{end+1, 1} = keys{i};
            cleanSectionName = strrep(reactivitySections{j}, 'reactivity_', '');  % Remove 'reactivity_' prefix
            sectionColumn{end+1, 1} = cleanSectionName;
            reactivityColumn(end+1, 1) = reactivityResults.(keys{i}).(reactivitySections{j});
            
            % Get LinesDifference value if available
            if isfield(segmentedData.(keys{i}), 'LinesDifference')
                linesDifferenceColumn(end+1, 1) = segmentedData.(keys{i}).LinesDifference;
            else
                linesDifferenceColumn(end+1, 1) = NaN;  % Use NaN for Control or missing values
            end
        end
    end

    % Create the table
    data = table(keyColumn, sectionColumn, reactivityColumn, linesDifferenceColumn, ...
        'VariableNames', {'Key', 'Section', 'Reactivity', 'LinesDifference'});

    includedSections = {'EO_EC', 'EO_DEC', 'EO_NDEC'};

    % Filter rows based on 'Key' starting with 'A' and included sections
    dataA = data(contains(data.Key, 'A') & ismember(data.Section, includedSections), :);
    % Filter rows based on 'Key' starting with 'C' and included sections
    dataC = data(contains(data.Key, 'C') & ismember(data.Section, includedSections), :);

    % Convert 'Section' columns to categorical
    dataA.Section = categorical(dataA.Section, includedSections);
    dataC.Section = categorical(dataC.Section, includedSections);

    % Adjust x-coordinates for spacing
    xA = double(dataA.Section) - 0.2; % Shift Amblyopia points slightly to the left
    xC = double(dataC.Section) + 0.2; % Shift Control points slightly to the right

    % Normalize LinesDifference for color intensity (only for Amblyopia)
    normLinesDiffA = (dataA.LinesDifference - min(dataA.LinesDifference, [], 'omitnan')) / ...
                     (max(dataA.LinesDifference, [], 'omitnan') - min(dataA.LinesDifference, [], 'omitnan'));

    % Define marker symbols for each patient
    markers = {'o', 's', 'd', '>', '<', 'p', 'h'};
    numMarkers = numel(markers);
    markerMap = containers.Map(keys, markers(mod(1:numel(keys), numMarkers) + 1));

    % Create figure and set size
    figure('Position', [100, 100, 1200, 800]);
    hold on;

    % Plot data for Amblyopia with varying color intensity and different markers
    for i = 1:numel(dataA.Key)
        key = dataA.Key{i};
        marker = markerMap(key);
        scatter(xA(i), dataA.Reactivity(i), 50, [0, 0, 1], marker, 'filled', 'MarkerFaceColor', 'none', 'MarkerEdgeColor', [0, 0, 1] .* (0.5 + 0.5 * normLinesDiffA(i)));
    end
    
    % Plot data for Control with fixed color and different markers
    for i = 1:numel(dataC.Key)
        key = dataC.Key{i};
        marker = markerMap(key);
        scatter(xC(i), dataC.Reactivity(i), 50, 'r', marker, 'filled', 'MarkerFaceColor', 'none', 'MarkerEdgeColor', 'r');
    end

    % Create a custom legend with unique markers for each patient
    uniqueKeys = unique([dataA.Key; dataC.Key]);
    legendHandles = gobjects(numel(uniqueKeys), 1);
    legendLabels = cell(numel(uniqueKeys), 1);
    for i = 1:numel(uniqueKeys)
        key = uniqueKeys{i};
        marker = markerMap(key);
        if contains(key, 'A')
            color = 'b';  % Blue for Amblyopia
        else
            color = 'r';  % Red for Control
        end
        legendHandles(i) = plot(nan, nan, marker, 'MarkerFaceColor', 'none', 'MarkerEdgeColor', color);
        legendLabels{i} = key;
    end

    % Enhance the plot
    ylabel(columnName);
    xlabel('Section');
    xticks(1:length(includedSections));
    xticklabels(includedSections);
    legend(legendHandles, legendLabels, 'Location', 'southeast');  % Custom legend
    title(['Comparison of ', titleName, ' for Amblyopia and Control']);
    grid on;
    hold off;
end
