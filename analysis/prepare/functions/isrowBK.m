function [flag] = isrowBK(v)
% 
% isrow(V) returns logical 1 (true) if size(V) returns [1 n] with 
% a nonnegative integer value n, and logical 0 (false) otherwise
%
% Matteo Lisi, 2013
% 

dim = size(v);
if dim(1) == 1 && dim(2) >= 0
    flag = 1;
else
    flag = 0;
end