function plotBoxCharta(extendedStatisticsResults)
    % Define included sections
    includedSections = {'EC', 'EO', 'DEC', 'NDEC'};
    
    % Get all keys in the results
    keys = fieldnames(extendedStatisticsResults);
    
    % Define the statistics to plot
    statisticFields = {'mean'}; % Focused on 'mean' as per your example
    
    % Initialize data structures for plotting
    allData = [];
    groupNumbers = []; % Use numerical values for group association
    sectionLabels = []; % Use numerical indices for section association
    legendInfo = {'Amblyopia', 'Control'}; % Legends for the groups
    
    % Collect data from each key and section
    for i = 1:numel(keys)
        key = keys{i};
        keyGroup = key(1); % Assuming the key starts with 'A' or 'C'
        groupNum = find(['A', 'C'] == keyGroup); % Convert 'A' or 'C' to a numeric group identifier
        
        sections = fieldnames(extendedStatisticsResults.(key));
        for j = 1:numel(sections)
            section = sections{j};
            if ismember(section, includedSections) && ...
               isfield(extendedStatisticsResults.(key).(section), 'normal')
                sectionIndex = find(strcmp(includedSections, section)); % Find the index of the section
                % Extract data for each statistic
                for s = 1:numel(statisticFields)
                    statField = statisticFields{s};
                    if isfield(extendedStatisticsResults.(key).(section).normal, statField)
                        data = extendedStatisticsResults.(key).(section).normal.(statField);
                        allData = [allData; data]; % Append data
                        groupNumbers = [groupNumbers; groupNum + (sectionIndex - 1) * 2]; % Create unique index for each group-section combination
                        sectionLabels = [sectionLabels; sectionIndex]; % Append section index for x-axis
                    end
                end
            end
        end
    end
    
    % Check if data exists to plot
    if ~isempty(allData)
        % Grouping data for boxplot
        figure;
        boxplot(allData, groupNumbers, 'Colors', [0 0 1; 1 0.5 0], 'factorgap', 1, 'labelverbosity', 'minor'); % Blue and Orange
        title('Comparison of Mean for Amblyopia and Control');
        ylabel('Mean');
        set(gca, 'XTick', 1.5:2:length(includedSections)*2, 'XTickLabel', includedSections); % Set explicit labels for x-axis centered between groups
        xlabel('Section');
        set(gca, 'XTickLabelRotation', 45);
        
        % Custom legend
        legend(findall(gca, 'Tag', 'Box'), legendInfo, 'Location', 'best', 'Box', 'off');
    else
        disp('No data available to plot.');
    end
end
