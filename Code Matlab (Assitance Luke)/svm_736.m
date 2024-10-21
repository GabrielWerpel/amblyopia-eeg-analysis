% This Matlab script aims to provide a practical introduction to the use of
% support-vector machines for classification.

% The first two columns of our data matrix, DAT, locate each observation in our
% 2D feature space, (x1, x2). The third colum is each observation's class
% label, that is, either 1 or -1. Notice that our data are linearly separable.
run svm_736_read_plot_data.m

% A simple approach is to fit a linear-kernel SVM with a so-called "hard
% margin". The Matlab function fitcsvm() returns a ClassificationSVM object
% which has associated methods and properties.  A SVM finds a decision boundary
% such that the margin between class 1 observations and class 2 observations is
% maximized. We'll visualize the margin in just a moment...
svm = fitcsvm(DAT(:,1:2), DAT(:,3), 'KernelFunction', 'linear');

% Let's now visualize the SVM that we just fit to our data. 
%
% Because this is a hard-margin SVM, and our data are linearly separable, the
% support vectors will mark the edges of the margin. 
%
% First, we plot the support vectors as squares in our 2D feature space.
% Notice, here, there are three support vectors, and those are specified in our
% ClassificationSVM object that we've called "svm".
%
% Second, we plot the decision regions determined by our linear-kernel SVM
% fit. If new observations came to hand, and they were to be plotted in this 2D
% features space, they would be categorized by this SVM according to which
% decision region they landed in.
%
% The (hard) margin is the space between our two (linearly separable) samples -
% black and blue. Notice that none of our data fall in the margin, but that our
% three support vectors sit exactly at the margin's edge. 
run svm_736_visualize.m

% Now, let's repeat the process, but we'll soften the margin, effectively
% fitting a different linear-kernel SVM. When we soften the margin, we make use
% of more support vectors, and observations are allowed to fall within the
% margin.
clear
run svm_736_read_plot_data.m

% In practical terms, the margin is softened by reducing the value of the
% hyperparameter 'BoxConstraint'. The default value for this hyperparameter is
% 1, but here we'll lower it to 0.001 to see the effects -- the resulting
% margin is wider, there are more support vectors (six in fact) used to define
% the decision boundary, and observations are allowed to fall within the
% margin. Notice also that one of the blue data points (lower, left in the
% feature space) is incorrectly classified.
%
% Why would we soften the margin? We might do so because we believed that
% softening the margin would improve our classifier's ability to generalize,
% that is, to accurately predict the class membership of previously unseen
% data.
svm = fitcsvm(DAT(:,1:2), DAT(:,3), 'KernelFunction', 'linear', 'BoxConstraint', 0.001);

%
run svm_736_visualize.m

% Now, let's use a polynomial-kernel SVM, specifically, a second-order (ie.,
% quadratic) kernel, which results in a quadratic decision boundary.  Ask
% youself these questions: How many support vectors result?  What is the shape
% of the decision boundary?
clear
run svm_736_read_plot_data.m

svm = fitcsvm(DAT(:,1:2), DAT(:,3), 'KernelFunction', 'polynomial', 'PolynomialOrder', 2);

run svm_736_visualize.m

