function inside = isinrect(x,y,rect)
%
% Tests if point [x y] is inside one of the
% rects specified in rect [x1 y1 x2 y2].
% inside returns the rect, which [x,y] is in.
%
% 2006 by Martin Rolfs

inside = 0;
for r = 1:size(rect,1)
    if x >= min(rect(r,[1 3])) && x <= max(rect(r,[1 3])) && y >= min(rect(r,[2 4])) && y <= max(rect(r,[2 4]))
        inside = r;
    end
end
