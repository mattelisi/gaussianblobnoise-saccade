function design = runTrials(design, datFile, el, scr, visual, const)
% run experimental blocks

% hide cursor if not in dummy mode
if const.TEST == 1
    ShowCursor;
else
    HideCursor;
end

% preload important functions
% NOTE: adjusting timer with GetSecsTest
% has become superfluous in OSX
Screen(scr.main, 'Flip');
GetSecs;
WaitSecs(.2);
FlushEvents('keyDown');

% create data fid
datFid = fopen(datFile, 'w');

% unify keynames for different operating systems
KbName('UnifyKeyNames');

Eyelink('StartRecording')

% determine recorded eye
if ~isfield(const,'recEye') && ~const.TEST
    eye_used = Eyelink( 'eyeavailable');
    const.recEye = eye_used +1;
end

% first calibration
if ~const.TEST
    calibresult = EyelinkDoTrackerSetup(el);
    if calibresult==el.TERMINATE_KEY
        return
    end
end

% set a counter for trials across bloc
ot = 0; 
latencies = [];

for b = 1:design.nBlocks
    
    % block = design.blockOrder(b); 
    if isfield(design.b(b),'train')
        ntTrain = length(design.b(b).train);
        ntTrial = length(design.b(b).trial);
    else
        ntTrain = 0;
        ntTrial = length(design.b(b).trial);
    end
    ntt = ntTrain + ntTrial;

    
    % instructions
    systemFont = 'Arial'; % 'Courier';
    systemFontSize = 19;
    GeneralInstructions = ['Block ',num2str(b),' of ',num2str(design.nBlocks),'. \n\n',...
        'Press any key to begin.'];
    Screen('TextSize', scr.main, systemFontSize);
    Screen('TextFont', scr.main, systemFont);
    Screen('FillRect', scr.main, visual.bgColor);
    
    DrawFormattedText(scr.main, GeneralInstructions, 'center', 'center', visual.fgColor,70);
    Screen('Flip', scr.main);
    
    SitNWait;
    
    
    % test trials
    t = 0;
    while t < ntt
        t = t + 1;
        trialDone = 0; %#ok<NASGU>
        if t <= ntTrain
            trial = t;
            if trial == 1
                Eyelink('message', 'STARTING TRAINING TRIALS');
            end
            td = design.b(b).train(trial);
        else
            trial = t-ntTrain;
            td = design.b(b).trial(trial);
        end

        % clean operator screen
        Eyelink('command','clear_screen');

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Eyelink Stuff
        if trial==1	%|| ~mod(trial,design.nTrlsBreak)        % calibration
            strDisplay(sprintf('%i out of %i trials finished. Press any key to continue',trial-1,ntt),scr.centerX, scr.centerY,scr,visual);
            SitNWait;
            if ~const.TEST
                calibresult = EyelinkDoTrackerSetup(el);
                if calibresult==el.TERMINATE_KEY
                    return
                end
            end
        end

        if ~const.TEST
            if Eyelink('isconnected')==el.notconnected		% cancel if eyeLink is not connected
                return
            end
        end

        % This supplies a title at the bottom of the eyetracker display
        Eyelink('command', 'record_status_message ''Block %d of %d, Trial %d of %d''', b, design.nBlocks, trial, ntt-ntTrain);
        % this marks the start of the trial
        Eyelink('message', 'TRIALID %d', trial);

        ncheck = 0;
        fix    = 0;
        record = 0;
        if const.TEST < 2
            while fix~=1 || ~record
                if ~record
                    Eyelink('startrecording');	% start recording
                    % You should always start recording 50-100 msec before required
                    % otherwise you may lose a few msec of data
                    WaitSecs(.1);
                    if ~const.TEST
                        key=1;
                        while key~= 0
                            key = EyelinkGetKey(el);		% dump any pending local keys
                        end
                    end
                    
                    err=Eyelink('checkrecording'); 	% check recording status
                    if err==0
                        record = 1;
                        Eyelink('message', 'RECORD_START');
                    else
                        record = 0;	% results in repetition of fixation check
                        Eyelink('message', 'RECORD_FAILURE');
                    end
                end
                
                if fix~=1 && record
                    
                    Eyelink('command','clear_screen 0');
                    cleanScr;
                    WaitSecs(0.1);
                    
                    % CHECK FIXATION
                    fix = checkFix(scr, visual, const, td.fixLoc);
                    ncheck = ncheck + 1;
                end
                
                if fix~=1 && record
                    % calibration, if maxCheck drift corrections did not succeed
                    if ~const.TEST
                        calibresult = EyelinkDoTrackerSetup(el);
                        if calibresult==el.TERMINATE_KEY
                            return
                        end
                    end
                    record = 0;
                end
            end
        else
            drawFixation(visual.fixCol,td.fixLoc,scr,visual);
            Screen('Flip', scr.main);
            % SitNWait;
            WaitSecs(0.2);
        end

        Eyelink('message', 'TRIAL_START %d', trial);
        Eyelink('message', 'SYNCTIME');		% zero-plot time for EDFVIEW
        
        %% RUN SINGLE TRIAL
        data = runSingleTrial(td, scr, visual, const, design);
        
        Eyelink('message', 'TRIAL_END %d',  trial);
        Eyelink('stoprecording');
        
        dataStr = sprintf('%i\t%i\t%s\n',b,trial,data); % print data to string
        if const.TEST; fprintf(1,sprintf('\n%s',dataStr));end

        % go to next trial if fixation was not broken
        if strcmp(data,'fixBreak')
            trialDone = 0;

            feedback('Please maintain fixation until target appears.',td.fixLoc(1),td.fixLoc(2),scr,visual);
            
        elseif strcmp(data,'tooSlow')
            trialDone = 0;

            feedback('Too slow.',td.fixLoc(1),td.fixLoc(2),scr,visual);
            
        else
            trialDone = 1;
            
            Eyelink('message', 'TrialData %s', dataStr);% write data to edfFile
            fprintf(datFid,dataStr);                    % write data to datFile
        end

        if const.TEST>0; fprintf(1,'\nTrial %i done',t-ntTrain); end

        if ~trialDone && (t-ntTrain)>0
            ntn = length(design.b(b).trial)+1;  % new trial number
            design.b(b).trial(ntn) = td;        % add trial at the end of the block
            ntt = ntt+1;

            if const.TEST>0; fprintf(1,' ... trial added, now total of %i trials',ntt); end
        end
        WaitSecs(design.iti);
        
        if const.saveMovie
            if trial > const.nTrialMovie
                return
            end
        end
        
    end
end

fclose(datFid); % close datFile

% end eye-movement recording
if ~const.TEST
    Screen(el.window,'FillRect',el.backgroundcolour);   % hide display
    WaitSecs(0.1);Eyelink('stoprecording');             % record additional 100 msec of data
end

Screen('FillRect', scr.main,visual.bgColor);
Screen(scr.main,'DrawText','Thanks, you have finished this part of the experiment.',100,100,visual.fgColor);
Screen(scr.main,'Flip');
Eyelink('command','clear_screen');
Eyelink('command', 'record_status_message ''ENDE''');

WaitSecs(1);
cleanScr;
ShowCursor;