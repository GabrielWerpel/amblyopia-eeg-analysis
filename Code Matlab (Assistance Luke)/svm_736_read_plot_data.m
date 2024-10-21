% Data from Ben-Hur et al. (2008), PLoS Computational Biology.
DAT = [13.9562   93.4537  -1;
       10.8420   57.6749  -1;
       10.9573    5.4176  -1;
       31.0265   82.3928  -1;
       17.7624   48.3070  -1;
       35.1788   72.2348  -1;
       33.2180   59.1422  -1;
       43.2526   61.9639  -1;
       67.1280   68.7359  -1;
       76.3552   91.1964  -1;
       39.2157   23.1377   1;
       42.0992   11.2867   1;
       70.3576   31.3770   1;
       79.5848   24.0406   1];

fh1 = figure; hold on
for ii = 1:size(DAT,1)
  marker_color = 'black';
  if (DAT(ii,3) == -1), marker_color = 'blue'; end
  plot(DAT(ii,1), DAT(ii,2), 'ow', 'MarkerFaceColor', marker_color, 'MarkerSize', 8); axis square
end
axis([0 100 0 100])
xlabel('Feature x_1')
ylabel('Feature x_2')
