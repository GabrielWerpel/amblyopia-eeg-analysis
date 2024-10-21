function displaySkewnessResults(skewnessResults)
    % Get the field names
    keys = fieldnames(skewnessResults);

    % Print the header
    fprintf('Key\tGroup\t\tSkewness (0-40 Hz)\t\t\t\t\tSkewness (8-12 Hz)\n');
    fprintf('\t\t\tEC\t\tDEC\t\tNDEC\t\tEO\t\tEC\t\tDEC\t\tNDEC\t\tEO\n');
    fprintf('-----------------------------------------------------------------------------------------------------------------------------------\n');

    % Iterate over each key and print the results
    for i = 1:numel(keys)
        key = keys{i};
        group = skewnessResults.(key).group;
        skewness_0_40 = skewnessResults.(key).skewness_0_40;
        skewness_8_12 = skewnessResults.(key).skewness_8_12;

        fprintf('%s\t%s\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\n', ...
            key, group, ...
            skewness_0_40.EC, skewness_0_40.DEC, skewness_0_40.NDEC, skewness_0_40.EO, ...
            skewness_8_12.EC, skewness_8_12.DEC, skewness_8_12.NDEC, skewness_8_12.EO);
    end
end
