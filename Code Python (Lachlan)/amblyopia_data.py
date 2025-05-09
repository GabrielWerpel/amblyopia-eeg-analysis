import mne
from pathlib import Path
import os
from scipy.io import loadmat
import pandas as pd
from machine_learning_common.features.features_common import (
    compute_power_frequency_features,
)
import numpy as np

### CONFIGURATION ###
# File paths #
BASE_DIR = Path(__file__).resolve().parent
BASE_DATA_PATH = BASE_DIR / "data"

# Experiment parameters #
SFREQ = 2048
CH_NAMES = ["O1", "Oz", "O2"]

# Pre-processing parameters #
BANDPASS_DATA = False
BANDPASS_FREQS = (0.5, 80)
NOTCH_FREQ = 50

# Options #
DISCARD_TRANSITION_PERIOD = False
TRANSITION_PERIOD_SECS = 2
EPOCH_LENGTH = 0.25
#####################


def load_data() -> mne.BaseEpochs:
    return parse_data()


def parse_data() -> mne.BaseEpochs:
    """ """
    # Create MNE info object and event ID dict
    info = mne.create_info(ch_names=CH_NAMES, sfreq=SFREQ, ch_types="eeg")
    event_ids = {
        "Eyes Closed": 0,
        "Eyes Opened": 1,
        "Dominant Eye Closed ": 2,
        "Non Dominant Eye Closed": 3,
    }

    combined_epochs = []
    for fp in os.listdir(BASE_DATA_PATH):
        if not fp.endswith(".mat"):
            continue

        participant_id = fp.split("_")[1].split(".")[0]
        ambploypia_assesment = 0 if "c" in fp else 1  # 0 for control, 1 for amblyopia
        raw_data = loadmat(BASE_DATA_PATH / fp)
        eeg_data = raw_data["mmsig"]

        # Iterate through the experimental conditions
        alpha_reference_eyes_closed = None
        for experiment_condition in range(eeg_data.shape[1]):
            eeg_segment = mne.io.RawArray(eeg_data[:, experiment_condition, :].T, info)
            eeg_segment_preprocessed = preprocess_data(eeg_segment)
            eeg_segment_preprocessed_data = eeg_segment_preprocessed.get_data()

            # Create epochs
            epochs = mne.make_fixed_length_epochs(
                eeg_segment_preprocessed, duration=EPOCH_LENGTH, preload=True
            )
            epochs.detrend = True

            # Compute alpha reference needed to compute the normalized alpha feature
            normalized_alpha_ref = []
            for ch_i in range(len(CH_NAMES)):
                alpha_reference = compute_power_frequency_features(
                    eeg_segment_preprocessed_data[ch_i, :],
                    epochs.info["sfreq"],
                    {"alpha_ref": (36, 40)},
                )["alpha_ref_band_power"]

                normalized_alpha_ref.append(alpha_reference)

            if experiment_condition == 0:
                alpha_reference_eyes_closed = normalized_alpha_ref

            normalized_alpha_ref_df = pd.DataFrame(
                np.array([alpha_reference_eyes_closed] * len(epochs)),
                # np.array([normalized_alpha_ref] * len(epochs)),
                columns=[f"{ch_name}_alpha_ref" for ch_name in CH_NAMES],
            )

            metadata = pd.DataFrame(
                {
                    "participant_id": [participant_id] * len(epochs),
                    "file_name": [fp] * len(epochs),
                    "amblyopia_assesment": [ambploypia_assesment] * len(epochs),
                    "experiment_condition": [experiment_condition] * len(epochs),
                }
            )
            metadata = pd.concat(
                [metadata, normalized_alpha_ref_df.reset_index(drop=True)], axis=1
            )

            epochs.events[:, 2] = experiment_condition
            epochs.event_id = event_ids
            epochs.metadata = metadata
            combined_epochs.append(epochs)

    # Combine all the epochs into a single array
    combined_epochs = mne.concatenate_epochs(combined_epochs)
    return combined_epochs


def preprocess_data(raw_data: mne.io.Raw) -> mne.io.Raw:
    """
    Perform the following pre-processing:
    1) 0.5 - 80Hz bandpass filter
    2) 50Hz notch filter
    """
    if BANDPASS_DATA:
        raw_data.filter(BANDPASS_FREQS[0], BANDPASS_FREQS[1])
        raw_data.notch_filter(NOTCH_FREQ)

    if DISCARD_TRANSITION_PERIOD:
        raw_data.crop(tmin=TRANSITION_PERIOD_SECS, tmax=None)

    return raw_data


if __name__ == "__main__":
    test_data = load_data()
