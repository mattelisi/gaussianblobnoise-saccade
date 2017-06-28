function outside = isoutofcircle(x,y,rect)
%
% Tests if point [x y] is inside one of the
% circles enveloped by rectangles defined in
% rect [x1 y1 x2 y2]. inside returns the rect,
% which [x,y] is in.
%
% 2006 by Martin Rolfs

outside = 0;
cxm = mean(rect([1 3]));    % x center of circle
cym = mean(rect([2 4]));    % y center of circle
dx  = rect(3)-rect(1);      % x diameter
dy  = rect(4)-rect(2);      % y diameter
rad = abs(min([dx dy])/2);
if sqrt((x-cxm)^2+(y-cym)^2)>rad
    outside = 1;
end
