function analyzeECMaxPeaks(segmentedData)
    % Get all field names in the segmentedData structure
    fields = fieldnames(segmentedData);

    % Iterate through each field in the segmentedData structure
    for i = 1:numel(fields)
        key = fields{i};
        data = segmentedData.(key);
        hdr = data.header;
        
        % Extract the EC segment
        EC = data.EC;

        % Determine the number of samples for 1 second
        samples_per_second = hdr.Fs;

        % Limit the data to the first second
        EC = EC(1:samples_per_second);

        % Find the 10 maximum peaks
        [pks, locs] = findpeaks(EC, 'NPeaks', 10, 'SortStr', 'descend');

        % Sort peaks based on their location (time order)
        [locs, idx] = sort(locs);
        pks = pks(idx);

        % Calculate the distances between consecutive peaks
        distances = diff(locs);

        % Calculate the average distance
        avg_distance = mean(distances);

        % Display results
        fprintf('Results for %s:\n', key);
        fprintf('Peak Locations: %s\n', num2str(locs));
        fprintf('Peak Values: %s\n', num2str(pks));
        fprintf('Distances between Peaks: %s\n', num2str(distances));
        fprintf('Average Distance between Peaks: %.2f samples\n', avg_distance);
        
        % Plot the EC segment and mark the peaks
        figure;
        plot(EC);
        hold on;
        plot(locs, EC(locs), 'r^', 'MarkerFaceColor', 'r');
        title([key ' - EC Segment with Peaks']);
        xlabel('Samples');
        ylabel('Amplitude');
        legend('EC Signal', 'Peaks');
        hold off;
    end
end
