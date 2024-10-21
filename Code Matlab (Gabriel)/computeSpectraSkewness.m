function skewnessResults = computeSpectraSkewness(spectraResults)
    % Initialize the skewness results structure
    skewnessResults = struct;

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

        % Calculate skewness for the specified frequency ranges
        skewness_0_40.EC = skewness(EC_spectrum_dB(indices_0_40));
        skewness_0_40.DEC = skewness(DEC_spectrum_dB(indices_0_40));
        skewness_0_40.NDEC = skewness(NDEC_spectrum_dB(indices_0_40));
        skewness_0_40.EO = skewness(EO_spectrum_dB(indices_0_40));

        skewness_8_12.EC = skewness(EC_spectrum_dB(indices_8_12));
        skewness_8_12.DEC = skewness(DEC_spectrum_dB(indices_8_12));
        skewness_8_12.NDEC = skewness(NDEC_spectrum_dB(indices_8_12));
        skewness_8_12.EO = skewness(EO_spectrum_dB(indices_8_12));

        % Store the skewness results in the structure
        skewnessResults.(key) = struct('skewness_0_40', skewness_0_40, ...
                                       'skewness_8_12', skewness_8_12);

        % Distinguish between Amblyopia and Control groups
        if startsWith(key, 'A')
            skewnessResults.(key).group = 'Amblyopia';
        elseif startsWith(key, 'C')
            skewnessResults.(key).group = 'Control';
        else
            skewnessResults.(key).group = 'Unknown';
        end
    end
end
