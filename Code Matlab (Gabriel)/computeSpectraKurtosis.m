function kurtosisResults = computeSpectraKurtosis(spectraResults)
    % Initialize the kurtosis results structure
    kurtosisResults = struct;

    % Frequency range limits
    freq_range_0_40 = [0 40];
    freq_range_8_12 = [8 12];

    % Iterate through each field in the spectra results structure
    fields = fieldnames(spectraResults);
    for i = 1:numel(fields)
        key = fields{i};
        data = spectraResults.(key);

        % Extract frequency axis and spectra in dB
        freq_axis = data.freq_axis;
        EC_spectrum_dB = data.EC_spectrum_dB;
        DEC_spectrum_dB = data.DEC_spectrum_dB;
        NDEC_spectrum_dB = data.NDEC_spectrum_dB;
        EO_spectrum_dB = data.EO_spectrum_dB;

        % Indices for the specified frequency ranges
        indices_0_40 = find(freq_axis >= freq_range_0_40(1) & freq_axis <= freq_range_0_40(2));
        indices_8_12 = find(freq_axis >= freq_range_8_12(1) & freq_axis <= freq_range_8_12(2));

        % Calculate kurtosis for the specified frequency ranges
        kurtosis_0_40.EC = kurtosis(EC_spectrum_dB(indices_0_40));
        kurtosis_0_40.DEC = kurtosis(DEC_spectrum_dB(indices_0_40));
        kurtosis_0_40.NDEC = kurtosis(NDEC_spectrum_dB(indices_0_40));
        kurtosis_0_40.EO = kurtosis(EO_spectrum_dB(indices_0_40));

        kurtosis_8_12.EC = kurtosis(EC_spectrum_dB(indices_8_12));
        kurtosis_8_12.DEC = kurtosis(DEC_spectrum_dB(indices_8_12));
        kurtosis_8_12.NDEC = kurtosis(NDEC_spectrum_dB(indices_8_12));
        kurtosis_8_12.EO = kurtosis(EO_spectrum_dB(indices_8_12));

        % Store the kurtosis results in the structure
        kurtosisResults.(key) = struct('kurtosis_0_40', kurtosis_0_40, ...
                                       'kurtosis_8_12', kurtosis_8_12);

        % Distinguish between Amblyopia and Control groups
        if startsWith(key, 'A')
            kurtosisResults.(key).group = 'Amblyopia';
        elseif startsWith(key, 'C')
            kurtosisResults.(key).group = 'Control';
        else
            kurtosisResults.(key).group = 'Unknown';
        end
    end
end
