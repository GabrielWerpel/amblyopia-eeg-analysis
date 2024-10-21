function showAllReactivities(reactivityResults)
    % Check if reactivityResults is empty
    if isempty(reactivityResults)
        disp('No reactivity results available.');
        return;
    end
    
    % Get all field names from the reactivityResults structure
    fields = fieldnames(reactivityResults);
    
    % Display the header
    fprintf('%-20s %-15s %-15s %-15s\n', 'Key', 'EC-EO (dB)', 'DEC-EO (dB)', 'NDEC-EO (dB)');
    fprintf('%s\n', repmat('-', 1, 70));
    
    % Iterate through each field to extract and display all reactivities
    for i = 1:numel(fields)
        key = fields{i};
        reactivity_EO_EC = reactivityResults.(key).reactivity_EO_EC;
        reactivity_EO_DEC = reactivityResults.(key).reactivity_EO_DEC;
        reactivity_EO_NDEC = reactivityResults.(key).reactivity_EO_NDEC;
        
        % Print formatted results
        fprintf('%-20s %-15.2f %-15.2f %-15.2f\n', key, reactivity_EO_EC, reactivity_EO_DEC, reactivity_EO_NDEC);
    end
end
