function saveParticipantMatricesAndSeverityAsMat(segmentedData, cohortFileName, outputFileName)
    % Sample rate in Hz
    sample_rate = 2048; % samples/second
    segment_duration = 10; % seconds

    % Number of samples in a 10-second segment
    num_samples = segment_duration * sample_rate;

    % Read the cohort information from the Excel file
    cohortTable = readtable(cohortFileName);

    % Initialize the output structure to hold matrices and severity for each participant
    dataToSave = struct;

    % List of channels to process
    channels = {'Oz', 'O1', 'O2'};

    % Iterate through each field (participant) in segmentedData
    fields = fieldnames(segmentedData);
    for i = 1:numel(fields)
        key = fields{i};
        participantData = segmentedData.(key);

        % Find the matching row in the cohort table for the participant
        cohortRow = cohortTable(strcmp(cohortTable.Cohort, key), :);
        
        if isempty(cohortRow)
            error(['Cohort information not found for participant ', key]);
        end

        % Extract the severity information from the cohort table
        severity = cohortRow.LinesDifference;

        % Store the severity for the participant
        dataToSave.(strcat(key, '_Severity')) = severity;

        % Iterate over each channel ('Oz', 'O1', 'O2')
        for j = 1:numel(channels)
            channel = channels{j};

            % Check if the specified channel data exists for this participant
            if isfield(participantData, channel)
                % Get the segmented data for the specified channel
                EC = participantData.(channel).EC;
                EO = participantData.(channel).EO;
                DEC = participantData.(channel).DEC;
                NDEC = participantData.(channel).NDEC;

                % Ensure each segment has the correct number of samples
                if length(EC) ~= num_samples || length(EO) ~= num_samples || ...
                   length(DEC) ~= num_samples || length(NDEC) ~= num_samples
                    error(['Segment length mismatch for participant ', key, ' on channel ', channel]);
                end

                % Create the matrix with 4 columns: [EC, EO, DEC, NDEC]
                participantMatrix = [EC, EO, DEC, NDEC];

                % Dynamically assign the matrix to the participant in the results structure
                matrixName = strcat(key, '_', channel); % e.g., A1_Oz, A1_O1, A1_O2
                dataToSave.(matrixName) = participantMatrix;

                % Optionally, display a message confirming success
                disp(['Matrix created for participant ', key, ' (', channel, ')']);
            else
                warning(['No ', channel, ' data found for participant ', key]);
            end
        end
    end

    % Save the combined data (matrices and severity list) to a .mat file
    save(outputFileName, '-struct', 'dataToSave');

    disp(['Matrices and severity list saved to ', outputFileName]);
end
