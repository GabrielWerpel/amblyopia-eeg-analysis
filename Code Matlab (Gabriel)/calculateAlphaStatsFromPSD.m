function alphaStatsResults = calculateAlphaStatsFromPSD(psdResults)
    % Initialize the alpha statistics results structure
    alphaStatsResults = struct;

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

        % Define alpha band range 8-12 Hz
        alpha_range = freq_axis >= 8 & freq_axis <= 12;

        % Extract the alpha band PSDs
        BE_Closed_alpha = BE_Closed_psd(alpha_range);
        BE_Open_alpha = BE_Open_psd(alpha_range);
        LE_Closed_alpha = LE_Closed_psd(alpha_range);
        RE_Closed_alpha = RE_Closed_psd(alpha_range);

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