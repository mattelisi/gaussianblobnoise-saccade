function angle = compDir(x,y)
%
% compute the direction of the vector result from x and y, in a way suited
% for comparison with other angles (no negative angles)
%
% x & y must be the horizontal and vertical component respectively
%
%

switch sprintf('%i %i',sign([x, y]))
    
    case '1 1'
        
        angle = atan (y/x);
        
    case '-1 1'
        
        angle = pi - atan (y/x);
        
    case '1 -1'
        
        angle = 2*pi - atan(y/x);
        
    case '-1 -1'
        
        angle = pi + atan(y/x);
        
end
    