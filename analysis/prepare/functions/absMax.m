function [smax, i] = absMax(v)
%
% Find the maximum absolute value in vector v and return it signed.
% Optional second output 'i' is the index of the value in the vector.
%
% Matteo Lisi, 2013
%

i = find(abs(v) == max(abs(v)));
smax = v(i);
