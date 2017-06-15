
function commonyAxes(axHandles,eqXAxes)
%
% function commonyAxes(axHandles, eqXAxes)
%
% cluster neighbouring axes such that only one 
% y-axis is plotted. Axes must have the same 
% height and be in a left-to-right order. In the
% figure no other axes should lie in between.
% 
% If eqXAxes is set to 1, all x axes will have 
% the same extent after applying the function.
% If eqXAxes is 0 or not specified, x axes will
% have the same relative extent as before.
%
% see also MATFIG, DESFIG, COMMONXAXES.
%
% 2006 by Martin Rolfs (University of Potsdam, Germany)

if nargin<2
    eqXAxes = 0;
end

na = length(axHandles);

for a = 1:na
    axPos(a,1:4) = get(axHandles(a),'Position');
end

if length(find(axPos(:,2)==axPos(1,2)))~=na
    error('y-axes do not have the same starting position!');
end
if length(find(axPos(:,4)==axPos(1,4)))~=na
    error('y-axes do not have the same extent!');
end

% design parameters
yMin = axPos(1,2);
yMax = yMin + axPos(1,4);
xMin = axPos(1,1);
xMax = axPos(end,1)+axPos(end,3);
xSep = 0.02;

ah = axPos(1,4);                % axis height
taw = (xMax-xMin-(na-1)*xSep);  % total axis height

if eqXAxes
    aw = (ones(1,na)*taw)/na;
else
    awRel = axPos(:,3)/sum(axPos(:,3));
    aw = awRel*taw;
end

% reposition axes in figure
for a = 1:na
    x1 = xMin+(a-1)*xSep+sum(aw(1:a-1));
    
    set(axHandles(a),'Pos',[x1 yMin aw(a) ah]);
end

% delete labels
set(axHandles(2:end),'yticklabel',{});
ylims = get(axHandles(1),'ylim');
set(axHandles,'ylim',ylims);
for a = 2:length(axHandles)
    axes(axHandles(a));
    ylabel('');
end