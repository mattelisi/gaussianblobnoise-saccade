function [x,y] =getCoord(wPtr,const)
%
% collect real or simulated eye position data
%

x=0; y=0;   % to avoid errors at the beginning of recordings

if const.TEST
    [x,y]=GetMouse(wPtr.main); % gaze position simulate by mouse position
else
    evt = Eyelink('newestfloatsample');
    x = evt.gx(const.recEye);
    y = evt.gy(const.recEye);
    
end