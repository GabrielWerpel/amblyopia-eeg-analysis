function psdResults = computeAndPlotPSD(segmentedResults, window, noverlap, nfft)
    % Initialize the PSD results structure
    psdResults = struct;

    % Iterate through each field in the segmented results structure
    fields = fieldnames(segmentedResults);
    for i = 1:numel(fields)
        key = fields{i};
        data = segmentedResults.(key);

        % Extract BE_Closed data segment
        BE_Closed = data.BE_Closed;
        hdr = data.header;

        % Initialize a figure for plotting PSD
        figure('Position', [0, 0, 1200, 600]);
        hold on;
        title(['PSD of BE_Closed for ', key]);
        xlabel('Frequency (Hz)');
        ylabel('Power/Frequency (dB/Hz)');
        grid on;

        % Calculate PSD using Welch's method for BE_Closed
        [Pxx_BE_Closed, f] = pwelch(BE_Closed, window, noverlap, nfft, hdr.Fs);

        % Convert power to dB
        Pxx_BE_Closed_dB = 10 * log10(Pxx_BE_Closed);

        % Limit the frequency range to 0-40 Hz
        freq_range = f >= 0 & f <= 40;
        f_limited = f(freq_range);
        Pxx_BE_Closed_limited = Pxx_BE_Closed_dB(freq_range);

        % Store the PSD result
        psdResults.(key).BE_Closed = struct('frequency', f_limited, 'psd', Pxx_BE_Closed_limited);

        % Plot the PSD
        plot(f_limited, Pxx_BE_Closed_limited, 'DisplayName', 'BE_Closed');
        
        % Repeat the process for BE_Open, LE_Closed, and RE_Closed
        segments = {'BE_Open', 'LE_Closed', 'RE_Closed'};
        for j = 1:numel(segments)
            segment = segments{j};
            segment_data = data.(segment);

            % Calculate PSD using Welch's method
            [Pxx, f] = pwelch(segment_data, window, noverlap, nfft, hdr.Fs);

            % Convert power to dB
            Pxx_dB = 10 * log10(Pxx);

            % Limit the frequency range to 0-40 Hz
            Pxx_limited = Pxx_dB(freq_range);

            % Store the PSD result
            psdResults.(key).(segment) = struct('frequency', f_limited, 'psd', Pxx_limited);

            % Plot the PSD
            plot(f_limited, Pxx_limited, 'DisplayName', segment);
        end

        % Add legend to the plot
        legend('show');
        hold off;
    end
end
