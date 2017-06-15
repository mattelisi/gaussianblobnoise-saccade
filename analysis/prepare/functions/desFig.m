function handles = desFig(desMat)
%
% function h = desFig(desMat)
%
% creates figure with axes spatially arranged
% the way specified in desMat. desMat specifies width,
% heigth, and starting points for each axis. Values in 
% desmat are normalized, i.e., ratios of one.
% 
% desMat(1) = [x1 y1 Width Height]
% desMat(2) = [x1 y1 Width Height]
%   ...
% desMat(n) = [x1 y1 Width Height]
%
% Returns handles in h:
%   h.fig = figure handle
%   h.axes(1:nAxes) = axis handles
%
% see also MATFIG, COMMONXAXES, COMMONYAXES.
%
% 2006 by Martin Rolfs (University of Potsdam, Germany)

handles.fig = figure;

for a = 1:size(desMat,1)
    handles.axes(a) = axes('Position',desMat(a,:),'Box','on');
end
