function segmentedData = segmentEEGData(results)
    
    %Segment Duration
    segment_duration = 10; %s

    % Initialize the segmented results structure
    segmentedData = struct;

    % Clear potential variable conflicts
    clear data;
    
    % Iterate through each field in the results structure
    fields = fieldnames(results);
    for i = 1:numel(fields)
        key = fields{i};
        data = results.(key).data;
        hdr = results.(key).header;

        % Define the duration and sample rate
        samples_per_segment = segment_duration * hdr.Fs;

        % Initialize segments with zeros
        EC = zeros(samples_per_segment, 1);
        EO = zeros(samples_per_segment, 1);
        LC = zeros(samples_per_segment, 1);
        RC = zeros(samples_per_segment, 1);

        % Fill segments with data if available
        if length(data) >= samples_per_segment
            EC = data(1:samples_per_segment);
        end
        if length(data) >= 2 * samples_per_segment
            EO = data(samples_per_segment+1:2*samples_per_segment);
        end
        if length(data) >= 3 * samples_per_segment
            LC = data(2*samples_per_segment+1:3*samples_per_segment);
        end
        if length(data) >= 4 * samples_per_segment
            RC = data(3*samples_per_segment+1:4*samples_per_segment);
        end

        % Store the segmented data in the results structure
        segmentedData.(key) = struct('header', hdr, 'EC', EC, 'EO', EO, 'LC', LC, 'RC', RC);
    end
end