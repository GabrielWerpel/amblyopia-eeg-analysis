function alphaStatsResults = calculateAlphaStats(spectraResults)
    % Initialize the alpha statistics results structure
    alphaStatsResults = struct;

    % Iterate through each field in the spectra results structure
    fields = fieldnames(spectraResults);
    for i = 1:numel(fields)
        key = fields{i};
        data = spectraResults.(key);

        % Extract frequency axis and spectra
        freq_axis = data.freq_axis;
        BE_Closed_spectrum_dB = data.BE_Closed_spectrum_dB;
        BE_Open_spectrum_dB = data.BE_Open_spectrum_dB;
        LE_Closed_spectrum_dB = data.LE_Closed_spectrum_dB;
        RE_Closed_spectrum_dB = data.RE_Closed_spectrum_dB;

        % Define alpha band range 8-12 Hz
        alpha_range = freq_axis >= 8 & freq_axis <= 12;
        alpha_freqs = freq_axis(alpha_range);

        % Extract the alpha band spectra
        BE_Closed_alpha = BE_Closed_spectrum_dB(alpha_range);
        BE_Open_alpha = BE_Open_spectrum_dB(alpha_range);
        LE_Closed_alpha = LE_Closed_spectrum_dB(alpha_range);
        RE_Closed_alpha = RE_Closed_spectrum_dB(alpha_range);

        % Calculate skewness and kurtosis
        skewness_BE_Closed = skewness(BE_Closed_alpha);
        kurtosis_BE_Closed = kurtosis(BE_Closed_alpha);
        skewness_BE_Open = skewness(BE_Open_alpha);
        kurtosis_BE_Open = kurtosis(BE_Open_alpha);
        skewness_LE_Closed = skewness(LE_Closed_alpha);
        kurtosis_LE_Closed = kurtosis(LE_Closed_alpha);
        skewness_RE_Closed = skewness(RE_Closed_alpha);
        kurtosis_RE_Closed = kurtosis(RE_Closed_alpha);

        % Store the results in the alpha statistics results structure
        alphaStatsResults.(key) = struct('skewness_BE_Closed', skewness_BE_Closed, ...
                                         'kurtosis_BE_Closed', kurtosis_BE_Closed, ...
                                         'skewness_BE_Open', skewness_BE_Open, ...
                                         'kurtosis_BE_Open', kurtosis_BE_Open, ...
                                         'skewness_LE_Closed', skewness_LE_Closed, ...
                                         'kurtosis_LE_Closed', kurtosis_LE_Closed, ...
                                         'skewness_RE_Closed', skewness_RE_Closed, ...
                                         'kurtosis_RE_Closed', kurtosis_RE_Closed);

        % Display the results
        fprintf('Key: %s\n', key);
        fprintf('Skewness and Kurtosis for BE_Closed alpha band:\n');
        fprintf('Skewness: %f, Kurtosis: %f\n', skewness_BE_Closed, kurtosis_BE_Closed);
        fprintf('Skewness and Kurtosis for BE_Open alpha band:\n');
        fprintf('Skewness: %f, Kurtosis: %f\n', skewness_BE_Open, kurtosis_BE_Open);
        fprintf('Skewness and Kurtosis for LE_Closed alpha band:\n');
        fprintf('Skewness: %f, Kurtosis: %f\n', skewness_LE_Closed, kurtosis_LE_Closed);
        fprintf('Skewness and Kurtosis for RE_Closed alpha band:\n');
        fprintf('Skewness: %f, Kurtosis: %f\n', skewness_RE_Closed, kurtosis_RE_Closed);
        fprintf('\n');
    end
end