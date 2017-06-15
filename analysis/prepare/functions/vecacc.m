function v = vecacc(xx,TYPE)
%------------------------------------------------------------
%
%   - compute acceleration
%
%-------------------------------------------------------------
%
%  INPUT:
%
%  xy(1:N,1:2)     raw data, x- and y-components of the time series
%
%  OUTPUT:
%
%  v(1:N,1:2)     velocity, x- and y-components
%
%-------------------------------------------------------------
N = length(xx);            % length of the time series
v = zeros(N,2);

if nargin < 2
    TYPE = 1;
end

switch TYPE
    case 1
        v(2:N-1,:) = [xx(3:end,:) - xx(1:end-2,:)];
    case 2
        v(3:N-2,:) = 1/3 * [xx(5:end,:) + xx(4:end-1,:) - xx(2:end-3,:) - xx(1:end-4,:)];
        v(2,:) = [xx(3,:) - xx(1,:)];
        v(N-1,:) = [xx(end,:) - xx(end-2,:)];
end
