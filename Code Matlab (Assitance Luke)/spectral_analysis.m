%

T_SEC = 0:0.1:10; % vector describing our time axis
F1_HZ = 1;
F2_HZ = 1.5;
OFFSET = 1;
sig_ = OFFSET + 6*sin(2*pi*F1_HZ*T_SEC) + 3*sin(2*pi*F2_HZ*T_SEC);

%
figure; hold on
plot(T_SEC, sig_, '-k'); axis square
axis([-1 11 -10 10])
xlabel('Time (sec)')
ylabel('Measured signal (V)')
set(gca, 'FontSize', 18)

%
Fsig_ = fft(sig_) / length(sig_); % for details, see 'help fft'

%
aFsig_ = abs(Fsig_); % we're interested in amplitude, but not phase!

%
delta_freq_Hz = 1 / max(T_SEC);
f_axis_Hz = delta_freq_Hz * (0:(length(aFsig_)-1));

figure; hold on
plot(f_axis_Hz, aFsig_, '-ok'); axis square
axis([-0.2 10.2 -1 4])
xlabel('Frequency (Hz)')
ylabel('Fourier component amplitude (V)')
set(gca, 'FontSize', 18)
set(gca, 'xtick', 0:max(T_SEC))
set(gca, 'xticklabel', [0 1 2 3 4 5 -4 -3 -2 -1])

%
aFsig_ = 2*aFsig_(1:floor(length(aFsig_)/2));
aFsig_(1) = aFsig_(1)/2; % don't 2x the DC component b/c it has no complement

%
figure; hold on
plot(f_axis_Hz(1:length(aFsig_)), aFsig_, '-ok'); axis square
axis([-0.2 5 -1 7])
xlabel('Frequency (Hz)')
ylabel('Fourier component amplitude (V)')
set(gca, 'FontSize', 18)
set(gca, 'xtick', 0:5)
set(gca, 'xticklabel', [0 1 2 3 4 5])
title('One-sided Fourier amplitude spectrum')

%%%
%%
%%%

%
load A8_Alpha.mat; % participant A8
whos

%
t_sec = (1/Fs) * [0:(length(EEG_Eyes_Closed)-1)];

%
figure; hold on; 
plot(t_sec,EEG_Eyes_Closed,'-k'); axis square
plot(t_sec,EEG_Eyes_Open,'-b');
xlabel('Time (s)')
ylabel('EEG (microvolts)')
set(gca, 'FontSize', 18)
axis square
axis tight
grid on

%
F_Nyquist_Hz = Fs/2;
F_CUT1_HZ = 1;
F_CUT2_HZ = 100;
[b,a] = butter(2,[F_CUT1_HZ/F_Nyquist_Hz, F_CUT2_HZ/F_Nyquist_Hz]); % an order-4 Butterworth filter; for more see 'help butter'
EEG_Eyes_Closed_filt = filter(b,a,EEG_Eyes_Closed);
EEG_Eyes_Open_filt = filter(b,a,EEG_Eyes_Open);

%
figure; hold on; 
plot(t_sec,EEG_Eyes_Closed,'-k'); axis square
plot(t_sec,EEG_Eyes_Closed_filt,'-r')
xlabel('Time (s)')
ylabel('EEG (microvolts)')
set(gca, 'FontSize', 18)
axis square
axis tight
grid on

%
%sig = EEG_Eyes_Open_filt;
sig = EEG_Eyes_Closed_filt;

%
Fsig = fft(sig) / length(sig);
aFsig = abs(Fsig); % amplitudes, not phases

%
aFsig = 2*aFsig(1:floor(length(Fsig)/2));
aFsig(1) = aFsig(1)/2; % don't 2x the DC component!
f_axis_Hz = 1/10 * (0:(length(aFsig)-1));

figure; hold on
plot(f_axis_Hz, aFsig, '-or'); axis square
axis tight
axis([xlim 0 max(ylim)])
xlabel('Frequency (Hz)')
ylabel('Fourier amplitude (microvolts)')
set(gca, 'FontSize', 18)

%

Fsig = fft(sig) / length(sig);
aFsig = abs(Fsig); % amplitudes, not phases
p_spectrum = aFsig.^2; % two-sided power spectrum, p_spectrum
p_spectrum = 2*p_spectrum(1:floor(length(Fsig)/2));
p_spectrum(1) = p_spectrum(1)/2; % one-sided power spectrum, p_spectrum

figure; hold on
plot(f_axis_Hz, p_spectrum, '-or'); axis square
axis tight
axis([xlim 0 max(ylim)])
xlabel('Frequency (cyc per sec)')
ylabel('EEG power (microvolts squared)')
set(gca, 'FontSize', 18)

%

P0 = sum([EEG_Eyes_Closed_filt EEG_Eyes_Open_filt].^2) / length([EEG_Eyes_Closed_filt EEG_Eyes_Open_filt]);
p_spectrum_dB = 10*log10(p_spectrum / P0);
figure; hold on
plot(f_axis_Hz, p_spectrum_dB, '-or'); axis square
axis tight
axis([0 100 ylim])
xlabel('Frequency (Hz)')
ylabel('Signal power (dB rel. mean inst. power)')
set(gca, 'FontSize', 18)

%

pgon1 = polyshape([8 8 12 12],[min(ylim) max(ylim) max(ylim) min(ylim)]);
plot(pgon1)
pgon2 = polyshape([12 12 30 30],[min(ylim) max(ylim) max(ylim) min(ylim)]);
plot(pgon2)
mask1 = (f_axis_Hz > 8 & f_axis_Hz <= 12);
mean(p_spectrum_dB(mask1))
mask2 = (f_axis_Hz > 12 & f_axis_Hz <= 30);
mean(p_spectrum_dB(mask2))

