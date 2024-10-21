% Define feature labels as a column cell array
feature_labels = {'O1_EC'; 'Oz_EC'; 'O2_EC'; 'O1_EO'; 'Oz_EO'; 'O2_EO'; 'O1_DEC'; 'Oz_DEC'; 'O2_DEC'; 'O1_NDEC'; 'Oz_NDEC'; 'O2_NDEC'};

% Colors for plotting (if needed).
COL1 = [27 158 119] ./ 255;  % Color 1 (normalized RGB values)
COL2 = [217 95 2] ./ 255;    % Color 2
COL3 = [117 112 179] ./ 255; % Color 3

% 'all_features' is a matrix where:
% - Each column represents a different feature extracted from EEG signals.
% - Features include conditions like Eyes Closed (EC), Eyes Open (EO), Dominant Eye Closed (DEC),
%   Non-Dominant Eye Closed (NDEC) for electrodes O1, Oz, and O2.
% - Each row corresponds to a 2-second segment from a subject.
% - There are 4 segments per subject (since recordings are divided into 2-second segments).

% Load the feature matrix (this should be the result from the previous code)

all_features = [   18.2193    3.2387    8.6311    8.0677   18.0929    4.0563    7.6432    7.7959   21.4995    3.7339    8.1478    8.0539;
   18.9329   -4.5905    4.0133    6.6763   16.3359   -2.7231    2.7880    6.8159   19.8275    1.0520    3.4324    8.5240;
   16.1264    1.6297    6.6151    7.6979   15.9287    1.9558    6.1645    7.8736   18.4037    1.5200    5.5405   10.9175;
   14.5559    5.4939    9.2065   10.4506   13.1098    5.1056   10.5291    8.8815   19.2392    7.8108   12.5895    9.0186;
   13.5806    5.0531    6.9747    5.3095   15.2070   10.8779   10.2620    6.8453   17.1912   10.1477   10.8114    5.0609;
    7.5768    2.3768    6.5293    5.5459   13.7829    6.6478    6.3081    8.7192   17.6923    4.2830    6.6066    7.9348;
   12.4723    6.7851    6.7986    2.5224   20.8212   11.8927    9.4008    5.9690   23.7775   10.4932   12.8695    5.2635;
    7.6996    7.1289    8.0890   11.5928   13.3104    7.4362    6.2821    8.8137   14.4649    7.5862   10.4569    8.6643;
   24.8604    0.0170    8.0923    4.6773   27.0528    1.1963    8.5506    6.9357   28.0720    2.0804    5.1407    9.4782;
   24.6713    8.4925    5.8588    3.3065   29.1508    9.9872    5.5338    7.3206   24.3445    9.0398    3.4194   10.9208;
   19.7509    5.3878    6.7870    4.1370   21.4991   13.2933   10.4084    7.0682   17.5788   10.9853    7.5945    6.3135;
   19.9124    6.5906    8.1882    3.8684   21.8226    8.6423    9.2607    5.4577   18.5841   10.5732    8.8701    5.8410;
   25.4897   12.0392    0.7825    9.4110   22.3366   10.6701    2.0066   10.8832   21.7090    6.1307    4.0710   12.1761;
   21.6161   10.9272    7.9867   14.1027   20.2472   11.6141   10.6112   13.0275   20.8457   10.1022    9.9450   13.4637;
   21.3411   12.8232    8.8751   11.4454   21.4376   12.3360   13.0682   11.1675   19.0153   10.2104   13.4556    8.9088;
   20.6011    9.9866    9.5343   13.9106   16.7092   11.2231    8.7644   14.3660   15.0399    9.4339   10.1736   12.4960;
    9.4841    9.3639    3.8587    7.9770    5.8359    8.6052    6.8837    4.0441    4.3930    7.1693    7.2947    3.8124;
   12.3280    7.5110    7.4132    8.3318    9.7291    5.2925    7.0218    6.9171    9.9221    2.6197    6.1219    7.4443;
   11.6075   12.5692    4.9532    6.6324   11.7291   14.1274    6.1392    6.1842   10.4357   12.6168    5.1370    6.4747;
   11.5539    9.5581    9.3135    8.5266   11.2706   10.0072    5.7679    9.2713   10.5405   10.6060    6.2620    9.8669;
   19.3323   10.2834    7.5744   14.3786   17.8834    8.6295    7.5029   13.6158   17.9823    6.3688    7.3284   10.2921;
   18.4865    7.8131    8.2575   12.9100   17.1745    5.8733    6.1459   11.8068   19.1187    5.1717    4.7980    7.3293;
   18.4345    9.7963    7.7374    7.2494   18.6819    7.3894    6.3486    6.9660   23.1289    5.8240    5.8086    5.2521;
   17.8140   12.2648    7.3713   11.4903   17.8167   11.7726    7.3765    9.4929   16.8171   10.8124    5.1541    7.7112;
   12.4276    9.2432    3.5698    7.1786   25.1189   13.8725   15.8182    6.3265   27.0071   12.4821   17.0860    5.2811;
   17.0568    4.3459    8.4969    5.0680   25.1578   10.7406   16.5371    9.1080   23.8717   10.0648   15.0988    8.4495;
   16.0860    8.2539    9.5923    8.4828   24.8430   13.2521   10.6559    6.6914   22.6531   11.2773    7.5754    4.6250;
   16.3359    7.7538    6.5958    4.7841   24.5567   13.4125   11.8507   13.6258   26.2110   14.1589   13.7205   13.9355;
   12.1019    5.5329    4.1199    3.2821   12.0673    6.5734    3.9694    1.7577   18.3649   11.7580    9.2212    8.4539;
   22.3908    9.4918    2.6206    9.8993   19.1054   12.5291    1.7460    8.3116   23.4944   11.1868    4.6174   13.0078;
   15.7189    3.7913    4.5007    6.6620   15.0021    4.5928    3.2067    5.3714   20.2099    8.5455    5.4102   10.7068;
   16.0759    8.1442    3.6528    5.9524   13.6811    5.3734    3.2296    3.9601   17.9147   10.9920    9.9790    6.5713;
   10.9311   12.3936   -0.7544    7.9094   11.4319   12.2274    3.2627   10.0998   10.8919   13.2997    4.3626    9.4991;
   16.4478   10.7356    2.9795    6.5317   15.9880   11.2684    5.1543    7.9503   14.5123   10.2987    7.2719    9.1254;
    8.6785   15.4467   -1.7851    5.6229    6.7361   11.9263    0.3750    7.9107    7.5087    8.3849    0.3739    8.8990;
   15.9215    9.7968    7.6319    7.6398   14.6140   11.4885    9.4401    7.6799   12.0675   11.7247    9.5967    7.9322;
   11.9966   15.1394    4.8413    7.6172   14.4360   11.0455    2.9791    6.6545   15.2024   12.4033    5.9853    5.6426;
   21.0878    8.3919    7.5867    7.9276   21.4210   11.4569    7.2433    8.3489   23.3692   11.2101    7.4018    9.2184;
   19.8645   12.3711   11.1142    9.4017   23.7726   11.0998   11.6834    9.4629   23.9401   11.0809   13.7889    8.4820;
   19.1246    7.2945    7.0455    8.1888   21.4076    6.9358    7.6271   12.3330   22.2090    7.1746   10.3646   10.4045;
   24.1768   11.0937    5.4048    6.5690   24.6402   10.2920    4.9382    6.0255   25.1472    8.8387    4.4362    5.3253;
   22.7649    9.6141    4.3538   10.2719   23.5086    8.6730    4.4349    9.5012   25.0422    8.9645    3.3368    6.8094;
   25.1532    7.5248   10.6956    7.2716   28.3025   12.0581    8.9123    7.5554   28.2605    8.5528    7.0420    3.7861;
   24.7829   14.3632    6.0860    4.6610   22.4160   15.4357    7.2988    4.3828   23.4157   11.6348    4.3424    3.3357;
    9.7766    3.9303    6.6868    2.1178    8.8635    5.8152    8.4675    4.0157   14.5843   11.7356   11.0462    4.8277;
    7.2287    0.1462    7.9259    3.1578    8.8019    1.9030    8.0252    4.1014   13.2438   10.4879   11.0934    7.4712;
    4.6210    9.7509    5.7928    2.3179    6.0472    9.5561    7.2287    0.7298    9.5310   15.3513   13.0791    0.4407;
   10.0614    5.1382    7.4617    6.5731   10.0573    2.8105    5.8021    6.5556   13.7505    7.0533    7.9653    9.7444;
   21.1809    9.4640    8.6746    9.2378   19.8027   11.0801    9.5078   11.6717   14.7181    7.2517    9.9784   12.4849;
   21.7863    8.8790   12.9038    9.2272   22.4801    9.9764   11.9926   12.4226   20.2519   12.1044   11.3215   10.5502;
   19.6970   13.5929    9.2540    9.4875   18.8757   12.6579   10.0605    7.5702   19.5031   13.1201    8.0194    9.4247;
   25.4426   12.2197   11.1266   12.5628   23.7820   12.3505   11.1218   11.6368   24.8738   11.6497   13.5013   11.9669];

