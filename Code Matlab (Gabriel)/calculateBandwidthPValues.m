function calculateBandwidthPValues(bandwidthResults)
    % Check if bandwidthResults is empty
    if isempty(bandwidthResults)
        disp('No bandwidth results available.');
        return;
    end

    % Extract bandwidths into arrays
    fields = fieldnames(bandwidthResults);
    bandwidth_EO = [];
    bandwidth_EC = [];
    bandwidth_DEC = [];
    bandwidth_NDEC = [];
    
    for i = 1:numel(fields)
        bandwidth_EO = [bandwidth_EO; bandwidthResults.(fields{i}).EO.bandwidth];
        bandwidth_EC = [bandwidth_EC; bandwidthResults.(fields{i}).EC.bandwidth];
        bandwidth_DEC = [bandwidth_DEC; bandwidthResults.(fields{i}).DEC.bandwidth];
        bandwidth_NDEC = [bandwidth_NDEC; bandwidthResults.(fields{i}).NDEC.bandwidth];
    end
    
    % Calculate p-values using t-test, assuming equal variances
    [h1, p1] = ttest2(bandwidth_EC, bandwidth_DEC);
    [h2, p2] = ttest2(bandwidth_EC, bandwidth_NDEC);
    [h3, p3] = ttest2(bandwidth_DEC, bandwidth_NDEC);
    [h4, p4] = ttest2(bandwidth_EO, bandwidth_EC);
    [h5, p5] = ttest2(bandwidth_EO, bandwidth_DEC);
    [h6, p6] = ttest2(bandwidth_EO, bandwidth_NDEC);
    
    % Display p-values
    fprintf('P-value between EC and DEC bandwidths: %f\n', p1);
    fprintf('P-value between EC and NDEC bandwidths: %f\n', p2);
    fprintf('P-value between DEC and NDEC bandwidths: %f\n', p3);
    fprintf('P-value between EO and EC bandwidths: %f\n', p4);
    fprintf('P-value between EO and DEC bandwidths: %f\n', p5);
    fprintf('P-value between EO and NDEC bandwidths: %f\n', p6);
end
