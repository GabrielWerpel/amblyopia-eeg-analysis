load participant_data_and_severity.mat

ID_SUBJECTS = {'A1','A3','A4','A6','A7','A8','A9','C1','C11','C12','C13','C14','C15'};
FSAMP_HZ = 2048;
fnZscore = @(x) (x - mean(x(:))) ./ std(x(:)); % x is matrix


for ii_subject = 1:size(ID_SUBJECTS,2)

  this_subject = ID_SUBJECTS{ii_subject};
  switch lower(this_subject)

    case {'a1'}
      mmsig = cat(3, A1_O1, A1_Oz, A1_O2);
    case {'a3'}
      mmsig = cat(3, A3_O1, A3_Oz, A3_O2);
    case {'a4'}
      mmsig = cat(3, A4_O1, A4_Oz, A4_O2);
    case {'a6'}
      mmsig = cat(3, A6_O1, A6_Oz, A6_O2);
    case {'a7'}
      mmsig = cat(3, A7_O1, A7_Oz, A7_O2);
    case {'a8'}
      mmsig = cat(3, A8_O1, A8_Oz, A8_O2);
    case {'a9'}
      mmsig = cat(3, A9_O1, A9_Oz, A9_O2);
    case {'c1'}
      mmsig = cat(3, C1_O1, C1_Oz, C1_O2);
    case {'c11'}
      mmsig = cat(3, C11_O1, C11_Oz, C11_O2);
    case {'c12'}
      mmsig = cat(3, C12_O1, C12_Oz, C12_O2);
    case {'c13'}
      mmsig = cat(3, C13_O1, C13_Oz, C13_O2);
    case {'c14'}
      mmsig = cat(3, C14_O1, C14_Oz, C14_O2);
    case {'c15'}
      mmsig = cat(3, C15_O1, C15_Oz, C15_O2);
    otherwise
      error("Unknown subject ID.");

  end

  amps = [];
  for ii_elec = 1:3

    msig = mmsig(:,:,ii_elec);
    msig = fnZscore(msig);

    % time, frequency axes
    deltat_s = 1/FSAMP_HZ;
    taxis_s = deltat_s * [0:(size(msig,1)-1)];
    deltaf_hz = 1/max(taxis_s);
    faxis_hz = deltaf_hz * [0:(size(msig,1)-1)];

    for ix_sig = 1:4 % signal

      for ix_seg = 1:5 % 2-second segments for each 10-second signal

        window = double(taxis_s > ((ix_seg-1)*2) & taxis_s <= (ix_seg*2));
        sig = msig(:,ix_sig);
        sig = sig .* window';

        Fsig = fft(sig) / length(sig);

        % reference is the integrated F amplitude from 36 to 40 Hz
        ix_alpha = (faxis_hz >= 8 & faxis_hz <= 12);
        ix_ref = (faxis_hz >= 36 & faxis_hz <= 40);
        amp_ref = sum(abs(Fsig(ix_ref)));
        amp_alpha = sum(abs(Fsig(ix_alpha))); 
        amp = 20*log10(amp_alpha / amp_ref);
        amps = [amps; [ii_subject ii_elec ix_sig ix_seg amp]];

      end % ix_seg
    end % ix_sig
  end % ii_elec

  % display amps; discarding the first 2-second segment
  for ii = 2:5
    disp(transpose(amps(ii:5:end,5)))
  end

end % ii_subject

