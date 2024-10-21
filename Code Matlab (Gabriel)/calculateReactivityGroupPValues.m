function calculateReactivityGroupPValues(reactivityResults)
    % Check if reactivityResults is empty
    if isempty(reactivityResults)
        disp('No reactivity results available.');
        return;
    end

    % Initialize arrays to store reactivities
    reactivity_A_EC_EO = [];
    reactivity_C_EC_EO = [];
    reactivity_A_DEC_EO = [];
    reactivity_C_DEC_EO = [];
    reactivity_A_NDEC_EO = [];
    reactivity_C_NDEC_EO = [];

    % Extract reactivities into arrays based on group keys
    fields = fieldnames(reactivityResults);
    for i = 1:numel(fields)
        key = fields{i};
        if startsWith(key, 'A')
            reactivity_A_EC_EO = [reactivity_A_EC_EO; reactivityResults.(key).reactivity_EO_EC];
            reactivity_A_DEC_EO = [reactivity_A_DEC_EO; reactivityResults.(key).reactivity_EO_DEC];
            reactivity_A_NDEC_EO = [reactivity_A_NDEC_EO; reactivityResults.(key).reactivity_EO_NDEC];
        elseif startsWith(key, 'C')
            reactivity_C_EC_EO = [reactivity_C_EC_EO; reactivityResults.(key).reactivity_EO_EC];
            reactivity_C_DEC_EO = [reactivity_C_DEC_EO; reactivityResults.(key).reactivity_EO_DEC];
            reactivity_C_NDEC_EO = [reactivity_C_NDEC_EO; reactivityResults.(key).reactivity_EO_NDEC];
        end
    end

    % Calculate p-values using t-test
    [h1, p1] = ttest2(reactivity_A_EC_EO, reactivity_C_EC_EO);
    [h2, p2] = ttest2(reactivity_A_DEC_EO, reactivity_C_DEC_EO);
    [h3, p3] = ttest2(reactivity_A_NDEC_EO, reactivity_C_NDEC_EO);
    
    % Display p-values
    fprintf('P-value between A and C groups for EC-EO: %f\n', p1);
    fprintf('P-value between A and C groups for DEC-EO: %f\n', p2);
    fprintf('P-value between A and C groups for NDEC-EO: %f\n', p3);
end
