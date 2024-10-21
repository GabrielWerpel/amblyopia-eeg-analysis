function plotBandwidthBoxPlots(bandwidthResults, columnName, titleName)
    % Initialize variables to store keys and data
    keys = fieldnames(bandwidthResults);  % Get all keys like 'A1', 'A2', etc.
    
    % Prepare variables for table
    keyColumn = {};
    sectionColumn = {};
    bandwidthColumn = [];  % Rename the variable for clarity
    
    % Loop over all keys to populate the table data
    for i = 1:numel(keys)
        % Get the condition names like 'EC', 'DEC', 'NDEC'
        conditions = fieldnames(bandwidthResults.(keys{i}));
        
        % Loop through each condition to extract bandwidth data
        for j = 1:numel(conditions)
            keyColumn{end+1, 1} = keys{i};
            sectionColumn{end+1, 1} = conditions{j};
            bandwidthColumn(end+1, 1) = bandwidthResults.(keys{i}).(conditions{j}).bandwidth;
        end
    end

    % Create the table
    data = table(keyColumn, sectionColumn, bandwidthColumn, ...
        'VariableNames', {'Key', 'Section', 'Bandwidth'});

    includedSections = {'EO', 'EC', 'DEC', 'NDEC'};

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
    combinedData.Group = categorical(combinedData.Group);

    % Box plot
    figure;
    boxchart(combinedData.Section, combinedData.(columnName), 'GroupByColor', combinedData.Group);
    hold on;

    % Enhance the plot
    ylabel(columnName);
    xlabel('Section');
    legend('Amblyopia', 'Control', 'Location', 'southeast');  % Updated legend location
    title(['Comparison of ', titleName, ' for Amblyopia and Control']);
    grid on;
end
