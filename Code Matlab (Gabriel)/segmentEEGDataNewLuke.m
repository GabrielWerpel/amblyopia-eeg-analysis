function segmentedData = segmentEEGDataNewLuke(results)
    % Read the cohort information from an Excel file
    cohortTable = readtable('Cohort.xlsx');
    % Segment Duration
    segment_duration = 10; %s

    % Initialize the segmented results structure
    segmentedData = struct;

    % Iterate through each field in the results structure
    fields = fieldnames(results);
    for i = 1:numel(fields)
        key = fields{i};
        
        % Access the data for O1, Oz, and O2
        data_O1 = results.(key).O1_data;
        data_Oz = results.(key).Oz_data;
        data_O2 = results.(key).O2_data;
        hdr = results.(key).header;

        % Find the matching row in the cohort table
        cohortRow = cohortTable(strcmp(cohortTable.Cohort, key), :);
        
        if isempty(cohortRow)
            error(['Cohort information not found for ', key]);
        end

        % Define the duration and sample rate
        samples_per_segment = segment_duration * hdr.Fs;

        % Initialize segments for each channel with zeros
        EC_O1 = zeros(samples_per_segment, 1);
        EO_O1 = zeros(samples_per_segment, 1);
        LC_O1 = zeros(samples_per_segment, 1);
        RC_O1 = zeros(samples_per_segment, 1);
        DEC_O1 = zeros(samples_per_segment, 1);
        NDEC_O1 = zeros(samples_per_segment, 1);
        
        EC_Oz = zeros(samples_per_segment, 1);
        EO_Oz = zeros(samples_per_segment, 1);
        LC_Oz = zeros(samples_per_segment, 1);
        RC_Oz = zeros(samples_per_segment, 1);
        DEC_Oz = zeros(samples_per_segment, 1);
        NDEC_Oz = zeros(samples_per_segment, 1);
        
        EC_O2 = zeros(samples_per_segment, 1);
        EO_O2 = zeros(samples_per_segment, 1);
        LC_O2 = zeros(samples_per_segment, 1);
        RC_O2 = zeros(samples_per_segment, 1);
        DEC_O2 = zeros(samples_per_segment, 1);
        NDEC_O2 = zeros(samples_per_segment, 1);

        % Fill segments for O1 channel
        if length(data_O1) >= samples_per_segment
            EC_O1 = data_O1(1:samples_per_segment);
            EC_Oz = data_Oz(1:samples_per_segment);
            EC_O2 = data_O2(1:samples_per_segment);
        end
        if length(data_O1) >= 2 * samples_per_segment
            EO_O1 = data_O1(samples_per_segment+1:2*samples_per_segment);
            EO_Oz = data_Oz(samples_per_segment+1:2*samples_per_segment);
            EO_O2 = data_O2(samples_per_segment+1:2*samples_per_segment);
        end
        if length(data_O1) >= 3 * samples_per_segment
            LC_O1 = data_O1(2*samples_per_segment+1:3*samples_per_segment);
            LC_Oz = data_Oz(2*samples_per_segment+1:3*samples_per_segment);
            LC_O2 = data_O2(2*samples_per_segment+1:3*samples_per_segment);
        end
        if length(data_O1) >= 4 * samples_per_segment
            RC_O1 = data_O1(3*samples_per_segment+1:4*samples_per_segment);
            RC_Oz = data_Oz(3*samples_per_segment+1:4*samples_per_segment);
            RC_O2 = data_O2(3*samples_per_segment+1:4*samples_per_segment);
        end

        % Apply conditions based on cohort table
        if strcmp(cohortRow.LC, 'DEC')
            % Swap 'LC' with 'DEC' condition if applicable
            DEC_O1 = LC_O1;
            DEC_Oz = LC_Oz;
            DEC_O2 = LC_O2;
            NDEC_O1 = RC_O1;
            NDEC_Oz = RC_Oz;
            NDEC_O2 = RC_O2;
        end
        if strcmp(cohortRow.RC, 'DEC')
            % Apply 'DEC' condition to 'RC'
            DEC_O1 = RC_O1;
            DEC_Oz = RC_Oz;
            DEC_O2 = RC_O2;
            NDEC_O1 = LC_O1;
            NDEC_Oz = LC_Oz;
            NDEC_O2 = LC_O2;
        end

        % Store the segmented data in the results structure
        segmentedData.(key) = struct('header', hdr, ...
                                     'O1', struct('EC', EC_O1, 'EO', EO_O1, 'DEC', DEC_O1, 'NDEC', NDEC_O1), ...
                                     'Oz', struct('EC', EC_Oz, 'EO', EO_Oz, 'DEC', DEC_Oz, 'NDEC', NDEC_Oz), ...
                                     'O2', struct('EC', EC_O2, 'EO', EO_O2, 'DEC', DEC_O2, 'NDEC', NDEC_O2), ...
                                     'LinesDifference', cohortRow.LinesDifference);
    end
end
