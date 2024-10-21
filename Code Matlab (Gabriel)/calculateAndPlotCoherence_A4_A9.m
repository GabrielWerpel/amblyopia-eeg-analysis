function coherenceResults = calculateAndPlotCoherence_A4_A9(segmentedData, spectraResults, window, noverlap, nfft)
    % Initialize the coherence results structure
    coherenceResults = struct;

    % Define the keys to compare
    key1 = 'A4';
    key2 = 'A9';

    % Extract data segments for A4 and A9 from spectraResults
    data1 = segmentedData.(key1);
    data2 = segmentedData.(key2);

    % Extract the EC spectra in dB
    EC1 = data1.EC;
    EC2 = data2.EC;

    % Smooth the EC data using a moving average
    EC1_smoothed = smoothdata(EC1, 'movmean', 50);
    EC2_smoothed = smoothdata(EC2, 'movmean', 50);

    % Extract sampling frequency from the original segmentedResults
    hdr = segmentedData.(key1).header;
    Fs = hdr.Fs;

    % Adjust NFFT to focus on 0-40 Hz
    max_freq = 40;
    nfft = min(nfft, floor(Fs / max_freq) * 2);

    % Initialize a figure for plotting coherence
    figure('Position', [0, 0, 1200, 600]);
    hold on;
    title(['Coherence between ', key1, ' and ', key2]);
    xlabel('Frequency (Hz)');
    ylabel('Coherence');
    grid on;

    % Calculate and plot coherence of A4 with itself
    [Cxy_self_1, f_self_1] = mscohere(EC1_smoothed, EC1_smoothed, window, noverlap, nfft, Fs);

    % Limit the frequency range to 0-40 Hz for plotting
    freq_range_self_1 = f_self_1 <= max_freq;
    f_limited_self_1 = f_self_1(freq_range_self_1);
    Cxy_limited_self_1 = Cxy_self_1(freq_range_self_1);

    % Store the coherence result for A4 with itself
    coherenceResults.(key1).(key1) = struct('frequency', f_limited_self_1, 'coherence', Cxy_limited_self_1);

    % Plot the coherence of A4 with itself on the second y-axis
    yyaxis right;
    plot(f_limited_self_1, smoothdata(Cxy_limited_self_1, 'movmean', 5), 'k', 'LineWidth', 2, 'DisplayName', ['Coherence with ', key1, ' (self)']);
    ylabel('Coherence (self)');
    ylim([0 1]);

    % Switch back to the first y-axis
    yyaxis left;

    % Calculate and plot coherence between A4 and A9
    [Cxy_1_2, f_1_2] = mscohere(EC1_smoothed, EC2_smoothed, window, noverlap, nfft, Fs);

    % Limit the frequency range to 0-40 Hz for plotting
    freq_range_1_2 = f_1_2 <= max_freq;
    f_limited_1_2 = f_1_2(freq_range_1_2);
    Cxy_limited_1_2 = Cxy_1_2(freq_range_1_2);

    % Store the coherence result between A4 and A9
    coherenceResults.(key1).(key2) = struct('frequency', f_limited_1_2, 'coherence', Cxy_limited_1_2);

    % Plot the coherence between A4 and A9
    plot(f_limited_1_2, smoothdata(Cxy_limited_1_2, 'movmean', 5), 'b', 'DisplayName', ['Coherence with ', key2]);

    % Add legend to the plot
    legend('show');
    hold off;

    % Plot spectra with magnitude on y-axis
    figure('Position', [0, 0, 1200, 600]);
    hold on;
    title(['Spectra Magnitude for ', key1, ' and ', key2]);
    xlabel('Frequency (Hz)');
    ylabel('Magnitude (dB)');
    grid on;

    % Plot spectra for A4 and A9
    freq_axis = spectraResults.(key1).freq_axis;
    plot(freq_axis, smoothdata(spectraResults.(key1).EC_spectrum_dB, 'movmean', 5), 'r', 'LineWidth', 1.5, 'DisplayName', [key1, ' EC Spectrum']);
    plot(freq_axis, smoothdata(spectraResults.(key2).EC_spectrum_dB, 'movmean', 5), 'g', 'LineWidth', 1.5, 'DisplayName', [key2, ' EC Spectrum']);
    
    xlim([0 max_freq]); % Limit x-axis to 0-40 Hz
    legend('show');
    hold off;

    % Plot spectra with magnitude on y-axis
    figure('Position', [0, 0, 1200, 600]);
    hold on;

    % Plot segmented data for A4 and A9
    plot(EC1, 'r', 'LineWidth', 1, 'DisplayName', [key1, ' EC']);
    plot(EC2, 'g', 'LineWidth', 1, 'DisplayName', [key2, ' EC']);
    plot(EC1_smoothed, 'k', 'LineWidth', 1.5, 'DisplayName', [key1, ' EC (Smoothed)']);
    plot(EC2_smoothed, 'b', 'LineWidth', 1.5, 'DisplayName', [key2, ' EC (Smoothed)']);
    xlim([0 4000]);
    legend('show');
    hold off;
end
