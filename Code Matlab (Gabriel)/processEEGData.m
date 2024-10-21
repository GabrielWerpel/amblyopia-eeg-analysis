function [EEG_Oz_filtered, hdr] = processEEGData()
    % User selects BDF file using a dialog box
    [filename, path] = uigetfile('*.bdf', 'Select a BDF file');
    if isequal(filename, 0)
        error('No file selected');
    end

    % Construct the full file path
    fullFilePath = fullfile(path, filename);

    % Read header information using Fieldtrip toolbox
    hdr = read_biosemi_bdf(fullFilePath);

    % Read raw EEG data, skipping the first sample and extracting all samples
    EEG_raw = read_biosemi_bdf(fullFilePath, hdr, hdr.nSamplesPre, hdr.nSamples)';
    EEG_raw = EEG_raw(2:end, 1:end-1); % Remove first row (garbage value) and last column (event data)

    % Select data from the occipital channel 'Oz'
    channel_select = 'A16';  % Channel label for Oz
    channel_index = find(strcmp(hdr.label, channel_select));  % Find index of Oz in the label list

    if isempty(channel_index)
        error('Selected channel not found in the data');
    end

    EEG_Oz1 = EEG_raw(:, channel_index);  % Extract Oz channel data

    % Display a message indicating successful selection
    disp(['Data for channel ', channel_select, ' selected successfully']);

    % Filter EEG Data
    % Set bandpass filter parameters (2 to 80 Hz) - 6th order zero-phase Butterworth IIR
    Fc_BP = [2 80];  % Bandpass frequency range
    Wn_BP = Fc_BP / (hdr.Fs / 2);  % Normalize by Nyquist frequency

    % Create bandpass filter coefficients
    [B_BP, A_BP] = butter(3, Wn_BP, 'bandpass');

    % Apply bandpass filter
    EEG_Oz_filtered_BP = filtfilt(B_BP, A_BP, EEG_Oz1);

    % Set band stop filter parameters (48 to 52 Hz) - 6th order zero-phase Butterworth IIR
    Fc_BS = [48 52];  % Band stop frequency range
    Wn_BS = Fc_BS / (hdr.Fs / 2);  % Normalize by Nyquist frequency

    % Create band stop filter coefficients
    [B_BS, A_BS] = butter(3, Wn_BS, 'stop');

    % Apply band stop filter
    EEG_Oz_filtered = filtfilt(B_BS, A_BS, EEG_Oz_filtered_BP);
end
