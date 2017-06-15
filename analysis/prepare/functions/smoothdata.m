function y = smoothdata(x);
%
%
%
y0 = x(1,:);
v = vecvel(x,1,2);
y = cumsum([y0; v]);