% Define class labels:
% - There are 7 Amblyopia patients (coded as 1) and 6 Control subjects (coded as 0).
% - Each subject has 4 segments, so we multiply by 4.
class_division = [ones(7*4, 1); zeros(6*4, 1)];

% Check for NaN or Inf values in data
if any(isnan(all_features(:))) || any(isinf(all_features(:)))
    error('Data contains NaN or Inf values. Please clean the data before proceeding.');
end

% Define the feature indices to be used for classification.
% Consider all combinations of 2 features from 12.
IX_FEATURES_ = nchoosek(1:12, 2);

% Initialize an array to store classification results.
all_results = [];

% Set up cross-validation partition
cv = cvpartition(class_division, 'LeaveOut');

% Loop over each set of feature indices.
for ix_feat = 1:size(IX_FEATURES_, 1)
    
    % Select the current set of features.
    IX_FEATURES = IX_FEATURES_(ix_feat, :);
    
    % Extract the data for the selected features.
    data = all_features(:, IX_FEATURES);
    
    % Initialize arrays to store metrics for each fold
    accuracies = zeros(cv.NumTestSets, 1);
    
    % Initialize arrays to store true labels and predictions across all folds
    y_true_all = [];
    y_pred_all = [];
    
    % Loop over each fold (Leave-One-Out Cross-Validation)
    for i = 1:cv.NumTestSets
        trainIdx = cv.training(i);
        testIdx = cv.test(i);
        
        % Training and test data
        X_train = data(trainIdx, :);
        y_train = class_division(trainIdx);
        X_test = data(testIdx, :);
        y_test = class_division(testIdx);
        
        % Train Random Forest classifier
        numTrees = 10; % Adjust the number of trees as needed
        rfModel = TreeBagger(numTrees, X_train, y_train, 'Method', 'classification', 'OOBPrediction', 'off');
        
        % Predict on test data
        [y_pred, ~] = predict(rfModel, X_test);
        y_pred = str2double(y_pred); % Convert cell array to numeric
        
        % Store true labels and predictions
        y_true_all = [y_true_all; y_test];
        y_pred_all = [y_pred_all; y_pred];
        
        % Compute accuracy for this fold
        accuracy = 100 * sum(y_pred == y_test) / length(y_test);
        
        % Store accuracy
        accuracies(i) = accuracy;
    end
    
    % After cross-validation, compute confusion matrix components
    tp = sum((y_true_all == 1) & (y_pred_all == 1));
    tn = sum((y_true_all == 0) & (y_pred_all == 0));
    fp = sum((y_true_all == 0) & (y_pred_all == 1));
    fn = sum((y_true_all == 1) & (y_pred_all == 0));
    
    % Calculate performance metrics using aggregated data
    avg_accuracy = mean(accuracies);
    mcc = ((tp * tn) - (fp * fn)) / sqrt((tp + fp)*(tp + fn)*(tn + fp)*(tn + fn) + eps);
    sensitivity = 100 * tp / (tp + fn + eps);
    specificity = 100 * tn / (tn + fp + eps);
    
    % Store the results: [Accuracy, MCC, Sensitivity, Specificity, Feature Indices]
    all_results = [all_results; [avg_accuracy, mcc, sensitivity, specificity, IX_FEATURES]];
