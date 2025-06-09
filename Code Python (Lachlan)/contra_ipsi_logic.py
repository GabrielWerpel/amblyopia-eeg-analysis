import pandas as pd
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
BASE_DATA_PATH = BASE_DIR / "data"
COHORT_FILE = BASE_DATA_PATH / "Cohort.xlsx"

# Load the cohort Excel file
cohort_df = pd.read_excel(COHORT_FILE)

# Drop rows with missing values in relevant columns
cohort_df = cohort_df.dropna(subset=["Cohort", "LC", "RC"])


# Determine dominant eye and channel mapping
def determine_mapping(row):
    participant_id = str(row["Cohort"]).strip()
    lc = str(row["LC"]).strip()
    rc = str(row["RC"]).strip()

    if lc == "DEC":
        dominant_eye = "LC"
        mapping = {"O1": "OC", "O2": "OI"}
    elif rc == "DEC":
        dominant_eye = "RC"
        mapping = {"O1": "OI", "O2": "OC"}
    else:
        dominant_eye = "Unknown"
        mapping = {"O1": "O1", "O2": "O2"}

    return pd.Series(
        [participant_id, dominant_eye, mapping["O1"], mapping["O2"]],
        index=["Participant ID", "Dominant Eye", "O1 Mapping", "O2 Mapping"],
    )


# Apply the mapping function to each row
mapping_table = cohort_df.apply(determine_mapping, axis=1)

# Display the resulting table
print(mapping_table)
