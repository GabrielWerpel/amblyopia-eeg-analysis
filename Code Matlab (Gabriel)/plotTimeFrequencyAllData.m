function plotTimeFrequencyAllData(segmentedData)
    % Extract all fieldnames from the segmentedData
    patients = fieldnames(segmentedData);

    % Define conditions to plot
    conditions = {'EC', 'EO', 'DEC', 'NDEC'};
    numPlotsPerPatient = numel(conditions);
    
    % Frequency range of interest
    freqRange = [0 40];
    
    % Parameters for spectrogram to balance resolution and smoothness
    windowSize = 256*2;       % Window size for frequency resolution
    noverlap = floor(windowSize * 0.75); % Reduce overlap to 75% for smoother time resolution
    nfft = 1024*16;            % Number of FFT points to keep frequency resolution high

    % Iterate through each patient
    for i = 1:numel(patients)
        patientID = patients{i};
        patientData = segmentedData.(patientID);
        
        % Create a new figure for each patient
        figure;
        % Set figure size for better visibility
        set(gcf, 'Position', [100, 100, 1200, 800]); % Adjust size as needed

        % Plot each condition
        for j = 1:numPlotsPerPatient
            condition = conditions{j};
            data = patientData.(condition);
            
            % Check if data is not empty
            if ~isempty(data)
                subplot(2, 2, j); % Layout for 4 conditions
                
                % Compute and plot the spectrogram
                [s, f, t] = spectrogram(data, windowSize, noverlap, nfft, patientData.header.Fs, 'yaxis');
                % Limit frequency range to 0-40 Hz
                freqIndices = f >= freqRange(1) & f <= freqRange(2);
                s = s(freqIndices, :);
                f = f(freqIndices);
                
                % Convert power to dB scale and plot
                dBs = 10*log10(abs(s));
                imagesc(t, f, dBs);
                axis xy;
                colormap jet;
                colorbar;
                title([patientID ' - ' condition]);
                
                % Adjust color limits to enhance visibility
                % Set the color limits based on the minimum and a fixed maximum value
                % caxis([prctile(dBs(:), 5), prctile(dBs(:), 95)]); % Adjust these percentiles as needed
                
                % Label axes
                xlabel('Time (s)');
                ylabel('Frequency (Hz)');
            end
        end
        
        % Adjust subplot spacing and add a title
        sgtitle(['Time-Frequency Analysis for ' patientID]);
    end
end
