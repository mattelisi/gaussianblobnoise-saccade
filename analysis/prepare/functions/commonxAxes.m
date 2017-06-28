function commonxAxes(axHandles,eqYAxes)
%
% function commonxAxes(axHandles, eqYAxes)
%
% cluster neighbouring axes such that only one 
% x-axis is plotted. Axes must have the same 
% width and be in a top-to-bottom order. In the
% figure no other axes should lie in between.
% 
% If eqYAxes is set to 1, all y axes will have 
% the same extent after applying the function.
% If eqYAxes is 0 or not specified, y axes will
% have the same relative extent as before.
%
% see also MATFIG, DESFIG, COMMONYAXES.
%
% 2006 by Martin Rolfs (University of Potsdam, Germany)

if nargin<2
    eqYAxes = 0;
end

na = length(axHandles);

for a = 1:na
    axPos(a,1:4) = get(axHandles(a),'Position');
end

if length(find(axPos(:,1)==axPos(1,1)))~=na
    error('x-axes do not have the same starting position!');
end
if length(find(axPos(:,3)==axPos(1,3)))~=na
    error('x-axes do not have the same extent!');
end

% design parameters
xMin = axPos(1,1);
xMax = xMin + axPos(1,3);
yMin = axPos(end,2);
yMax = axPos(1,2)+axPos(1,4);
ySep = 0.02;

aw = axPos(1,3);                % axis width
tah = (yMax-yMin-(na-1)*ySep);  % total axis height

if eqYAxes
    ah = (ones(1,na)*tah)/na;
else
    ahRel = axPos(:,4)/sum(axPos(:,4));
    ah = ahRel*tah;
end

% reposition axes in figure
for a = 1:na
    y1 = yMax-sum(ah(1:a))-(a-1)*ySep;
    
    set(axHandles(a),'Pos',[xMin y1 aw ah(a)]);
end

% delete labels
set(axHandles(1:end-1),'xticklabel',{});
xlims = get(axHandles(end),'xlim');
set(axHandles,'xlim',xlims);
for a = 1:length(axHandles)-1
    axes(axHandles(a));
    xlabel('');
end