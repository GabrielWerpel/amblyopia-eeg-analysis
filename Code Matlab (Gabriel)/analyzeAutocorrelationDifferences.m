function analyzeAutocorrelationDifferences(segmentedData)
    % Get all field names in the segmentedData structure
    fields = fieldnames(segmentedData);

    % Initialize arrays to store autocorrelation values
    groupA_ac = [];
    groupB_ac = [];
    
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

        % Aggregate autocorrelation values by group
        if startsWith(key, 'A')
            groupA_ac = [groupA_ac; acEC', acEO', acDEC', acNDEC'];
        elseif startsWith(key, 'C')
            groupB_ac = [groupB_ac; acEC', acEO', acDEC', acNDEC'];
        end
        
        % Plot autocorrelation for each segment
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
    
    % Perform statistical tests
    lags = size(groupA_ac, 2) / 4;
    pValues = zeros(lags, 4);
    for lag = 1:lags
        [~, pValues(lag, 1)] = ttest2(groupA_ac(:, lag), groupB_ac(:, lag));
        [~, pValues(lag, 2)] = ttest2(groupA_ac(:, lag + lags), groupB_ac(:, lag + lags));
        [~, pValues(lag, 3)] = ttest2(groupA_ac(:, lag + 2 * lags), groupB_ac(:, lag + 2 * lags));
        [~, pValues(lag, 4)] = ttest2(groupA_ac(:, lag + 3 * lags), groupB_ac(:, lag + 3 * lags));
    end
    
    % Plot p-values for statistical tests
    figure;
    subplot(4,1,1);
    plot(pValues(:,1));
    title('EC p-values');
    xlabel('Lag');
    ylabel('p-value');
    yline(0.05, 'r--', 'Significance Threshold');

    subplot(4,1,2);
    plot(pValues(:,2));
    title('EO p-values');
    xlabel('Lag');
    ylabel('p-value');
    yline(0.05, 'r--', 'Significance Threshold');

    subplot(4,1,3);
    plot(pValues(:,3));
    title('DEC p-values');
    xlabel('Lag');
    ylabel('p-value');
    yline(0.05, 'r--', 'Significance Threshold');

    subplot(4,1,4);
    plot(pValues(:,4));
    title('NDEC p-values');
    xlabel('Lag');
    ylabel('p-value');
    yline(0.05, 'r--', 'Significance Threshold');
    
    % Interpret Results
    fprintf('Autocorrelation Analysis Results:\n');
    for section = 1:4
        significant_lags = find(pValues(:,section) < 0.05);
        if ~isempty(significant_lags)
            switch section
                case 1
                    section_name = 'EC';
                case 2
                    section_name = 'EO';
                case 3
                    section_name = 'DEC';
                case 4
                    section_name = 'NDEC';
            end
            fprintf('Significant differences in %s at lags: %s\n', section_name, num2str(significant_lags'));
        end
    end
end
