% Example Code: Loading Biosemi EEG Data
% Jerry Zhang
% December 2023

% 1. Extract multi-channel EEG data from Biosemi BDF files
% 2. Compute bandpass, bandstop and notch filtered EEG signals
% 3. Segment filtered EEG data
% 4. Compute FFT on EEG segments

%% Load File and Extract Data
close all;
clearvars;

% Set directory, get file info and load data
[filename, path] = uigetfile('.\*.bdf');
hdr = read_biosemi_bdf([path filename]);
EEG_raw = read_biosemi_bdf([path filename], hdr, hdr.nSamplesPre, hdr.nSamples)'; % This is from the 'Fieldtrip' toolbox
EEG_events = EEG_raw(2:end, end); % We don't need the event data for now
EEG_raw = EEG_raw(2:end, 1:end-1); % Discard the first garbage value

% Let's just look at a single, occipital channel Oz for now
channel_select = ['A16'];
EEG_Oz = EEG_raw(:, find(strcmp(hdr.label,channel_select)));

%% Filter EEG Data

% See https://au.mathworks.com/help/signal/ref/butter.html
% Set up 1-40 Hz bandpass filter - 6th order zero-phase Butterworth IIR
Fc_BP = [1 40]; 
Wn_BP = Fc_BP/(hdr.Fs/2);

[B_BP, A_BP] = butter(3, Wn_BP, 'bandpass');
EEG_Oz_filtered = filtfilt(B_BP, A_BP, EEG_Oz);


%% Plot EEG Time-Series - Raw and Filtered



%% Segment EEG Data



%% Plot and Compare EEG Fourier Spectrums



