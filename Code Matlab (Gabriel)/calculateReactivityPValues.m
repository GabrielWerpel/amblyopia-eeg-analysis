function calculateReactivityPValues(reactivityResults)
    % Check if reactivityResults is empty
    if isempty(reactivityResults)
        disp('No reactivity results available.');
        return;
    end

    % Extract reactivities into arrays
    fields = fieldnames(reactivityResults);
    reactivity_EC_EO = [];
    reactivity_DEC_EO = [];
    reactivity_NDEC_EO = [];
    
    for i = 1:numel(fields)
        reactivity_EC_EO = [reactivity_EC_EO; reactivityResults.(fields{i}).reactivity_EO_EC];
        reactivity_DEC_EO = [reactivity_DEC_EO; reactivityResults.(fields{i}).reactivity_EO_DEC];
        reactivity_NDEC_EO = [reactivity_NDEC_EO; reactivityResults.(fields{i}).reactivity_EO_NDEC];
    end
    
    % Calculate p-values using t-test, assuming equal variances
    [h1, p1] = ttest2(reactivity_EC_EO, reactivity_DEC_EO);
    [h2, p2] = ttest2(reactivity_EC_EO, reactivity_NDEC_EO);
    [h3, p3] = ttest2(reactivity_DEC_EO, reactivity_NDEC_EO);
    
    % Display p-values
    fprintf('P-value between EC-EO and DEC-EO: %f\n', p1);
    fprintf('P-value between EC-EO and NDEC-EO: %f\n', p2);
    fprintf('P-value between DEC-EO and NDEC-EO: %f\n', p3);
end
