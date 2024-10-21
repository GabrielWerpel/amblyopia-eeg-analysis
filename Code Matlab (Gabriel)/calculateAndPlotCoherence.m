function coherenceResults = calculateAndPlotCoherence(segmentedResults, window, noverlap, nfft)
    % Initialize the coherence results structure
    coherenceResults = struct;

    % Iterate through each field in the segmented results structure
    fields = fieldnames(segmentedResults);
    for i = 1:numel(fields)
        key = fields{i};
        data = segmentedResults.(key);

        % Extract BE_Closed data segment
        EC = data.EC;
        hdr = data.header;

        % Initialize a figure for plotting coherence
        figure('Position', [0, 0, 1200, 600]);
        hold on;
        title(['Coherence of EC for ', key]);
        xlabel('Frequency (Hz)');
        ylabel('Coherence');
        grid on;

        % Calculate and plot coherence with itself
        [Cxy_self, f_self] = mscohere(EC, EC, window, noverlap, nfft, hdr.Fs);

        % Limit the frequency range to 0-40 Hz
        freq_range_self = f_self >= 0 & f_self <= 40;
        f_limited_self = f_self(freq_range_self);
        Cxy_limited_self = Cxy_self(freq_range_self);

        % Store the coherence result
        coherenceResults.(key).(key) = struct('frequency', f_limited_self, 'coherence', Cxy_limited_self);

        % Plot the coherence with itself on the second y-axis
        yyaxis right;
        plot(f_limited_self, Cxy_limited_self, 'k', 'LineWidth', 2, 'DisplayName', ['Coherence with ', key, ' (self)']);
        ylabel('Coherence (self)');
        ylim([0 1]);

        % Switch back to the first y-axis
        yyaxis left;

        % Colors for plotting coherence with other segments
        colors = lines(numel(fields) - 1);

        % Calculate and plot coherence with other segments
        colorIndex = 1;
        for j = 1:numel(fields)
            if i ~= j
                key2 = fields{j};
                data2 = segmentedResults.(key2);
                EC2 = data2.EC;

                % Calculate coherence
                [Cxy, f] = mscohere(EC, EC2, window, noverlap, nfft, hdr.Fs);

                % Limit the frequency range to 0-40 Hz
                freq_range = f >= 0 & f <= 40;
                f_limited = f(freq_range);
                Cxy_limited = Cxy(freq_range);

                % Store the coherence result
                coherenceResults.(key).(key2) = struct('frequency', f_limited, 'coherence', Cxy_limited);

                % Plot the coherence
                plot(f_limited, Cxy_limited, 'Color', colors(colorIndex, :), 'DisplayName', ['Coherence with ', key2]);
                colorIndex = colorIndex + 1;
            end
        end

        % Add legend to the plot
        legend('show');
        hold off;
    end
end