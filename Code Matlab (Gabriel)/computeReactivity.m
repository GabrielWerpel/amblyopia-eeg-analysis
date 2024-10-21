function reactivityResults = computeReactivity(spectraResults)
    % Initialize the reactivity results structure
    reactivityResults = struct;

    % Iterate through each field in the spectra results structure
    fields = fieldnames(spectraResults);
    for i = 1:numel(fields)
        key = fields{i};
        data = spectraResults.(key);

        % Extract spectra and frequency axis
        freq_axis = data.freq_axis;
        EC_spectrum_dB = data.EC_spectrum_dB;
        EO_spectrum_dB = data.EO_spectrum_dB;
        DEC_spectrum_dB = data.DEC_spectrum_dB;
        NDEC_spectrum_dB = data.NDEC_spectrum_dB;

        % Define frequency range 8-12 Hz
        freq_range = freq_axis >= 8 & freq_axis <= 12;
        freq_range_indices = find(freq_range);

        % Process EC
        [max_EC, idx_EC] = max(EC_spectrum_dB(freq_range_indices));
        max_freq_EC = freq_axis(freq_range_indices(idx_EC));
        freq_half_range_EC = freq_axis >= (max_freq_EC - 0.5) & freq_axis <= (max_freq_EC + 0.5);
        freq_half_indices_EC = find(freq_half_range_EC);
        [max_EO_half_range_EC, idx_EO_EC] = max(EO_spectrum_dB(freq_half_indices_EC));
        max_freq_EO_EC = freq_axis(freq_half_indices_EC(idx_EO_EC));
        reactivity_EO_EC = max_EO_half_range_EC - max_EC;

        % Process DEC
        [max_DEC, idx_DEC] = max(DEC_spectrum_dB(freq_range_indices));
        max_freq_DEC = freq_axis(freq_range_indices(idx_DEC));
        freq_half_range_DEC = freq_axis >= (max_freq_DEC - 0.5) & freq_axis <= (max_freq_DEC + 0.5);
        freq_half_indices_DEC = find(freq_half_range_DEC);
        [max_EO_half_range_DEC, idx_EO_DEC] = max(EO_spectrum_dB(freq_half_indices_DEC));
        max_freq_EO_DEC = freq_axis(freq_half_indices_DEC(idx_EO_DEC));
        reactivity_EO_DEC = max_EO_half_range_DEC - max_DEC;

        % Process NDEC
        [max_NDEC, idx_NDEC] = max(NDEC_spectrum_dB(freq_range_indices));
        max_freq_NDEC = freq_axis(freq_range_indices(idx_NDEC));
        freq_half_range_NDEC = freq_axis >= (max_freq_NDEC - 0.5) & freq_axis <= (max_freq_NDEC + 0.5);
        freq_half_indices_NDEC = find(freq_half_range_NDEC);
        [max_EO_half_range_NDEC, idx_EO_NDEC] = max(EO_spectrum_dB(freq_half_indices_NDEC));
        max_freq_EO_NDEC = freq_axis(freq_half_indices_NDEC(idx_EO_NDEC));
        reactivity_EO_NDEC = max_EO_half_range_NDEC - max_NDEC;

        % Store the results in the reactivity results structure
        reactivityResults.(key) = struct('max_power_EC', max_EC, ...
                                         'max_freq_EC', max_freq_EC, ...
                                         'max_power_EO_EC', max_EO_half_range_EC, ...
                                         'max_freq_EO_EC', max_freq_EO_EC, ...
                                         'reactivity_EO_EC', reactivity_EO_EC, ...
                                         'max_power_DEC', max_DEC, ...
                                         'max_freq_DEC', max_freq_DEC, ...
                                         'max_power_EO_DEC', max_EO_half_range_DEC, ...
                                         'max_freq_EO_DEC', max_freq_EO_DEC, ...
                                         'reactivity_EO_DEC', reactivity_EO_DEC, ...
                                         'max_power_NDEC', max_NDEC, ...
                                         'max_freq_NDEC', max_freq_NDEC, ...
                                         'max_power_EO_NDEC', max_EO_half_range_NDEC, ...
                                         'max_freq_EO_NDEC', max_freq_EO_NDEC, ...
                                         'reactivity_EO_NDEC', reactivity_EO_NDEC);

        % Store and display the results
        fprintf('Key: %s\n', key);
        fprintf('Max Power EC: %.2f dB at %.1f Hz\n', max_EC, max_freq_EC);
        fprintf('Max Power EO: %.2f dB at %.1f Hz\n', max_EO_half_range_EC, max_freq_EO_EC);
        fprintf('--- Reactivity EO-EC: %.2f dB ---\n', reactivity_EO_EC);

        fprintf('Max Power DEC: %.2f dB at %.1f Hz\n', max_DEC, max_freq_DEC);
        fprintf('Max Power EO: %.2f dB at %.1f Hz\n', max_EO_half_range_DEC, max_freq_EO_DEC);
        fprintf('--- Reactivity EO-DEC: %.2f dB ---\n', reactivity_EO_DEC);

        fprintf('Max Power NDEC: %.2f dB at %.1f Hz\n', max_NDEC, max_freq_NDEC);
        fprintf('Max Power EO: %.2f dB at %.1f Hz\n', max_EO_half_range_NDEC, max_freq_EO_NDEC);
        fprintf('--- Reactivity EO-NDEC: %.2f dB ---\n', reactivity_EO_NDEC);
        fprintf('\n');
    end
end
