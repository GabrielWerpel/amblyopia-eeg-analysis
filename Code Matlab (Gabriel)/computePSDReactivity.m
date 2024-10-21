function psdReactivityResults = computePSDReactivity(psdResults, dB_drop)
    % Initialize the PSD reactivity results structure
    psdReactivityResults = struct;

    % Iterate through each field in the PSD results structure
    fields = fieldnames(psdResults);
    for i = 1:numel(fields)
        key = fields{i};
        data = psdResults.(key);

        % Extract frequency axis and PSDs
        freq_axis = data.BE_Closed.frequency;
        BE_Closed_psd = data.BE_Closed.psd;
        BE_Open_psd = data.BE_Open.psd;
        LE_Closed_psd = data.LE_Closed.psd;
        RE_Closed_psd = data.RE_Closed.psd;

        % Define the frequency range 0-40 Hz
        freq_range = freq_axis >= 0 & freq_axis <= 40;
        freq_range_indices = find(freq_range);

        % Find the maximum power and corresponding frequency within 8-12 Hz range for BE_Closed
        freq_range_8_12 = freq_axis >= 8 & freq_axis <= 12;
        freq_range_indices_8_12 = find(freq_range_8_12);
        
        [max_BE_Closed, idx_closed] = max(BE_Closed_psd(freq_range_indices_8_12));
        max_freq_closed = freq_axis(freq_range_indices_8_12(idx_closed));

        % Find the maximum power and corresponding frequency within 8-12 Hz range for BE_Open
        [max_BE_Open, idx_open] = max(BE_Open_psd(freq_range_indices_8_12));
        max_freq_open = freq_axis(freq_range_indices_8_12(idx_open));

        % Use the same frequency to find power values for other segments
        power_at_max_freq_open = BE_Open_psd(freq_range_indices_8_12(idx_closed));
        power_at_max_freq_le_closed = LE_Closed_psd(freq_range_indices_8_12(idx_closed));
        power_at_max_freq_re_closed = RE_Closed_psd(freq_range_indices_8_12(idx_closed));

        % Reactivity calculation (Closed - Open)
        reactivity = max_BE_Closed - power_at_max_freq_open;

        % Difference between max closed eye and max open eye
        max_closed_open_diff = max_BE_Closed - max_BE_Open;

        % Store the results in the PSD reactivity results structure
        psdReactivityResults.(key) = struct('max_power_BE_Closed', max_BE_Closed, ...
                                            'max_freq_closed', max_freq_closed, ...
                                            'power_at_max_freq_open', power_at_max_freq_open, ...
                                            'power_at_max_freq_le_closed', power_at_max_freq_le_closed, ...
                                            'power_at_max_freq_re_closed', power_at_max_freq_re_closed, ...
                                            'reactivity', reactivity, ...
                                            'max_power_BE_Open', max_BE_Open, ...
                                            'max_freq_open', max_freq_open, ...
                                            'max_closed_open_diff', max_closed_open_diff);

        % Display the results
        fprintf('Key: %s\n', key);
        fprintf('Maximum Power in BE_Closed (8-12 Hz): %f dB/Hz at %f Hz\n', max_BE_Closed, max_freq_closed);
        fprintf('Power in BE_Open at %f Hz: %f dB/Hz\n', max_freq_closed, power_at_max_freq_open);
        fprintf('Power in LE_Closed at %f Hz: %f dB/Hz\n', max_freq_closed, power_at_max_freq_le_closed);
        fprintf('Power in RE_Closed at %f Hz: %f dB/Hz\n', max_freq_closed, power_at_max_freq_re_closed);
        fprintf('Reactivity (Closed - Open): %f dB/Hz\n', reactivity);
        fprintf('Maximum Power in BE_Open (8-12 Hz): %f dB/Hz at %f Hz\n', max_BE_Open, max_freq_open);
        fprintf('Difference between max BE_Closed and max BE_Open: %f dB/Hz\n', max_closed_open_diff);
        fprintf('\n');
    end
end