import numpy as np
from sklearn.metrics import accuracy_score
from sklearn.model_selection import (
    GridSearchCV,
    StratifiedGroupKFold,
    StratifiedKFold,
    RandomizedSearchCV,
    LeaveOneGroupOut,
    GroupKFold,
)
from sklearn.base import clone
import pandas as pd

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
from statistical_testing import run_baseline_cv_with_shuffled_labels, perform_statistical_tests
import os
import csv

np.random.seed(42)

from machine_learning_common.hyperparameters_and_classifiers.classifiers import (
    Classifiers,
)
from machine_learning_common.evaluation.utils import save_overall_performance


def main(test_participant_ids=[], exclude=[]):
    # Create object for logging results
    results_director = ResultsDirector(
        builders=[LocalBuilder()],
        results_root=f"/tmp/amblyopia_results_v15_{"_".join(test_participant_ids)}",
    )

    # Load the data as mne Epochs
    epochs = load_data()
    # epochs = epochs["Eyes Opened"]
    
    # Remove excluded participants from the data
    if exclude:
        # Find indices of epochs to drop (participants to exclude)
        exclude_indices = epochs.metadata["participant_id"].isin(exclude)
        epochs_to_drop = np.where(exclude_indices)[0]
        
        # Drop epochs using MNE's drop method
        epochs.drop(epochs_to_drop)
        
        print(f"Excluded participants: {exclude}")
        print(f"Remaining participants: {epochs.metadata['participant_id'].unique()}")

    epochs_data = epochs.get_data()
    n_recordings, n_channels, n_samples = epochs_data.shape
    reshaped_data = epochs_data.transpose(1, 0, 2).reshape(n_channels, -1).T  # Shape: (n_recordings * n_samples, n_channels)

    scaler = StandardScaler()
    normalized_data = scaler.fit_transform(reshaped_data)

    # Reshape back to original shape
    epochs_data = normalized_data.T.reshape(n_channels, n_recordings, n_samples).transpose(1, 0, 2)

    # Limit epochs to only a certain experimental condition
    # epochs = epochs['Eyes Closed']
    # epochs = epochs["Dominant Eye Closed"].copy()
    # epochs = epochs["Non Dominant Eye Closed"].copy()

    classes = {"Normal": 0, "Amblyopia": 1}

    # # Shuffle the epochs
    shuffled_indices = np.random.permutation(len(epochs))
    epochs = epochs[shuffled_indices]

    # Compute the normalized alpha feature
    normalized_alpha_features = np.zeros((len(epochs), len(epochs.ch_names)))
    normalized_alpha_feature_names = [
        f"{ch}_normalized_alpha" for ch in epochs.ch_names
    ]

    for epoch_i, epoch in enumerate(epochs):
        for channel_i, channel in enumerate(epochs.ch_names):
            alpha = compute_power_frequency_features(
                epoch[channel_i, :], int(epochs.info["sfreq"])
            )["alpha_band_power"]
            alpha_reference = epochs[epoch_i].metadata[f"{channel}_alpha_ref"].iloc[0]
            normalized_alpha_features[epoch_i, channel_i] = 20 * np.log10(
                alpha / alpha_reference
            )

    # Compute alpha power ratio (OC channel eyes closed vs eyes open) for each participant
    alpha_ratio_features = np.zeros(len(epochs))
    
    for participant_id in epochs.metadata["participant_id"].unique():
        participant_mask = epochs.metadata["participant_id"] == participant_id
        participant_epochs = epochs[participant_mask]
        
        # Get OC channel data for eyes closed (0) and eyes open (1) conditions
        oc_idx = list(participant_epochs.ch_names).index("OC")
        closed_data = participant_epochs[participant_epochs.metadata["experiment_condition"] == 0].get_data()[:, oc_idx, :]
        open_data = participant_epochs[participant_epochs.metadata["experiment_condition"] == 1].get_data()[:, oc_idx, :]
        
        # Calculate mean alpha power for each condition
        alpha_closed = np.mean([compute_power_frequency_features(epoch, int(epochs.info["sfreq"]))["alpha_band_power"] for epoch in closed_data])
        alpha_open = np.mean([compute_power_frequency_features(epoch, int(epochs.info["sfreq"]))["alpha_band_power"] for epoch in open_data])
        
        # Assign ratio to all epochs of this participant
        alpha_ratio_features[participant_mask] = alpha_closed / alpha_open if alpha_open > 0 else 1.0

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
    
    experiment_conditions = epochs.events[:, 2]
    unique_conditions = np.unique(experiment_conditions)
    one_hot_conditions = np.zeros((len(experiment_conditions), len(unique_conditions)))
    
    for i, condition in enumerate(unique_conditions):
        one_hot_conditions[:, i] = (experiment_conditions == condition).astype(int)
    
    # Add one-hot encoded feature names
    condition_names = [f"experiment_condition_{int(cond)}" for cond in unique_conditions]
    feature_names.extend(normalized_alpha_feature_names)
    feature_names.extend(condition_names)
    # feature_names.append("OC_alpha_ratio_closed_vs_open")
    
    features = np.hstack((features, normalized_alpha_features))
    features = np.hstack((features, one_hot_conditions))
    # features = np.hstack((features, alpha_ratio_features[:, np.newaxis]))

    # Create channel grouping
    channel_grouping = {
        channel: [i for i, name in enumerate(feature_names) if channel in name]
        for channel in epochs.info["ch_names"]
    }

    # Permutate the data
    labels = epochs.metadata["amblyopia_assessment"].to_numpy()
    participant_ids = epochs.metadata["participant_id"].to_numpy()

    # Create test and train indices based on participant IDs
    test_indices = np.where(np.isin(participant_ids, test_participant_ids))[0]
    train_indices = np.where(~np.isin(participant_ids, test_participant_ids))[0]
    assert set(epochs[test_indices].metadata["participant_id"].unique()) == set(
        test_participant_ids
    ), f"Test participants should only include {test_participant_ids}"

    print(
        f"Train participants: {epochs[train_indices].metadata['participant_id'].unique()}"
    )

    x_test_features, x_train_features = features[test_indices], features[train_indices]
    x_test, x_train = (epochs_data[test_indices], epochs_data[train_indices])

    y_test, y_train = (
        labels[test_indices],
        labels[train_indices],
    )
    test_groups, train_groups = (
        participant_ids[test_indices],
        participant_ids[train_indices],
    )

    # Apply standard scaling (exclude last 4 features - one-hot encoded conditions)
    scaler = StandardScaler()
    x_train_features[:, :-4] = scaler.fit_transform(x_train_features[:, :-4])
    x_test_features[:, :-4] = scaler.transform(x_test_features[:, :-4])

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
    trained_classifiers = {}
    scoring = "accuracy"

    # classifiers_to_eval = Classifiers(n_chans=3, n_outputs=2, n_times=512, sfreq=epochs.info["sfreq"])
    classifiers_to_eval = Classifiers(n_chans=3, n_outputs=2, n_times=512, sfreq=epochs.info["sfreq"], classifiers=["DummyClassifier", "LDA", "LogisticRegression", "SVM", "DecisionTree", "RandomForest", "GradientBoosting"])
    # classifiers_to_eval = Classifiers(n_chans=3, n_outputs=2, n_times=512, sfreq=epochs.info["sfreq"], classifiers=["DummyClassifier", "GradientBoosting"])
    n_folds=10
    for name, model, params in classifiers_to_eval:
        print(f"Running hyperparameter tuning for {name}")

        # Run hyperparameter
        try:    
            # clf = RandomizedSearchCV(
            clf = GridSearchCV(
                model,
                params,
                # param_distributions=params,
                # cv=LeaveOneGroupOutCustom(),
                cv=StratifiedKFold(n_folds, shuffle=True, random_state=42),
                # cv=StratifiedGroupKFold(5, shuffle=True, random_state=42),
                # cv=LeaveOneGroupOut(),
                # cv=GroupKFold(len(np.unique(train_groups))),
                scoring=scoring,
                return_train_score=False,
                verbose=1,
                n_jobs=1,
                error_score=-np.inf,
                # n_iter=3,
            )

            if does_classifier_use_features(model):
                clf.fit(x_train_features, y_train, groups=train_groups)
            else:
                clf.fit(x_train, y_train, groups=train_groups)
        except Exception as e:
            print(f"Error processing {name}: {e}")
            continue

        print(f"Processing with model: {name}")
        print(f"Completed {name}. Mean score: {clf.best_score_:.2f}")
        trained_classifiers[name] = clf

        if clf.best_score_ > best_score:
            best_score = clf.best_score_
            best_classifier = name
            best_params = clf.best_params_
            print(f"New best classifier found: {best_classifier} with score: {best_score}")

    # Add 95% confidence intervals to cv_results_ for all trained classifiers
    for name, clf in trained_classifiers.items():
        cv_results = clf.cv_results_
        split_keys = [key for key in cv_results.keys() if key.startswith('split') and key.endswith('_test_score')]
        
        if split_keys:
            split_scores = np.array([cv_results[key] for key in split_keys]).T
            cv_results['95%_lower'] = np.percentile(split_scores, 2.5, axis=1)
            cv_results['95%_upper'] = np.percentile(split_scores, 97.5, axis=1)

    # Save the hyperparameter tuning results
    results_director.build_hyperparameter_tuning_results(
        classifiers=trained_classifiers,
        x_train_features=x_train_features,
        x_train=x_train,
        y_train=y_train,
        class_names=classes.keys(),
        feature_names=feature_names,
    )

    # Run baseline evaluation with shuffled labels using StratifiedKFold
    # Use the best model for baseline comparison (this is just for generating baseline performance)
    baseline_results = run_baseline_cv_with_shuffled_labels(
        best_model=trained_classifiers[best_classifier].best_estimator_,
        best_params=best_params,
        features=features,
        labels=labels,
        participant_ids=participant_ids,
        results_director=results_director,
        scoring=scoring,
        epochs_data=epochs_data,
        does_use_features=does_classifier_use_features(trained_classifiers[best_classifier].best_estimator_),
        n_folds=n_folds,
        random_state=42
    )

    # Perform statistical tests for all trained classifiers
    all_statistical_results = perform_statistical_tests(
        trained_classifiers=trained_classifiers,
        baseline_results=baseline_results,
        results_director=results_director,
    )

    # Train the best model on the entire training set
    best_model = trained_classifiers[best_classifier].best_estimator_
    best_model.set_params(**best_params)

    # Run leave one group out evaluation
    print("\n=== Leave One Group Out Evaluation ===")
    print(
        f"Best model: {best_classifier} with parameters: {best_params}."
    )
    
    # Prepare condition mapping for later use
    condition_mapping = {v: k for k, v in epochs.event_id.items()}
    
    logo_accuracies = []
    if does_classifier_use_features(best_model):
        X_scaled = features.copy()
        X_scaled[:, :-4] = StandardScaler().fit_transform(X_scaled[:, :-4])
    else:
        X_scaled = epochs_data

    all_predictions = []
    all_labels = []
    all_indices = []
    for fold, (train_idx, test_idx) in enumerate(LeaveOneGroupOut().split(X_scaled, labels, participant_ids), 1):
        fold_model = clone(best_model)
        fold_model = fold_model.set_params(**best_params)

        fold_model.fit(X_scaled[train_idx], labels[train_idx])
        predictions = fold_model.predict(X_scaled[test_idx])
        all_predictions.extend(predictions)
        all_labels.extend(labels[test_idx])
        all_indices.extend(test_idx)

        acc = accuracy_score(labels[test_idx], predictions)
        logo_accuracies.append(acc)
        print(f"Fold {fold} (Participant {participant_ids[test_idx][0]}): Accuracy = {acc:.4f}")
        
        # Create a separate results director for this fold
        fold_results_director = ResultsDirector(
            builders=[LocalBuilder()],
            results_root=f"/tmp/amblyopia_results_v15_{"_".join(test_participant_ids)}/fold_{fold}_participant_{participant_ids[test_idx][0]}",
        )
        
        # Save the evaluation results for this fold
        fold_results_director.build_evaluation_results(
            best_classifier=fold_model,
            X=features,
            X_features=features,
            y=labels,
            groups=participant_ids,
            test_indices=test_idx,
            train_indices=train_idx,
            y_pred=predictions,
            class_names=classes.keys(),
            feature_names=feature_names,
            target_class=classes["Amblyopia"],
            scoring=scoring,
            channel_grouping=channel_grouping,
            montage=epochs.get_montage(),
        )
        
        # Save overall performance for this fold
        fold_save_fp = os.path.join(fold_results_director.results_root, "other")
        os.makedirs(fold_save_fp, exist_ok=True)
        
        # Get participant experiment IDs for this fold
        fold_metadata = epochs.metadata.iloc[test_idx].copy()
        fold_participant_experiment_ids = (
            fold_metadata["participant_id"]
            + "_"
            + fold_metadata["experiment_condition"]
            .map(condition_mapping)
            .str.replace(" ", "_")
        ).to_numpy()
        
        save_overall_performance(
            fold_save_fp,
            np.array(predictions),
            np.array(labels[test_idx]),
            fold_participant_experiment_ids,
            np.arange(len(predictions)).tolist(),
            f"fold_{fold}_participant_{participant_ids[test_idx][0]}_performance_metrics",
        )
        
    print(f"Mean Accuracy: {np.mean(logo_accuracies):.4f} ± {np.std(logo_accuracies):.4f}")

    # Run baseline evaluation and statistical testing for LOGO results
    print("\n=== Running Statistical Tests for LOGO Results ===")
    
    # Run baseline evaluation with shuffled labels using LeaveOneGroupOut
    logo_baseline_results = run_baseline_cv_with_shuffled_labels(
        best_model=best_model,
        best_params=best_params,
        features=features,
        labels=labels,
        participant_ids=participant_ids,
        results_director=results_director,
        scoring=scoring,
        epochs_data=epochs_data,
        does_use_features=does_classifier_use_features(trained_classifiers[best_classifier].best_estimator_),
        n_folds=len(np.unique(participant_ids)),  # Use LOGO - one fold per participant
        random_state=42,
        use_logo=True  # Flag to use LeaveOneGroupOut instead of StratifiedKFold
    )

    # Create LOGO-based trained classifiers dict for statistical testing
    # Only process the best performing classifier
    class MockClassifier:
        def __init__(self, cv_results, best_index):
            self.cv_results_ = cv_results
            self.best_index_ = best_index
    
    # Create cv_results for the best classifier using actual LOGO results
    cv_results = {
        f'split{i}_test_score': [logo_accuracies[i]]
        for i in range(len(logo_accuracies))
    }
    
    logo_trained_classifiers = {best_classifier: MockClassifier(cv_results, 0)}

    # Perform statistical tests using LOGO results
    logo_statistical_results = perform_statistical_tests(
        trained_classifiers=logo_trained_classifiers,
        baseline_results=logo_baseline_results,
        results_director=results_director,
        test_suffix="_logo",
    )

    # Save results split by amblopia/normal and experiment condition
    metadata = epochs.metadata.copy()
    metadata["participant_experiment_id"] = (
        metadata["participant_id"]
        + "_"
        + metadata["experiment_condition"]
        .map(condition_mapping)
        .str.replace(" ", "_")
    )

    save_fp = os.path.join(results_director.results_root, "other")
    os.mkdir(save_fp)

    # Use the saved indices to get the corresponding metadata
    all_participant_experiment_ids = metadata["participant_experiment_id"].iloc[all_indices].to_numpy()

    save_overall_performance(
        save_fp,
        np.array(all_predictions),
        np.array(all_labels),
        all_participant_experiment_ids,
        np.arange(8).tolist(),  # Not important
        "participant_vs_condition_performance_metrics",
    )

    # mcc = matthews_corrcoef(y_test, predictions)
    # accuracy = accuracy_score(y_test, predictions)

    # print(
    #     f"Best model: {best_classifier} with parameters: {best_params} has a MCC: {mcc:.2f}, accuracy: {accuracy:.2f}"
    # )

if __name__ == "__main__":
    # Define test participant IDs
    # main(["a3", "a6", "c13"])
    # main(["a7", "c15"])
    # main(["a4", "c12"])
    # main(["a9", "c14"])
    # main(["a1", "c1"])
    # main(["a8", "c11"])

    # main(["a8", "a4", "c15"])
    # main(["a6", "c13"])
    # main(["a9", "c1"])
    # main(["a1", "c12"])

    main(["a6", "a8", "a9", "c13", "c14", "c15"], exclude=["a7"])
    # main(["a7", "a8", "a9", "c13", "c14", "c15"])
