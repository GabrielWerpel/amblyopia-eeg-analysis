% Support vectors as square on original plot of data
figure(fh1);
for ii = 1:size(svm.SupportVectors,1)
  aa = svm.SupportVectors(ii,:);
  marker_color = 'black';
  if (svm.SupportVectorLabels(ii) == -1), marker_color = 'blue'; end 
  plot(aa(1), aa(2), 'sw', 'MarkerFaceColor', marker_color, 'MarkerSize', 12);
end

% Decision regions
[X1,X2] = meshgrid(linspace(0,100,1000));
X1 = X1(:);
X2 = X2(:);
[label, score] = predict(svm, [X1 X2]);
R = reshape(label, [1000 1000]);
figure; hold on
imagesc(R); axis image off; colormap([0 0 1; 0 0 0]) 
title('Decision regions - blue and black')

% Margin
R = reshape(score(:,2), [1000 1000]);
figure; hold on
imagesc(double((R >= -1) & (R <= 1)), [0 1]); axis image off; colormap([1 1 1; 0.5 0.5 0.5])
title('Margin - grey')
