function results = processAllEEGDataLuke()
    % Get a list of all .bdf files in the current directory
    files = dir('*.bdf');
    if isempty(files)
        error('No BDF files found in the current directory');
    end

    % Initialize the results dictionary
    results = struct;

    % Loop over each file
    for i = 1:length(files)
        filename = files(i).name;
        fullFilePath = fullfile(files(i).folder, filename);

        % Read header information using Fieldtrip toolbox
        hdr = read_biosemi_bdf(fullFilePath);

        % Read raw EEG data, skipping the first sample and extracting all samples
        EEG_raw = read_biosemi_bdf(fullFilePath, hdr, hdr.nSamplesPre, hdr.nSamples)';
        EEG_raw = EEG_raw(2:end, 1:end-1); % Remove first row (garbage value) and last column (event data)

        % Select data from the occipital channels 'A15' (O1), 'A16' (Oz), and 'A17' (O2)
        channels_select = {'A15', 'A16', 'A17'};
        channel_indices = find(ismember(hdr.label, channels_select));  % Find indices of A15, A16, and A17

        if length(channel_indices) ~= length(channels_select)
            error('One or more selected channels not found in the data');
        end

        EEG_O1 = EEG_raw(:, channel_indices(1));  % Extract O1 (A15) channel data
        EEG_Oz = EEG_raw(:, channel_indices(2));  % Extract Oz (A16) channel data
        EEG_O2 = EEG_raw(:, channel_indices(3));  % Extract O2 (A17) channel data

        % Filter EEG Data
        % Set bandpass filter parameters (2 to 80 Hz) - 6th order zero-phase Butterworth IIR
        Fc_BP = [2 80];  % Bandpass frequency range
        Wn_BP = Fc_BP / (hdr.Fs / 2);  % Normalize by Nyquist frequency

        % Create bandpass filter coefficients
        [B_BP, A_BP] = butter(3, Wn_BP, 'bandpass');

        % Apply bandpass filter
        EEG_O1_filtered_BP = filtfilt(B_BP, A_BP, EEG_O1);
        EEG_Oz_filtered_BP = filtfilt(B_BP, A_BP, EEG_Oz);
        EEG_O2_filtered_BP = filtfilt(B_BP, A_BP, EEG_O2);

        % Set band stop filter parameters (48 to 52 Hz) - 6th order zero-phase Butterworth IIR
        Fc_BS = [48 52];  % Band stop frequency range
        Wn_BS = Fc_BS / (hdr.Fs / 2);  % Normalize by Nyquist frequency

        % Create band stop filter coefficients
        [B_BS, A_BS] = butter(3, Wn_BS, 'stop');

        % Apply band stop filter
        EEG_O1_filtered = filtfilt(B_BS, A_BS, EEG_O1_filtered_BP);
        EEG_Oz_filtered = filtfilt(B_BS, A_BS, EEG_Oz_filtered_BP);
        EEG_O2_filtered = filtfilt(B_BS, A_BS, EEG_O2_filtered_BP);
        
        % Extract prefix before underscore
        underscoreIndex = find(filename == '_', 1);
        
        % Store results in the dictionary
        key = filename(1:underscoreIndex-1);
        results.(key) = struct('O1_data', EEG_O1_filtered, 'Oz_data', EEG_Oz_filtered, 'O2_data', EEG_O2_filtered, 'header', hdr);
        
        % Display a message indicating successful processing
        disp(['Data for file ', filename, ' processed successfully']);
    end
end
