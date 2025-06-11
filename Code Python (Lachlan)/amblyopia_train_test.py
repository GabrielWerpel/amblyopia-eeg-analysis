import numpy as np
from sklearn.metrics import accuracy_score, matthews_corrcoef
from sklearn.model_selection import (
    GridSearchCV,
    StratifiedGroupKFold,
    StratifiedKFold,
    RandomizedSearchCV,
)

from amblyopia_data import load_data
from machine_learning_common.evaluation.local_builder import LocalBuilder
from machine_learning_common.evaluation.results_director import ResultsDirector
from machine_learning_common.features.features_common import (
    compute_entropy_features,
    compute_power_frequency_features,
    compute_fractal_features,
    compute_variation_features,
    compute_features_from_epochs,
    bandpass_filter,
    compute_band_power,
)
from sklearn.preprocessing import StandardScaler
from machine_learning_common.evaluation.utils import does_classifier_use_features
import os

np.random.seed(42)

from machine_learning_common.hyperparameters_and_classifiers.classifiers import (
    Classifiers,
)
from machine_learning_common.evaluation.utils import save_overall_performance

# Create object for logging results
results_director = ResultsDirector(
    builders=[LocalBuilder()], results_root="/tmp/amblyopia_results"
)

# Load the data as mne Epochs
epochs = load_data()
classes = {"Normal": 0, "Amblyopia": 1}

# Shuffle the epochs
shuffled_indices = np.random.permutation(len(epochs))
epochs = epochs[shuffled_indices]

# Compute the normalized alpha feature
normalized_alpha_features = np.zeros((len(epochs), len(epochs.ch_names)))
normalized_alpha_feature_names = [f"{ch}_normalized_alpha" for ch in epochs.ch_names]

for epoch_i, epoch in enumerate(epochs):
    for channel_i, channel in enumerate(epochs.ch_names):
        alpha = compute_power_frequency_features(
            epoch[channel_i, :], int(epochs.info["sfreq"])
        )["alpha_band_power"]
        alpha_reference = epochs[epoch_i].metadata[f"{channel}_alpha_ref"].iloc[0]
        normalized_alpha_features[epoch_i, channel_i] = 20 * np.log10(
            alpha / alpha_reference
        )

# Create features from data
functions = [
    compute_power_frequency_features,
    # compute_alpha_power_normalized,
    # compute_entropy_features,
    # compute_alpha_power_normalized,
    # compute_power_frequency_features,
    # compute_fractal_features,
    # compute_variation_features,
]

kwargs = {
    "sfreq": epochs.info["sfreq"],
}

features, feature_names = compute_features_from_epochs(epochs, functions, **kwargs)
feature_names.append("experiment_condition")
feature_names.extend(normalized_alpha_feature_names)
features = np.hstack((features, epochs.events[:, 2][:, np.newaxis]))
features = np.hstack((features, normalized_alpha_features))

# Create channel grouping
channel_grouping = {
    channel: [i for i, name in enumerate(feature_names) if channel in name]
    for channel in epochs.info["ch_names"]
}

# Permutate the data
labels = epochs.metadata["amblyopia_assessment"].to_numpy()
participant_ids = epochs.metadata["participant_id"].to_numpy()

test_indices = np.where((participant_ids == "c1") | (participant_ids == "a1"))[0]
train_indices = np.where((participant_ids != "c1") & (participant_ids != "a1"))[0]
assert set(epochs[test_indices].metadata["participant_id"].unique()) == {
    "c1",
    "a1",
}, "Test participants should only include 'c1' and 'a1'"

print(
    f"Train participants: {epochs[train_indices].metadata['participant_id'].unique()}"
)

x_test, x_train = features[test_indices], features[train_indices]
y_test, y_train = (
    labels[test_indices],
    labels[train_indices],
)
test_groups, train_groups = (
    participant_ids[test_indices],
    participant_ids[train_indices],
)

# Apply standard scaling
scaler = StandardScaler()
x_train = scaler.fit_transform(x_train)
x_test = scaler.transform(x_test)

# Summerize the data and save as a Dataframe
results_director.build_dataset_summary(
    y_train=y_train,
    y_test=y_test,
    groups_train=train_groups,
    groups_test=test_groups,
    class_dict=classes,
)

best_score = 0
best_classifier = None
best_params = None
classifiers = {}
scoring = "matthews_corrcoef"

classifiers_to_eval = Classifiers()
for name, model, params in classifiers_to_eval:
    print(f"Running hyperparameter tuning for {name}")

    if not does_classifier_use_features(model):
        continue

    # Run hyperparameter tuning
    try:
        clf = GridSearchCV(
            model,
            params,
            cv=StratifiedKFold(5, shuffle=True, random_state=42),
            scoring=scoring,
            return_train_score=True,
            verbose=1,
            n_jobs=-1,
            error_score=0.0,
        )

        clf.fit(x_train, y_train)
    except Exception as e:
        print(f"Error processing {name}: {e}")
        continue

    print(f"Processing with model: {name}")
    print(f"Completed {name}. Best score: {clf.best_score_:.2f}")
    classifiers[name] = clf

    if clf.best_score_ > best_score:
        best_score = clf.best_score_
        best_classifier = name
        best_params = clf.best_params_
        print(f"New best classifier found: {best_classifier} with score: {best_score}")

# Save the hyperparameter tuning results
results_director.build_hyperparameter_tuning_results(
    classifiers=classifiers,
    x_train_features=x_train,
    x_train=x_train,
    y_train=y_train,
    class_names=classes.keys(),
    feature_names=feature_names,
)

# Train the best model on the entire training set
best_model = classifiers[best_classifier].best_estimator_
best_model.set_params(**best_params)
best_model.fit(x_train, y_train)
predictions = best_model.predict(x_test)

# Save the evaluation results
results_director.build_evaluation_results(
    best_classifier=best_model,
    X=features,
    X_features=features,
    y=labels,
    groups=participant_ids,
    test_indices=test_indices,
    train_indices=train_indices,
    y_pred=predictions,
    class_names=classes.keys(),
    feature_names=feature_names,
    target_class=classes["Amblyopia"],
    scoring=scoring,
    channel_grouping=channel_grouping,
    montage=epochs.get_montage(),
)

# Save results split by amblopia/normal and experiment condition
test_metadata = epochs[test_indices].metadata.copy()
condition_mapping = {v: k for k, v in epochs.event_id.items()}
test_metadata["participant_experiment_id"] = (
    test_metadata["participant_id"]
    + "_"
    + test_metadata["experiment_condition"].map(condition_mapping).str.replace(" ", "_")
)

save_fp = os.path.join(results_director.results_root, "other")
os.mkdir(save_fp)

save_overall_performance(
    save_fp,
    predictions,
    y_test,
    test_metadata["participant_experiment_id"].to_numpy(),
    np.arange(8).tolist(),  # Not important
    "participant_vs_condition_performance_metrics",
)

mcc = matthews_corrcoef(y_test, predictions)
accuracy = accuracy_score(y_test, predictions)
print(
    f"Best model: {best_classifier} with parameters: {best_params} has a MCC: {mcc:.2f} and accuracy: {accuracy:.2f}"
)
