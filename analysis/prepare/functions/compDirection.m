function [theta] = compDirection(x,y,type)
%%

if nargin<3
    % type = 'average';
    type = 'linear';
end

% determine hemi-field
q = sign(sum(diff(x)));

switch lower(type)
    
    case 'linear'
        
        % linear regression
        % coeff = polyfit(x, y, 1); % this include a non-zero intercept
        % NB polyfir report coefficients in descending order, so the 1st is
        % the slope, and the 2nd is the intercept.
        
        % orthogonal regression
        coeff=linortfit(x,y);
        
        switch q
            case -1
                % theta = pi + coeff(1); % linear
                theta = pi + atan(coeff(2));
            case 1
                % theta = coeff(1); % linear
                theta = atan(coeff(2));
        end
        
        
    case 'average'
        
        index = sort(repmat(1:3,1,floor(length(x)/3)));
        index = [index, repmat(3,1,mod(length(x),3))];
        x_start = mean(x(index==1));
        y_start = mean(y(index==1));
        x_end = mean(x(index==3));
        y_end = mean(y(index==3));
        theta = cart2pol(x_end-x_start, y_end-y_start);
        
end
% Determine direction angle (radians) for the ordered position vector (x,y)
% with a linear fit to the data. 
% UPDATE: linear fit is made through orthogonal regression (require linortfit.m)
%
% Matteo Lisi, 2013




% x = linspace(0,0.025,100) + randn(1,100)./10;
% y = linspace(0,7,100) + randn(1,100)./10;
% x=x'
% y=y'
% plot(x,y)


% a = [1 2 3 4 8 9 16 17 18];
% 
% b=a-(1:length(a));
% b = [true; diff(b(:)) ~= 0; true];
% split = mat2cell(a(:).', 1, diff(find(b)));
% 
% split{:}

