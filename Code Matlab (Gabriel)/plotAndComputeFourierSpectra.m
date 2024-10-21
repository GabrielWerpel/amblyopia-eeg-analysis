function spectraResults = plotAndComputeFourierSpectra(segmentedResults)
    % Define axis limits
    x_axis_limits = [0 40]; % Frequency axis limits (Hz)
    y_axis_limits = [-20 20]; % Magnitude axis limits (dB)

    % Initialize the spectra results structure
    spectraResults = struct;

    % Iterate through each field in the segmented results structure
    fields = fieldnames(segmentedResults);
    for i = 1:numel(fields)
        key = fields{i};
        data = segmentedResults.(key);

        % Extract data segments
        EC = data.EC;
        EO = data.EO;
        DEC = data.DEC;
        NDEC = data.NDEC;
        hdr = data.header;

        % Calculate the Fourier spectrum for each segment
        N = length(EC); % Length of each segment
        EC_spectrum = abs(fft(EC, N)) / N;
        EO_spectrum = abs(fft(EO, N)) / N;
        DEC_spectrum = abs(fft(DEC, N)) / N;
        NDEC_spectrum = abs(fft(NDEC, N)) / N;

        % Convert magnitude to decibels (dB)
        EC_spectrum_dB = 20 * log10(EC_spectrum);
        EO_spectrum_dB = 20 * log10(EO_spectrum);
        DEC_spectrum_dB = 20 * log10(DEC_spectrum);
        NDEC_spectrum_dB = 20 * log10(NDEC_spectrum);

        % Define frequency axis
        freq_axis = linspace(0, hdr.Fs, N);

        % Store the spectra and frequencies in the results structure
        spectraResults.(key) = struct('freq_axis', freq_axis, ...
                                      'EC_spectrum_dB', EC_spectrum_dB, ...
                                      'EO_spectrum_dB', EO_spectrum_dB, ...
                                      'DEC_spectrum_dB', DEC_spectrum_dB, ...
                                      'NDEC_spectrum_dB', NDEC_spectrum_dB);

        % Create separate plots
        lineTypes = {'-', '--', '-.', ':'};
        plotData = {EC, DEC, NDEC};
        plotTitles = {'Both Eyes Closed', 'Dominant Eye Closed', 'Non-Dominant Eye Closed'};
        
        for j = 1:3
            figure('Position', [0, 0, 1200, 600]);
            smoothEO = smoothdata(EO_spectrum_dB, 'movmean', 5);
            plot(freq_axis, smoothEO, 'k', 'DisplayName', 'Both Eyes Open', 'LineStyle', lineTypes{4});
            hold on;
            smoothOther = smoothdata(20 * log10(abs(fft(plotData{j}, N)) / N), 'movmean', 5);
            plot(freq_axis, smoothOther, 'k', 'DisplayName', plotTitles{j}, 'LineStyle', lineTypes{1});
            xlabel('Frequency (Hz)');
            ylabel('Magnitude (dB)');
            title([plotTitles{j} ' vs Both Eyes Open - ' key]);
            xlim(x_axis_limits);
            ylim(y_axis_limits);
            grid on;
            legend('Location', 'northeast');
            hold off;
        end
    end
end
