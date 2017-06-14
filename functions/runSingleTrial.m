 function [data] = runSingleTrial(td, scr, visual, const, design)
%
% run individual trials
% location uncertainty - dot clouds - saccade task
%
% Matteo Lisi, 2017
%

% clear keyboard buffer
FlushEvents('KeyDown');

% define response keys
leftkey = KbName('LeftArrow');
rightkey = KbName('RightArrow');

if const.TEST == 1
    ShowCursor;
    SetMouse(scr.centerX, scr.centerY, scr.main); % set mouse 
else
    HideCursor;
end


%% varying pix size
% predefine boundary information
cxm = round(td.fixLoc(1));
cym = round(td.fixLoc(2));
chk = visual.fixCkRad;

% draw trial information on EyeLink operator screen
Eyelink('command','draw_cross %d %d', cxm, cym);

% coord
tar_loc = [cxm + td.side * round(visual.ppd * td.ecc), cym]  / design.pixSixe; 

% generate noise background for this trial
bgmat = visual.bgColor + td.bg_sigma*randn(scr.yres/design.pixSixe, scr.xres/design.pixSixe);
bgtexture = Screen('MakeTexture', scr.main, uint8(repelem(bgmat,design.pixSixe,design.pixSixe))); 

% target texture
[x, y] = meshgrid(1:scr.xres/design.pixSixe, 1:scr.yres/design.pixSixe);
absoluteDifference = abs(visual.white - visual.bgColor);
scaled_sigma = td.sigma/design.pixSixe;

% with this you can have the constant energy one
if td.FE
    imageMat_tar =  1/(2*pi*td.sigma^2) *  exp(-(((x-tar_loc(1)) .^ 2) + ((y-tar_loc(2)) .^ 2)) / (2*scaled_sigma ^ 2));
    PeakLum = (td.contrast * 1/(2*pi*td.sigma^2) * absoluteDifference);
    

else
    % this keep the peak constant and vary only the sigma
    imageMat_tar =  exp(-(((x-tar_loc(1)) .^ 2) + ((y-tar_loc(2)) .^ 2)) / (2*scaled_sigma ^ 2));
    PeakLum = (td.contrast * absoluteDifference);
    
end
    
targetImageMatrix = bgmat + td.contrast*absoluteDifference*(imageMat_tar);
targettexture = Screen('MakeTexture', scr.main, uint8(repelem(targetImageMatrix,design.pixSixe,design.pixSixe)));

%%
% draw trial information on EyeLink operator screen
Eyelink('command','draw_cross %d %d', cxm, cym);

% predefine time stamps
tOn    = NaN;
tOff   = NaN;
tSac   = NaN; 

% other flags
ex_fg = 0;      % 0 = ok; 1 = fix break; 2 = tooSlow

%% fixation phase

% draw fixation 
Screen('DrawTexture', scr.main, bgtexture,[],[]);
drawFixation(visual.fixCol,[cxm cym],scr,visual);
tFix = Screen('Flip', scr.main,0);
Eyelink('message', 'EVENT_FixationDot');
if const.TEST>0; fprintf(1,strcat('\n','EVENT_FixationDot')); end
if const.saveMovie
    Screen('AddFrameToMovie', scr.main, visual.imageRect, 'frontBuffer', const.moviePtr, round(td.soa/scr.fd)); 
end

% random SoA before stimulus
tFlip = tFix + td.soa;

% fixation check
while GetSecs < (tFix +td.soa - scr.fd)
    [x,y] = getCoord(scr, const); % get eye position data
    chkres = checkGazeAtPoint([x,y],[cxm,cym],chk);
    if ~chkres
        ex_fg = 1;
    end
end

%% stimuli / saccade phase
    
% draw stimuli 
Screen('DrawTexture', scr.main, targettexture,[],[]);
% drawFixation(visual.fixCol,[cxm cym],scr,visual);
tOn = Screen('Flip', scr.main, tFlip);
Eyelink('message', 'EVENT_TargetOnset');
if const.TEST>0; fprintf(1,strcat('\n','EVENT_TargetOnset')); end

% prepare offscreen 
drawFixation(visual.fixCol,[cxm cym],scr,visual);
tFlip = tOn + td.tarDur;

if const.saveMovie
    Screen('AddFrameToMovie', scr.main, visual.imageRect, 'frontBuffer', const.moviePtr, round(td.tarDur/scr.fd)); 
end

% loop gaze control for response period
while GetSecs < (tOn + design.maxRT)
    
    if isnan(tOff) && GetSecs > (tOn + td.tarDur - scr.fd)
        %if isnan(tSac)
            %drawFixation(visual.fixCol,[cxm cym],scr,visual);
        %end
        Screen('DrawTexture', scr.main, bgtexture,[],[]);
        tOff = Screen('Flip', scr.main, tFlip);
        Eyelink('message', 'EVENT_TargetOffset');
        if const.TEST>0; fprintf(1,strcat('\n','EVENT_TargetOffset')); end
    end
    
    if isnan(tSac)
        [x,y] = getCoord(scr, const); % get eye position data
        chkres = checkGazeAtPoint([x,y],[cxm,cym],chk);
        
        if ~chkres
            tSac = GetSecs;
            Eyelink('message', 'EVENT_Saccade1Started');
            if const.TEST; fprintf(1,'\nEVENT_Saccade1Started'); end
            if tSac < (tOn + td.tarDur - scr.fd) % isnan(tOff)
                Screen('DrawTexture', scr.main, targettexture,[],[]);
                Screen('Flip', scr.main);
            else
                Screen('DrawTexture', scr.main, bgtexture,[],[]);
                Screen('Flip', scr.main);
            end
        end
    end
end

if isnan(tOff)
    % drawFixation(visual.fixCol,[cxm cym],scr,visual);
    Screen('DrawTexture', scr.main, bgtexture,[],[]);
    tOff = Screen('Flip', scr.main, tFlip);
    Eyelink('message', 'EVENT_TargetOffset');
    if const.TEST>0; fprintf(1,strcat('\n','EVENT_TargetOffset')); end
end

if isnan(tSac)
    ex_fg = 2;
end

%
if const.saveMovie
    Screen('AddFrameToMovie', scr.main, visual.imageRect, 'frontBuffer', const.moviePtr, round(0.3/scr.fd)); 
end


%% trial end

switch ex_fg
    
    case 1
        data = 'fixBreak';
        Eyelink('command','draw_text 100 100 15 Fixation break');
        
    case 2
        data = 'tooSlow';
        Eyelink('command','draw_text 100 100 15 Too slow or no saccade');
                
    case 0
        
        % collect trial information
        trialData = sprintf('%i\t%.2f\t%.2f\t%i\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t',[td.side td.ecc td.tarDur td.sigma cxm cym tar_loc td.soa  NaN PeakLum]); 
        
        % timing
        timeData = sprintf('%.2f\t%.2f\t%.2f\t%.2f',[tFix tOn tOff tSac]);
        
        % determine response data
        respData = sprintf('%.2f',[tSac - tOn]);
        
        % collect data for tab [14 x trialData, 6 x timeData, 1 x respData]
        data = sprintf('%s\t%s\t%s\t%s',trialData, timeData, respData);
        
end


% close active textures
Screen('Close', bgtexture);
Screen('Close', targettexture);

