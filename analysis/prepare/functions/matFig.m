function handles = matFig(figMat)
%
% function h = matFig(figMat)
%
% creates figure with axes spatially arranged
% the way specified in figMat. Axes' extents
% may be specified in desMat.
%
% E.g., figMat = [1 5 6
%                 2 5 6
%                 3 5 6
%                 4 4 6
%                 4 4 6
%                 4 4 6]
%
% results in six different axes located comparable
% like the corresponding numbers in figMat. Zero
% entries result in space left at corresponding 
% locations in the figure.
%
% Returns handles in h:
%   h.fig = figure handle
%   h.axes(1:nAxes) = axis handles
%
% see also DESFIG, COMMONXAXES, COMMONYAXES.
%
% 2006 by Martin Rolfs (University of Potsdam, Germany)

% general layout
nr = (size(figMat,1));
nc = (size(figMat,2));

% design parameters
xMin = 0.10;
xMax = 0.95;
yMin = 0.10;
yMax = 0.95;
xSep = 0.10/nc^.2;
ySep = 0.10/nr^.2;

aw = (1-(nc-1)*xSep-xMin-(1-xMax))/nc;  % axis width
ah = (1-(nr-1)*ySep-yMin-(1-yMax))/nr;  % axis height

% determination of design matrix
for a = 1:length(find(unique(figMat)>0))
    [rows, cols] = find(figMat==a);
    
    r1 = min(rows);
    r2 = max(rows);
    c1 = min(cols);
    c2 = max(cols);
        
    w  = (diff([c1 c2]))*(xSep+aw)+aw; 
    h  = (diff([r1 r2]))*(ySep+ah)+ah; 
    x1 = xMin+(c1-1)*(aw+xSep);
    y1 = yMin+(nr-r2)*(ah+ySep);
    
    desMat(a,1:4) = [x1 y1 w h];
end

handles = desFig(desMat);
