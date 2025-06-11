import os
from pathlib import Path

import mne
import numpy as np
import pandas as pd
from scipy.io import loadmat
from mne.channels import make_standard_montage

from machine_learning_common.features.features_common import (
    compute_power_frequency_features,
)

# ----------------------------- #
#        CONFIGURATION         #
# ----------------------------- #

BASE_DIR = Path(__file__).resolve().parent
BASE_DATA_PATH = BASE_DIR / "data"
COHORT_FILE = BASE_DATA_PATH / "Cohort.xlsx"

SFREQ = 2048
CH_NAMES = ["O1", "Oz", "O2"]

BANDPASS_DATA = False
BANDPASS_FREQS = (0.5, 80)
NOTCH_FREQ = 50

DISCARD_TRANSITION_PERIOD = False
TRANSITION_PERIOD_SECS = 2
EPOCH_LENGTH = 0.25

# ----------------------------- #
#         COHORT LOGIC         #
# ----------------------------- #


def load_cohort_mapping(filepath: Path) -> dict:
    """
    Load cohort mapping from Excel file.
    Returns:
        dict: Mapping of participant ID to dominant eye ('LC' or 'RC').
    """
    df = pd.read_excel(filepath)
    df = df.dropna(subset=["Cohort", "LC", "RC"])
    mapping = {}

    for _, row in df.iterrows():
        participant = str(row["Cohort"]).strip()
        lc = str(row["LC"]).strip()
        rc = str(row["RC"]).strip()

        if lc == "DEC":
            mapping[participant] = "LC"
        elif rc == "DEC":
            mapping[participant] = "RC"

    return mapping


def get_channel_mapping(participant_id: str, dominant_eye: str) -> dict:
    """
    Determine which EEG channel is OC and which is OI.
    Args:
        participant_id (str): ID of the participant.
        dominant_eye (str): 'LC' or 'RC'.
    Returns:
        dict: Mapping of original channel names to {'OC', 'OI'}.
    """
    if dominant_eye == "LC":
        return {"O1": "OC", "O2": "OI"}
    elif dominant_eye == "RC":
        return {"O1": "OI", "O2": "OC"}
    else:
        raise ValueError(
            f"Invalid dominant eye for participant {participant_id}: {dominant_eye}"
        )


def create_custom_montage():
    """
    Create a custom montage for channels ["OI", "Oz", "OC"] based on the standard 10-20 montage.
    Returns:
        mne.channels.DigMontage: Custom montage object.
    """
    # Load the standard 10-20 montage
    standard_montage = make_standard_montage("standard_1020")

    # Extract positions for O1, Oz, and O2
    positions = {
        "OI": standard_montage.get_positions()["ch_pos"]["O1"],
        "Oz": standard_montage.get_positions()["ch_pos"]["Oz"],
        "OC": standard_montage.get_positions()["ch_pos"]["O2"],
    }

    # Create a custom montage with the new channel names
    custom_montage = mne.channels.make_dig_montage(ch_pos=positions, coord_frame="head")

    return custom_montage


# ----------------------------- #
#         MAIN LOGIC           #
# ----------------------------- #


def load_data() -> mne.BaseEpochs:
    """
    Load and parse EEG data from .mat files into MNE Epochs.
    Returns:
        mne.BaseEpochs: Combined epochs from all participants and conditions.
    """
    cohort_map = load_cohort_mapping(COHORT_FILE)
    return parse_data(cohort_map)


def parse_data(cohort_map: dict) -> mne.BaseEpochs:
    """
    Parse EEG data files, preprocess, epoch, and annotate with metadata.
    Returns:
        mne.BaseEpochs: Concatenated epochs across all participants and conditions.
    """
    custom_montage = create_custom_montage()

    event_ids = {
        "Eyes Closed": 0,
        "Eyes Opened": 1,
        "Dominant Eye Closed ": 2,
        "Non Dominant Eye Closed": 3,
    }

    all_epochs = []

    for filename in os.listdir(BASE_DATA_PATH):
        if not filename.endswith(".mat"):
            continue

        participant_id = filename.split("_")[1].split(".")[0]
        is_amblyopic = 0 if "c" in filename else 1
        raw_data = loadmat(BASE_DATA_PATH / filename)["mmsig"]

        dominant_eye = cohort_map.get(participant_id.upper(), None)
        ch_map = get_channel_mapping(participant_id, dominant_eye)

        # Rename channels accordingly
        mapped_ch_names = [ch_map.get(ch, ch) for ch in CH_NAMES]
        info = mne.create_info(ch_names=mapped_ch_names, sfreq=SFREQ, ch_types="eeg")

        alpha_ref_eyes_closed = None

        for condition_idx in range(raw_data.shape[1]):
            raw = mne.io.RawArray(raw_data[:, condition_idx, :].T, info)
            raw.set_montage(custom_montage)

            # Reorder channels so they are consistently ordered
            raw.reorder_channels(custom_montage.ch_names)

            raw = preprocess_data(raw)
            raw_data_array = raw.get_data()

            epochs = mne.make_fixed_length_epochs(
                raw, duration=EPOCH_LENGTH, preload=True
            )
            epochs.detrend = True

            alpha_refs = [
                compute_power_frequency_features(
                    raw_data_array[ch_idx, :],
                    epochs.info["sfreq"],
                    {"alpha_ref": (36, 40)},
                )["alpha_ref_band_power"]
                for ch_idx in range(len(mapped_ch_names))
            ]

            if condition_idx == 0:
                alpha_ref_eyes_closed = alpha_refs

            alpha_ref_df = pd.DataFrame(
                np.array([alpha_ref_eyes_closed] * len(epochs)),
                columns=[f"{ch}_alpha_ref" for ch in mapped_ch_names],
            )

            metadata = pd.DataFrame(
                {
                    "participant_id": [participant_id] * len(epochs),
                    "file_name": [filename] * len(epochs),
                    "amblyopia_assessment": [is_amblyopic] * len(epochs),
                    "experiment_condition": [condition_idx] * len(epochs),
                }
            )

            metadata = pd.concat(
                [metadata, alpha_ref_df.reset_index(drop=True)], axis=1
            )

            epochs.events[:, 2] = condition_idx
            epochs.event_id = event_ids
            epochs.metadata = metadata

            all_epochs.append(epochs)

    return mne.concatenate_epochs(all_epochs)


def preprocess_data(raw: mne.io.Raw) -> mne.io.Raw:
    """
    Apply preprocessing steps to raw EEG data.
    Args:
        raw (mne.io.Raw): Raw EEG data.
    Returns:
        mne.io.Raw: Preprocessed EEG data.
    """
    if BANDPASS_DATA:
        raw.filter(BANDPASS_FREQS[0], BANDPASS_FREQS[1])
        raw.notch_filter(NOTCH_FREQ)

    if DISCARD_TRANSITION_PERIOD:
        raw.crop(tmin=TRANSITION_PERIOD_SECS, tmax=None)

    return raw


# ----------------------------- #
#         ENTRY POINT          #
# ----------------------------- #

if __name__ == "__main__":
    data = load_data()
