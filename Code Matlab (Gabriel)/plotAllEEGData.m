function plotAllEEGData(results)
    % Iterate through each field in the results structure
    fields = fieldnames(results);
    for i = 1:numel(fields)
        key = fields{i};
        data = results.(key).data;
        hdr = results.(key).header;

        % Create a new figure for each dataset
        figure('Position', [0, 0, 800, 200]);       
        
        % Use the header to add more detailed information if needed
        % For example, you can display the sampling frequency in the title
        title(['EEG Data for ', key, ' - Fs: ', num2str(hdr.Fs), ' Hz']);
        
        % Optional: If you have a time vector, you can use it for the x-axis
        time = (0:length(data)-1) / hdr.Fs;
        plot(time, data, 'k');
        title(['EEG Data for ', key]);
        xlabel('Time (s)');
        ylabel('Amplitude (μV)');
        xlim([0 40]);
        ylim([-50 50]);
    end
end
