function [c1, c2, out] = saccDeviation_3rd(X,Y)
%
% Compute saccade deviation with a curve-fitting approach (Ludwig & Gilchrist, 2002).
% 
% Saccade are first rotated and x-values are rescaled in the range [-1 1]. 
% 
% This function fit the saccade with a third order polynomial, in order to
% detect double curved ('s-shaped') saccades. The curvature values are
% given by the y-coordinates of the two turning points of the function, if
% these are within the saccade data interval (x = -1:1). When the saccade
% has a single curvature, the second turning point fall outside the saccade
% data interval and a NaN value is given to the second curvature (c2).
%
% 'out' is the full output, including R-squared and fitted values (e.g., for 
% plotting).
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
 
 % fit the third order polynomial
 coeff = polyfit(Xhn, Yh, 3);
 
 % find turning points
 xc1 = (-coeff(2) - sqrt(coeff(2)^2-3*coeff(1)*coeff(3))) / (3*coeff(1));
 xc2 = (-coeff(2) + sqrt(coeff(2)^2-3*coeff(1)*coeff(3))) / (3*coeff(1));
 
 % check order
 if xc2<xc1
     first = xc2;
     xc2 = xc1;
     xc1 = first;
 end
 tp = [xc1, xc2];
 tpval = polyval(coeff, tp);
 
 % check if the x coordinates of turning points are within the range [-1 1]
 inside = ([xc1, xc2] > -1) .* ([xc1, xc2] < 1);
 switch sprintf('%i%i',inside)
     case '10'
         c1 = tpval(find(inside)); %#ok<*FNDSB>
         c2 = NaN;
     case '01'
         c1 = tpval(find(inside));
         c2 = NaN;
     case '11'
         c1 = tpval(1);
         c2 = tpval(2);
     case '00'
         % warning('CUSTOM:curvatureAnalysis','Warning: both turning points are outside of the data range!')
         c1 = NaN;
         c2 = NaN;
 end
         
%  change sign for consistence with sacc2mov experiment design
%  a positive value --> clockwise change in direction NOT NEEDED
%  c1 = -c1;
%  c2 = -c2;
 
 % compute R squared
 predicted = polyval(coeff,Xhn);
 % predicted = coeff(1)*Xhn.^3 + coeff(2)*Xhn.^2 + coeff(3)*Xhn + coeff(4);
 R2 = (corr(predicted,Yh)^2);
 
 % exhaustive output structure
 out.coeff = coeff;
 out.Xh = Xh;
 out.Yh = Yh;
 out.Xh_n = Xhn;
 out.predicted = predicted;
 out.c1 = c1;
 out.c2 = c2;
 out.xc1 = xc1;
 out.xc2 = xc2;
 out.R2 = R2;
 
end