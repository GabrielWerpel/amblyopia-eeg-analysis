function calculateBandwidthGroupPValues(bandwidthResults)
    % Check if bandwidthResults is empty
    if isempty(bandwidthResults)
        disp('No bandwidth results available.');
        return;
    end

    % Initialize arrays to store bandwidths
    bandwidth_A_EO = [];
    bandwidth_C_EO = [];
    bandwidth_A_EC = [];
    bandwidth_C_EC = [];
    bandwidth_A_DEC = [];
    bandwidth_C_DEC = [];
    bandwidth_A_NDEC = [];
    bandwidth_C_NDEC = [];

    % Extract bandwidths into arrays based on group keys
    fields = fieldnames(bandwidthResults);
    for i = 1:numel(fields)
        key = fields{i};
        if startsWith(key, 'A')
            bandwidth_A_EO = [bandwidth_A_EO; bandwidthResults.(key).EO.bandwidth];
            bandwidth_A_EC = [bandwidth_A_EC; bandwidthResults.(key).EC.bandwidth];
            bandwidth_A_DEC = [bandwidth_A_DEC; bandwidthResults.(key).DEC.bandwidth];
            bandwidth_A_NDEC = [bandwidth_A_NDEC; bandwidthResults.(key).NDEC.bandwidth];
        elseif startsWith(key, 'C')
            bandwidth_C_EO = [bandwidth_C_EO; bandwidthResults.(key).EO.bandwidth];
            bandwidth_C_EC = [bandwidth_C_EC; bandwidthResults.(key).EC.bandwidth];
            bandwidth_C_DEC = [bandwidth_C_DEC; bandwidthResults.(key).DEC.bandwidth];
            bandwidth_C_NDEC = [bandwidth_C_NDEC; bandwidthResults.(key).NDEC.bandwidth];
        end
    end

    % Calculate p-values using t-test
    [h1, p1] = ttest2(bandwidth_A_EC, bandwidth_C_EC);
    [h2, p2] = ttest2(bandwidth_A_DEC, bandwidth_C_DEC);
    [h3, p3] = ttest2(bandwidth_A_NDEC, bandwidth_C_NDEC);
    [h4, p4] = ttest2(bandwidth_A_EO, bandwidth_C_EO);
    
    % Display p-values
    fprintf('P-value between A and C groups for EC bandwidth: %f\n', p1);
    fprintf('P-value between A and C groups for DEC bandwidth: %f\n', p2);
    fprintf('P-value between A and C groups for NDEC bandwidth: %f\n', p3);
    fprintf('P-value between A and C groups for EO bandwidth: %f\n', p4);
end
