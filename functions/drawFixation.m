function drawFixation(col,loc,scr,visual)
%
% simple dot
%

% square
Screen('DrawDots', scr.main, loc, round(visual.ppd*0.2), col,[], 4); % fixation

% circle
%if length(loc)==2
%    loc=[loc loc];
%end
%pu = round(visual.ppd*0.1);
%Screen(scr.main,'FillOval',col,loc+[-pu -pu pu pu]);
% Screen(scr.main,'FrameOval',rim,loc+3*[-pu -pu pu pu],pu/2);

