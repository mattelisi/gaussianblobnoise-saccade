function[texture] = makeBGNoise(scr,visual,bgsigma)

nmat = uint8(visual.bgColor + bgsigma*randn(scr.xres, scr.yres));
texture = Screen('MakeTexture', scr.main, nmat); 
