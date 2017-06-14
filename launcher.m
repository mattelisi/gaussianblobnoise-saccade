%
% location uncertainty - blob + noise - saccade task
%
% Matteo Lisi, 2017

clear all;  clear mex;  clear functions;
addpath('functions/');

home;

%% general parameters
const.TEST        = 1;      % 1 = test in dummy mode, 0 = test in eyelink mode
const.gammaLinear = 0;      % use monitor linearization
const.saveMovie   = 0;
const.nTrialMovie = 5;

% gamma calibration data folders path
const.gamma    = '../gammacalib/Eyelink.mat';


%% participant informations
newFile = 0;

while ~newFile
    [vpcode] = getVpCode;

    % create data file
    datFile = sprintf('%s.mat',vpcode);
    
    % dir names
    subDir=substr(vpcode, 0, 4);
    sessionDir=substr(vpcode, 5, 2);
    resdir=sprintf('data/%s/%s',subDir,sessionDir);
    
    if exist(resdir,'file')==7
        o = input('      This directory exists already. Should I continue/overwrite it [y / n]? ','s');
        if strcmp(o,'y')
            newFile = 1;
            % delete files to be overwritten?
            if exist([resdir,'/',datFile])>0;                    delete([resdir,'/',datFile]); end
            if exist([resdir,'/',sprintf('%s.edf',vpcode)])>0;   delete([resdir,'/',sprintf('%s.edf',vpcode)]); end
            if exist([resdir,'/',sprintf('%s',vpcode)])>0;       delete([resdir,'/',sprintf('%s',vpcode)]); end
        end
    else
        newFile = 1;
        mkdir(resdir);
    end
end

currentDir = cd;

%% how many consecutive session?
nsess = getTaskInfo;


for sess = 1:str2double(nsess)
    
    cd(currentDir);
    
    % update session number e vpcode, create directory
    actualSess = str2double(sessionDir) + sess -1;
    actualSessStr = num2str(actualSess);
    
    if length(actualSessStr)==1
        actualSessStr = strcat('0',actualSessStr);
    end
    
    if sess > 1
        vpcode = sprintf('%s%s',subDir,actualSessStr);
        
        % create data file
        datFile = sprintf('%s.mat',vpcode);
    
        % dir names
        resdir=sprintf('data/%s/%s',subDir,actualSessStr);
        
        % keep the control to avoid potential deleting of good data
        if exist(resdir,'file')==7
            o = input('      This directory exists already. Should I continue/overwrite it [y / n]? ','s');
            if strcmp(o,'y')
                newFile = 1;
                % delete files to be overwritten?
                if exist([resdir,'/',datFile])>0;                    delete([resdir,'/',datFile]); end
                if exist([resdir,'/',sprintf('%s.edf',vpcode)])>0;   delete([resdir,'/',sprintf('%s.edf',vpcode)]); end
                if exist([resdir,'/',sprintf('%s',vpcode)])>0;       delete([resdir,'/',sprintf('%s',vpcode)]); end
            end
        else
            newFile = 1;
            mkdir(resdir);
        end
        
    end
    
    % prepare screens
    scr = prepScreen;
    
    % prepare stimuli
    visual = prepStim(scr, const);
    
    % generate design
    design = genDesign(visual, scr);
    
    % prepare movie
    if const.saveMovie
        movieName = sprintf('%s.mov',vpcode);
        % use GSstreamer
        %Screen('Preference', 'DefaultVideocaptureEngine', 3)
        visual.imageRect = scr.rect;
        const.moviePtr = Screen('CreateMovie', scr.main, movieName, scr.xres, scr.yres, 60);

    end
    
    % initialize eyelink-connection
    [el, err]=initEyelink(vpcode,visual,const,scr);
    if err==el.TERMINATE_KEY
        return
    end
    
    as = mod(actualSess,design.totSession);
    if as==0; as=design.totSession; end
    
    % instructions
    systemFont = 'Arial'; % 'Courier';
    systemFontSize = 19;
    GeneralInstructions = ['Welcome to our experiment. \n\n',...
        'Session ',actualSessStr,' (',num2str(as),' of ',num2str(design.totSession),').\n\n',...
        'Intructions:\n'...
        '1) fixate central point\n'...
        '2) a luminance patch will appear either to the right or to the left of fixation:\n'...
        'you task is to move your gaze on the path as quickly and accurately as possible.'...
        'Press any key when ready to begin.'];
    Screen('TextSize', scr.main, systemFontSize);
    Screen('TextFont', scr.main, systemFont);
    Screen('FillRect', scr.main, visual.bgColor);
    
    DrawFormattedText(scr.main, GeneralInstructions, 'center', 'center', visual.fgColor,70);
    
    Screen('Flip', scr.main);
    
    SitNWait;
    
    try
        % runtrials
        design = runTrials(design,vpcode,el,scr,visual,const);
    catch ME
        reddUp;
        rethrow(ME);
    end
    
    % finalize
    if const.saveMovie
        Screen('FinalizeMovie', const.moviePtr);
    end
    
    % shut down everything
    reddUp;
    
    % save updated design information
    save(sprintf('%s.mat',vpcode),'design','visual','scr','const');
    
    % sposto i risultati nella cartella corrispondente
    movefile(datFile,resdir);
    movefile(vpcode,resdir);
    if ~const.TEST; movefile(sprintf('%s.edf',vpcode),resdir); end
    
    %fprintf(1,'\nThis part of the experiment took %.0f min.',(toc)/60);
    fprintf(1,'\n\nOK!\n');
    
    % copy also edf files for analysis
    copyfile(sprintf('%s/%s.edf',resdir,vpcode),'analysis/edf/')
    
end



