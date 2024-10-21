function bandwidthResults = computeBandwidth(spectraResults, dB_drop)
    % Initialize the bandwidth results structure
    bandwidthResults = struct;

    % Iterate through each field in the spectra results structure
    fields = fieldnames(spectraResults);
    for i = 1:numel(fields)
        key = fields{i};
        data = spectraResults.(key);

        % Extract spectra and frequency axis
        freq_axis = data.freq_axis;
        BE_Closed_spectrum_dB = data.BE_Closed_spectrum_dB;

        % Define frequency range 0-40 Hz
        freq_range = freq_axis >= 0 & freq_axis <= 40;
        freq_range_indices = find(freq_range);

        % Calculate the power in dB for the Closed condition within the alpha range
        power_BE_Closed_dB = BE_Closed_spectrum_dB(freq_range_indices);

        % Find the maximum power and corresponding frequency within 8-12 Hz range for BE_Closed
        freq_range_8_12 = freq_axis >= 8 & freq_axis <= 12;
        freq_range_indices_8_12 = find(freq_range_8_12);
        
        [max_BE_Closed, idx_closed] = max(BE_Closed_spectrum_dB(freq_range_indices_8_12));
        max_freq_closed = freq_axis(freq_range_indices_8_12(idx_closed));

        % Get the dB value 3 dB below the maximum power for the Closed condition
        target_dB_closed = max_BE_Closed - dB_drop;

        % Find the frequencies at -3dB points for Both Eyes Closed
        idx_closed_in_range = find(freq_range_indices == freq_range_indices_8_12(idx_closed));
        left_idx_closed = find(power_BE_Closed_dB(1:idx_closed_in_range) <= target_dB_closed, 1, 'last');
        right_idx_closed = find(power_BE_Closed_dB(idx_closed_in_range:end) <= target_dB_closed, 1, 'first') + idx_closed_in_range - 1;

        % Handle cases where the -3dB points are not found
        if isempty(left_idx_closed)
            left_freq_closed = freq_axis(freq_range_indices(1));
        else
            left_freq_closed = freq_axis(freq_range_indices(left_idx_closed));
        end

        if isempty(right_idx_closed)
            right_freq_closed = freq_axis(freq_range_indices(end));
        else
            right_freq_closed = freq_axis(freq_range_indices(right_idx_closed));
        end

        % Calculate bandwidth for the Closed condition
        bandwidth_closed = right_freq_closed - left_freq_closed;

        % Store the results in the bandwidth results structure
        bandwidthResults.(key) = struct('max_freq_closed', max_freq_closed, ...
                                        'bandwidth_closed', bandwidth_closed, ...
                                        'left_freq_closed', left_freq_closed, ...
                                        'right_freq_closed', right_freq_closed);

        % Display the results
        fprintf('Key: %s\n', key);
        fprintf('Bandwidth for BE_Closed around %f Hz: %f Hz (%f Hz to %f Hz)\n', max_freq_closed, bandwidth_closed, left_freq_closed, right_freq_closed);
        fprintf('\n');
    end
end