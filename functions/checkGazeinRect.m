function res = checkGazeinRect(gp,rect)
%
%   Check if gaze is in determined rect
%
%       [gp]    gaze point [x y]
%       [rect]  rect (can be more than one --> more row)
%       
%       res     binary flag, 1 = gaze is in one rects
%
%   Matteo Lisi, 2012
%

for r = size(rect,1)
   % if rect(i,1)<=gp(1) && gp(1)<=rect(i,3) && rect(i,2)<=gp(2) && gp(2)<=rect(i,4)
    if gp(1) >= min(rect(r,[1 3])) && gp(1) <= max(rect(r,[1 3])) && gp(2) >= min(rect(r,[2 4])) && gp(2) <= max(rect(r,[2 4]))
        res=1;
        return
    else
        res=0;
    end
end

