function [outMat] = alignTrial(inMat,trial)
%
% align data from a signle trial in a matrix. 
% Add NaN values at the end if needed
%
% Matteo Lisi
%

tl = length(trial);
ml = size(inMat,2);
if ~isrow(trial)
    trial = trial';
end
if tl == ml
    outMat = [inMat; trial];
elseif ml > tl
    outMat = [inMat; trial, NaN(1, ml-tl)];
elseif tl > ml
    outMat = [inMat, NaN(size(inMat,1), tl-ml); trial];
end