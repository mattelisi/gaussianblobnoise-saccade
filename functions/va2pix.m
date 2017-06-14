function pix=va2pix(va, scr)
% conversion of degree of visual angle into pixels 
% inputs :
%	va		: x degrees of visual angle
%	scr	    : structure describing monitor characteristics. Minimal fields required are listed below
%		scr.subDist	: viewing distance [cm]
%		scr.width	: physical width of monitor [mm]
%		scr.xres    : x resolution of monitor
pix = scr.subDist*tan(va*pi/180)/(scr.width/(10*scr.xres));	% distance between fixation point and target in pixels
 