end

% Sort the results based on MCC and Accuracy for display.
all_results = sortrows(all_results, [-2, -1]); % Sort by MCC (descending), then Accuracy

% Convert feature indices to labels
feature1_labels = feature_labels(all_results(:,5));
feature2_labels = feature_labels(all_results(:,6));

% Ensure feature labels are column vectors
feature1_labels = feature1_labels(:);
feature2_labels = feature2_labels(:);

% Display the results in a table
results_table = table(all_results(:,1), all_results(:,2), all_results(:,3), all_results(:,4), feature1_labels, feature2_labels, 'VariableNames', {'Accuracy', 'MCC', 'Sensitivity', 'Specificity', 'Feature1', 'Feature2'});
disp('Classification Results using Random Forest:');
disp(results_table);

% Select the best feature combination (first row of sorted results)
best_accuracy = all_results(1, 1);
best_mcc = all_results(1, 2);
best_sensitivity = all_results(1, 3);
best_specificity = all_results(1, 4);
best_features = all_results(1, 5:6);

% Get the labels for the best features
best_feature1_label = feature_labels{best_features(1)};
best_feature2_label = feature_labels{best_features(2)};

disp('Best Feature Combination using Random Forest:');
fprintf('Features: %s and %s\n', best_feature1_label, best_feature2_label);
fprintf('Accuracy: %.2f%%\n', best_accuracy);
fprintf('MCC: %.4f\n', best_mcc);
fprintf('Sensitivity: %.2f%%\n', best_sensitivity);
fprintf('Specificity: %.2f%%\n', best_specificity);

% Proceed to perform the shuffle test using the best feature combination.
% (Shuffle test code would be similar to before, adapted for Random Forest)
