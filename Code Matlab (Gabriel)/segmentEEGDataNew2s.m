function segmentedData = segmentEEGDataNew2s(results)
    % Read the cohort information from an Excel file
    cohortTable = readtable('Cohort.xlsx');
    % Segment Duration
    segment_duration = 10; %s
    remove_duration = 2; %s
    % Initialize the segmented results structure
    segmentedData = struct;

    % Iterate through each field in the results structure
    fields = fieldnames(results);
    for i = 1:numel(fields)
        key = fields{i};
        data = results.(key).data;
        hdr = results.(key).header;

        % Find the matching row in the cohort table
        cohortRow = cohortTable(strcmp(cohortTable.Cohort, key), :);
        
        if isempty(cohortRow)
            error(['Cohort information not found for ', key]);
        end

        % Define the duration and sample rate
        samples_per_segment = segment_duration * hdr.Fs;
        samples_to_remove = remove_duration * hdr.Fs;

        % Initialize segments with zeros
        EC = zeros(samples_per_segment- samples_to_remove, 1);
        EO = zeros(samples_per_segment - samples_to_remove, 1);
        LC = zeros(samples_per_segment - samples_to_remove, 1);
        RC = zeros(samples_per_segment - samples_to_remove, 1);
        DEC = zeros(samples_per_segment - samples_to_remove, 1);
        NDEC = zeros(samples_per_segment - samples_to_remove, 1);

        % Fill segments with data if available
        if length(data) >= samples_per_segment
            EC = data(samples_to_remove + 1:samples_per_segment);
        end
        if length(data) >= 2 * samples_per_segment
            EO = data(samples_per_segment + samples_to_remove + 1:2*samples_per_segment);
        end
        if length(data) >= 3 * samples_per_segment
            LC = data(2*samples_per_segment + samples_to_remove + 1:3*samples_per_segment);
        end
        if length(data) >= 4 * samples_per_segment
            RC = data(3*samples_per_segment + samples_to_remove + 1:4*samples_per_segment);
        end

        % Apply conditions based on cohort table
        if strcmp(cohortRow.LC, 'DEC')
            % Swap 'LC' with 'DEC' condition if applicable
            DEC = LC;
            NDEC = RC;
        end
        if strcmp(cohortRow.RC, 'DEC')
            % Apply 'DEC' condition to 'RC'
            DEC = RC;
            NDEC = LC;
        end

        % Store the segmented data and 'Lines Differences' in the results structure
        segmentedData.(key) = struct('header', hdr, 'EC', EC, 'EO', EO, 'DEC', DEC, 'NDEC', NDEC, 'LinesDifference', cohortRow.LinesDifference);
    end
end
