function diff = angDiff(alpha,beta)
%
% compute the signed angular difference between the angle beta and alpha,
% defined in radians, and being alpha the starting angle (source)
%
% Matteo Lisi, 2013
%

diff = atan2(sin(beta-alpha), cos(beta-alpha));