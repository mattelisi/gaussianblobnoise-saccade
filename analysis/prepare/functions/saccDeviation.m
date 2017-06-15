function [P, R2, out] = saccDeviation(X,Y)
%
% Compute saccade deviation with a curve-fitting approach (Ludwig & Gilchrist, 2002).
% 
% Saccade are first rotated and x-values are rescaled in the range [-1 1]. 
% The output consist in the quadratic curvature of the saccade, in the 
% given units (first value) and in the R-squared of the polynomial fit (second value).
% 
% NB. a positive value indicate a clockwise change in saccade direction (i.e.,
%     the trajectory has a counterclockwise bump)
%
%
% Reference:
%
%   Ludwig, C. J. H., & Gilchrist, I. D. (2002). 
%   Measuring saccade curvature: a curve-fitting approach. 
%   Behavior research methods, instruments, & computers, 34(4), 618?24. 
%   http://www.ncbi.nlm.nih.gov/pubmed/12564565
%
%
% Matteo Lisi, 2013
%

 % rotate saccade in order to have an horizontal-rightward saccade
 [theta_dev, rho_dev] = cart2pol(X - X(1), Y - Y(1));
 [Xh, Yh] = pol2cart(theta_dev-theta_dev(end), rho_dev);
 
 % rescale horizontal values in the range [-1 1]
 range = max(Xh) - min(Xh);
 Xhn = 2*((Xh - min(Xh))/range) - 1;
 
 % fit the second order polynomial and determine curvature
 coeff = polyfit(Xhn, Yh, 2);
 P = - coeff(1);    % change sign for consistence with sacc2mov experiment design
                    % a positive value --> clockwise change in direction
 
 % compute R squared
 predicted = coeff(1)*Xhn.^2 + coeff(2)*Xhn + coeff(3);
 R2 = (corr(predicted,Yh)^2);
 
 % exhaustive output structure
 out.coeff = coeff;
 out.Xh = Xh;
 out.Yh = Yh;
 out.Xh_n = Xhn;
 out.predicted = predicted;
 
end