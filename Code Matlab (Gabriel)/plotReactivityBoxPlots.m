function plotReactivityBoxPlots(reactivityResults, columnName, titleName)
    % Initialize variables to store keys and data
    keys = fieldnames(reactivityResults);  % Get all keys like 'A1', 'A2', etc.
    
    % Prepare variables for table
    keyColumn = {};
    sectionColumn = {};
    reactivityColumn = [];  % Rename the variable for clarity
    
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
        end
    end

    % Create the table
    data = table(keyColumn, sectionColumn, reactivityColumn, ...
        'VariableNames', {'Key', 'Section', 'Reactivity'});

    includedSections = {'EO_EC', 'EO_DEC', 'EO_NDEC'};

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

    % Convert to categorical for ordering
    combinedData.Section = categorical(combinedData.Section, includedSections);

    % Rename the categories to replace underscores with hyphens
    newLabels = strrep(categories(combinedData.Section), '_', '-');
    combinedData.Section = renamecats(combinedData.Section, newLabels);

    combinedData.Group = categorical(combinedData.Group);

    % Box plot
    figure;
    boxchart(combinedData.Section, combinedData.(columnName), 'GroupByColor', combinedData.Group);
    hold on;

    % Enhance the plot
    ylabel(columnName);
    xlabel('Section');
    legend('Amblyopia', 'Control','Location', 'southeast');  % Updated legend location
    title(['Comparison of ', titleName, ' for Amblyopia and Control']);
    grid on;
end
