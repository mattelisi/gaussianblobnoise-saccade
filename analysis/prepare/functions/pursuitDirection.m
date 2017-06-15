function [theta] = pursuitDirection(x,y,type)
%
% Determine direction angle (radians) for the ordered position vector (x,y)
% with a linear fit to the data. The output is the direction of the vector
% departing from [x(1), y(1)]
%
% Matteo Lisi, 2013
%

if nargin < 3
    type = 'intercept';
end

% determine hemi-quadrant
q = sign(x(end)-x(1));

switch type
    
    case 'intercept'    % this include a non-zero intercept
        
        % find coefficients
        coeff = polyfit(x, y, 1);
        
        switch q     
            case -1
                theta = pi + coeff(1);
                
            case 1
                theta = coeff(1);
        end
        
    case 'simple'       % zero-intercept
        
        switch q
            case -1
                theta = pi + x\y;
                
            case 1
                theta = x\y;
        end
        
end