function spectraResults = plotAndComputeFourierSpectraBandwidth(segmentedResults)
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

        % Extract data segments and the header
        EO = data.EO;
        EC = data.EC;
        DEC = data.DEC;
        NDEC = data.NDEC;
        hdr = data.header;

        % Calculate the Fourier spectrum for each condition
        N = length(EO); % Length of each segment
        spectra = struct('EO', EO, 'EC', EC, 'DEC', DEC, 'NDEC', NDEC);
        dB_spectra = struct;

        % Define frequency axis for the first half of the spectrum
        freq_axis = linspace(0, hdr.Fs/2, floor(N/2)+1);

        % Process each condition
        conditions = fieldnames(spectra);
        for j = 1:length(conditions)
            cond = conditions{j};
            spectrum = abs(fft(spectra.(cond), N)) / N;
            spectrum_half = spectrum(1:floor(N/2)+1);
            spectrum_dB = 20 * log10(spectrum_half);
            spectrum_dB(spectrum_half == 0) = min(spectrum_dB(spectrum_dB > -inf)); % Handle log of zero

            % Smooth the spectrum using a moving average of 5
            smoothed_spectrum_dB = smoothdata(spectrum_dB, 'movmean', 5);
            dB_spectra.(cond) = smoothed_spectrum_dB;

            % Create separate plot for each condition
            figure('Position', [100, 100, 1200, 600]); % Adjust figure position and size
            plot(freq_axis, smoothed_spectrum_dB, 'k', 'DisplayName', cond); % Plotting the smoothed spectrum
            xlabel('Frequency (Hz)');
            ylabel('Magnitude (dB)');
            title(['Fourier Spectrum of ' cond ' (Smoothed) - ' key]);
            xlim(x_axis_limits);
            ylim(y_axis_limits);
            grid on;
            legend(['Smoothed ' cond], 'Location', 'northeast');
        end

        % Store the spectra and frequencies in the results structure
        spectraResults.(key) = struct('freq_axis', freq_axis, ...
                                      'EO_spectrum_dB', dB_spectra.EO, ...
                                      'EC_spectrum_dB', dB_spectra.EC, ...
                                      'DEC_spectrum_dB', dB_spectra.DEC, ...
                                      'NDEC_spectrum_dB', dB_spectra.NDEC);
    end
end
