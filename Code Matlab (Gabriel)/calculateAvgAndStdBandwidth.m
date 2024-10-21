function [avgBandwidth, stdBandwidth] = calculateAvgAndStdBandwidth(bandwidthResults)
    % Initialize arrays to store all bandwidth values
    allBandwidths = [];

    % Iterate through each key in the bandwidth results
    fields = fieldnames(bandwidthResults);
    for i = 1:numel(fields)
        key = fields{i};

        % Iterate through each condition (EO, EC, DEC, NDEC)
        conditions = {'EO', 'EC', 'DEC', 'NDEC'};
        for cond = conditions
            condition = cond{1};
            bandwidth = bandwidthResults.(key).(condition).bandwidth;

            % Only include valid (non-NaN) bandwidths in the calculation
            if ~isnan(bandwidth)
                allBandwidths = [allBandwidths, bandwidth];
            end
        end
    end

    % Calculate the average and standard deviation of the bandwidths
    avgBandwidth = mean(allBandwidths);
    stdBandwidth = std(allBandwidths);

    % Display the results
    fprintf('Average Bandwidth: %.2f Hz\n', avgBandwidth);
    fprintf('Standard Deviation of Bandwidth: %.2f Hz\n', stdBandwidth);
end
