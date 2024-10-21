function participantMatrices = createParticipantMatrices(segmentedData, channel)
    % Sample rate in Hz
    sample_rate = 2048; % samples/second
    segment_duration = 10; % seconds

    % Number of samples in a 10-second segment
    num_samples = segment_duration * sample_rate;

    % Initialize the output structure to hold matrices for each participant
    participantMatrices = struct;

    % Ensure valid channel input ('Oz', 'O1', or 'O2')
    if ~ismember(channel, {'Oz', 'O1', 'O2'})
        error('Invalid channel specified. Choose either ''Oz'', ''O1'', or ''O2''.');
    end

    % Iterate through each field (participant) in segmentedData
    fields = fieldnames(segmentedData);
    for i = 1:numel(fields)
        key = fields{i};
        participantData = segmentedData.(key);

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
            matrixName = strcat(key, '_', channel); % e.g., A1_Oz or A1_O1 or A1_O2
            participantMatrices.(matrixName) = participantMatrix;

            % Optionally, display a message confirming success
            disp(['Matrix created for participant ', key, ' (', channel, ')']);
        else
            warning(['No ', channel, ' data found for participant ', key]);
        end
    end
end
