function plotCombinedReactivityHistograms(reactivityResults)
    % Extract reactivities from reactivityResults
    fields = fieldnames(reactivityResults);
    EO_EC_reactivities_A = [];
    EO_DEC_reactivities_A = [];
    EO_NDEC_reactivities_A = [];
    EO_EC_reactivities_C = [];
    EO_DEC_reactivities_C = [];
    EO_NDEC_reactivities_C = [];

    % Separate data by group
    for i = 1:numel(fields)
        key = fields{i};
        if startsWith(key, 'A')
            data = reactivityResults.(key);
            EO_EC_reactivities_A = [EO_EC_reactivities_A, data.reactivity_EO_EC];
            EO_DEC_reactivities_A = [EO_DEC_reactivities_A, data.reactivity_EO_DEC];
            EO_NDEC_reactivities_A = [EO_NDEC_reactivities_A, data.reactivity_EO_NDEC];
        elseif startsWith(key, 'C')
            data = reactivityResults.(key);
            EO_EC_reactivities_C = [EO_EC_reactivities_C, data.reactivity_EO_EC];
            EO_DEC_reactivities_C = [EO_DEC_reactivities_C, data.reactivity_EO_DEC];
            EO_NDEC_reactivities_C = [EO_NDEC_reactivities_C, data.reactivity_EO_NDEC];
        end
    end

    % Define bin width
    binWidth = 2;

    % Create histograms with different colors for A and C groups
    figure;
    subplot(3,1,1);
    histogram(EO_EC_reactivities_A, 'BinWidth', binWidth, 'Normalization', 'probability', 'FaceColor', 'b');
    hold on;
    histogram(EO_EC_reactivities_C, 'BinWidth', binWidth, 'Normalization', 'probability', 'FaceColor', 'r');
    hold off;
    legend('Amblyopia', 'Control');
    title('Histogram of EO-EC Reactivity');
    ylabel('Percentage (%)');
    ylim([0 0.6]);
    xlim([-30 10]); % Set x-axis limits
    set(gca, 'XDir', 'reverse'); % Invert x-axis

    subplot(3,1,2);
    histogram(EO_DEC_reactivities_A, 'BinWidth', binWidth, 'Normalization', 'probability', 'FaceColor', 'b');
    hold on;
    histogram(EO_DEC_reactivities_C, 'BinWidth', binWidth, 'Normalization', 'probability', 'FaceColor', 'r');
    hold off;
    legend('Amblyopia', 'Control');
    title('Histogram of EO-DEC Reactivity');
    ylabel('Percentage (%)');
    ylim([0 0.6]);
    xlim([-30 10]); % Set x-axis limits
    set(gca, 'XDir', 'reverse'); % Invert x-axis

    subplot(3,1,3);
    histogram(EO_NDEC_reactivities_A, 'BinWidth', binWidth, 'Normalization', 'probability', 'FaceColor', 'b');
    hold on;
    histogram(EO_NDEC_reactivities_C, 'BinWidth', binWidth, 'Normalization', 'probability', 'FaceColor', 'r');
    hold off;
    legend('Amblyopia', 'Control');
    title('Histogram of EO-NDEC Reactivity');
    ylabel('Percentage (%)');
    xlabel('Reactivity (dB)');
    ylim([0 0.6]);
    xlim([-30 10]); % Set x-axis limits
    set(gca, 'XDir', 'reverse'); % Invert x-axis

    % Adjust Y-axis labels to show percentage
    axes = findobj(gcf,'Type','axes');
    for ax = axes'
        ax.YAxis.Exponent = 0;
        yt = ax.YTick;
        ax.YTickLabel = yt*100;
    end
end
