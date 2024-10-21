function plotEnvelopeSignal(segmentedData)
    % Define colors for original and enveloped signals
    colors = {'b', 'r'};
    
    % Get all field names in the segmentedData structure
    fields = fieldnames(segmentedData);
    
    % Iterate through each field in the segmentedData structure
    for i = 1:numel(fields)
        key = fields{i};
        data = segmentedData.(key);
        hdr = data.header;
        
        % Extract the EEG segments
        EC = data.EC;
        EO = data.EO;
        DEC = data.DEC;
        NDEC = data.NDEC;

        % Compute the envelope of the signals using the Hilbert transform
        envEC = abs(hilbert(EC));
        envEO = abs(hilbert(EO));
        envDEC = abs(hilbert(DEC));
        envNDEC = abs(hilbert(NDEC));

        % Determine the number of samples for 1 second
        samples_per_second = hdr.Fs;

        % Limit the data to the first second
        EC = EC(1:samples_per_second);
        EO = EO(1:samples_per_second);
        DEC = DEC(1:samples_per_second);
        NDEC = NDEC(1:samples_per_second);
        
        envEC = envEC(1:samples_per_second);
        envEO = envEO(1:samples_per_second);
        envDEC = envDEC(1:samples_per_second);
        envNDEC = envNDEC(1:samples_per_second);

        % Create a new figure for each patient
        figure;
        
        subplot(4,1,1);
        plot(EC, 'Color', colors{1});
        hold on;
        plot(envEC, 'Color', colors{2}, 'LineWidth', 1.5);
        title([key ' - EC Signal and Envelope']);
        xlabel('Time (samples)');
        ylabel('Amplitude');
        legend('Original EC', 'Enveloped EC');
        xlim([1 samples_per_second]);
        hold off;

        subplot(4,1,2);
        plot(EO, 'Color', colors{1});
        hold on;
        plot(envEO, 'Color', colors{2}, 'LineWidth', 1.5);
        title([key ' - EO Signal and Envelope']);
        xlabel('Time (samples)');
        ylabel('Amplitude');
        legend('Original EO', 'Enveloped EO');
        xlim([1 samples_per_second]);
        hold off;

        subplot(4,1,3);
        plot(DEC, 'Color', colors{1});
        hold on;
        plot(envDEC, 'Color', colors{2}, 'LineWidth', 1.5);
        title([key ' - DEC Signal and Envelope']);
        xlabel('Time (samples)');
        ylabel('Amplitude');
        legend('Original DEC', 'Enveloped DEC');
        xlim([1 samples_per_second]);
        hold off;

        subplot(4,1,4);
        plot(NDEC, 'Color', colors{1});
        hold on;
        plot(envNDEC, 'Color', colors{2}, 'LineWidth', 1.5);
        title([key ' - NDEC Signal and Envelope']);
        xlabel('Time (samples)');
        ylabel('Amplitude');
        legend('Original NDEC', 'Enveloped NDEC');
        xlim([1 samples_per_second]);
        hold off;
    end
end
