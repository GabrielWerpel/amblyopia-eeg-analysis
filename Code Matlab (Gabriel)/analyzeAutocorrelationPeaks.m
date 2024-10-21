function analyzeAutocorrelationPeaks(segmentedData)
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

        % Compute the autocorrelation for the EC segment
        acEC = xcorr(EC, 'coeff');

        % Find the 10 maximum peaks in the autocorrelation
        [pks, locs] = findpeaks(acEC, 'NPeaks', 10, 'SortStr', 'descend');

        % Sort peaks based on their location (time order)
        [locs, idx] = sort(locs);
        pks = pks(idx);

        % Calculate the distances between consecutive peaks
        distances = diff(locs);

        % Calculate the average distance
        avg_distance = mean(distances);

        % Estimate the decay rate using exponential fitting, if enough peaks are found
        if length(pks) > 2
            % Using log transform for linear fit
            log_pks = log(pks);
            fit_result = polyfit(1:length(pks), log_pks, 1);
            decay_rate = fit_result(1); % The slope represents the decay rate in the log domain
        else
            decay_rate = NaN; % Not enough peaks to estimate decay rate
        end

        % Display results
        fprintf('Results for %s:\n', key);
        fprintf('Peak Locations: %s\n', num2str(locs));
        fprintf('Peak Values: %s\n', num2str(pks));
        fprintf('Distances between Peaks: %s\n', num2str(distances));
        fprintf('Average Distance between Peaks: %.2f samples\n', avg_distance);
        fprintf('Decay Rate of Peak Values: %.4f\n', decay_rate);
        
        % Plot the autocorrelation and mark the peaks
        figure;
        plot(acEC);
        hold on;
        plot(locs, acEC(locs), 'r^', 'MarkerFaceColor', 'r');
        title([key ' - Autocorrelation of EC Segment with Peaks']);
        xlabel('Lag');
        ylabel('Autocorrelation');
        ylim([-1 1]);
        legend('Autocorrelation', 'Peaks');
        hold off;
    end
end
