function bandwidthResults = calculateBandwidth(spectraResults)
    % Initialize the bandwidth results structure
    bandwidthResults = struct;

    % Iterate through each key in the spectra results
    fields = fieldnames(spectraResults);
    for i = 1:numel(fields)
        key = fields{i};
        freq_axis = spectraResults.(key).freq_axis;
        
        % Initialize a sub-structure for storing results for each condition
        conditionResults = struct;
        
        % Iterate through each condition (EO, EC, DEC, NDEC)
        conditions = {'EO', 'EC', 'DEC', 'NDEC'};
        for cond = conditions
            condition = cond{1};
            spectrum_dB = spectraResults.(key).([condition '_spectrum_dB']);

            % Find indices for the 8-12 Hz range
            idx_range = freq_axis >= 8 & freq_axis <= 12;

            % Extract the frequency and dB values in this range
            freq_range = freq_axis(idx_range);
            dB_range = spectrum_dB(idx_range);

            % Find the peak within the 8-12 Hz range
            [peak_dB, peak_idx] = max(dB_range);
            peak_freq = freq_range(peak_idx);

            % Calculate the -3 dB point
            target_dB = peak_dB - 3;

            % Find frequencies where the spectrum crosses this target level
            below_peak_indices = find(dB_range(1:peak_idx) <= target_dB, 1, 'last');
            above_peak_indices = find(dB_range(peak_idx:end) <= target_dB, 1, 'first') + (peak_idx-1);

            if isempty(below_peak_indices) || isempty(above_peak_indices)
                bandwidth = NaN; % Handle cases where the spectrum does not cross the -3 dB point
                lower_freq = NaN;
                upper_freq = NaN;
            else
                lower_freq = freq_range(below_peak_indices);
                upper_freq = freq_range(above_peak_indices);
                bandwidth = upper_freq - lower_freq;
            end

            % Store results in a sub-structure for this condition
            conditionResults.(condition) = struct('peak_frequency', peak_freq, ...
                                                  'bandwidth', bandwidth, ...
                                                  'lower_freq', lower_freq, ...
                                                  'upper_freq', upper_freq);
            fprintf('Key: %s, Condition: %s\n', key, condition);
            fprintf('Peak Frequency: %.2f Hz\n', peak_freq);
            fprintf('Bandwidth: %.2f Hz (from %.2f Hz to %.2f Hz)\n', bandwidth, lower_freq, upper_freq);
            fprintf('--------------------------------------\n');
        end
        
        % Store all condition results under this key
        bandwidthResults.(key) = conditionResults;
    end
end
