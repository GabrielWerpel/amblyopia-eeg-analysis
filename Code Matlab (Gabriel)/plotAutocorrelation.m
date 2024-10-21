function plotAutocorrelation(segmentedData)
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

        % Determine the number of samples for 1 second
        samples_per_second = hdr.Fs;

        % Limit the data to the first second
        EC = EC(1:samples_per_second);
        EO = EO(1:samples_per_second);
        DEC = DEC(1:samples_per_second);
        NDEC = NDEC(1:samples_per_second);

        % Compute the autocorrelation for each segment
        acEC = xcorr(EC, 'coeff');
        acEO = xcorr(EO, 'coeff');
        acDEC = xcorr(DEC, 'coeff');
        acNDEC = xcorr(NDEC, 'coeff');

        % Create a new figure for each patient
        figure;
        
        subplot(4,1,1);
        plot(acEC);
        title([key ' - EC Autocorrelation']);
        xlabel('Lag');
        ylabel('Autocorrelation');
        ylim([-1 1]);

        subplot(4,1,2);
        plot(acEO);
        title([key ' - EO Autocorrelation']);
        xlabel('Lag');
        ylabel('Autocorrelation');
        ylim([-1 1]);

        subplot(4,1,3);
        plot(acDEC);
        title([key ' - DEC Autocorrelation']);
        xlabel('Lag');
        ylabel('Autocorrelation');
        ylim([-1 1]);

        subplot(4,1,4);
        plot(acNDEC);
        title([key ' - NDEC Autocorrelation']);
        xlabel('Lag');
        ylabel('Autocorrelation');
        ylim([-1 1]);
    end
end
