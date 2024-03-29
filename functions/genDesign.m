function design = genDesign(visual,scr, sess, sjnum)
%
% location uncertainty v1.1 - gaussian blobs - saccade task
%
% Matteo Lisi, 2017
% 

%% display parameters
% design.eccentricity = [8 9 10 11 12];
if sjnum < 13
    if mod(sjnum,2)
        if mod(sess,2)
            design.eccentricity = [10 11 12];
        else
            design.eccentricity = [8 9 10];
        end
    else
        if mod(sess,2)==0 % revers session order for even sjs number
            design.eccentricity = [10 11 12];
        else
            design.eccentricity = [8 9 10];
        end
    end
    
else % extended ecc ranges for subjects n>12
    if mod(sjnum,2)
        if mod(sess,2)
            design.eccentricity = [10 11 12 13];
        else
            design.eccentricity = [7 8 9 10];
        end
    else
        if mod(sess,2)==0 % revers session order for even sjs number
            design.eccentricity = [10 11 12 13];
        else
            design.eccentricity = [7 8 9 10];
        end
    end
end

%% target parameters
design.min_sigma = 0.3;
design.sigma_range_deg = [design.min_sigma, 1.5];

% fixed set of sigmas
%design.sigmas_deg = logspace(design.min_sigma, design.sigma_range_deg(2), 5);
design.sigmas_deg = design.min_sigma;
for s = 1:4
    design.sigmas_deg = [design.sigmas_deg, design.sigmas_deg(s)*1.5];
end
design.sigmas = visual.ppd * design.sigmas_deg;

%% limit sigma conditions
design.sigmas_deg = linspace(design.sigmas_deg(1),design.sigmas_deg(end),3);
design.sigmas = linspace(design.sigmas(1),design.sigmas(end),3);

% uniform within range
% design.sigma_range = visual.ppd * design.sigma_range_deg;

design.side = [-1 1]; % side of the more distant target (+1 = right; -1 = left)
% design.deltaE = linspace(4/visual.ppd, 1.6, 6);

% conditions
design.condition_FE = [1]; % whether it is a fixed energy or constant peak condition
peak_contrast = 1; % fraction of the maximum for each condition

% this is actually a multiplier, ensure that peak luminance is at correct
% level
design.contrast_FE = 2 * pi * (visual.ppd * design.min_sigma)^2;
design.contrast_FE = design.contrast_FE * peak_contrast;

% this if you want to keep the peak constant
design.contrast_CP = ((design.min_sigma^2) / (max(design.sigmas_deg)^2) +1)/2;
design.contrast_CP = 0.4; % design.contrast_CP * peak_contrast;

% set the level of background noise
design.bg_RMScontrast = 10; % percentage of
design.bgsigma = design.bg_RMScontrast/100 * 256; 

% size of displayed pixel in screen pixels
design.pixSixe = 4;

%% timing
design.dur = [0.5];
design.soa = [500, 300]; % [min, jitter]
design.iti = 0.3;
design.preRelease = scr.fd/2;

% saccade condition
design.gap = [0];
design.gap_dur = 0.18;

%% saccade task
design.maxRT = 0.6;

%% exp structure
design.nBlocks = 6;
design.totSession = 1;
design.rep = 16;

%% other
design.fixJtStd = 0.2;

%% trials list
t = 0;
for cond = design.condition_FE
for i = 1:design.rep
for s = design.sigmas
for bg = design.bgsigma
for e = design.eccentricity
for side = design.side
for dur = design.dur
for gap = design.gap

    t = t+1;
    
    % trial settings 
    trial(t).ecc = e;
    trial(t).tarDur = dur;
    trial(t).FE = cond;
    if cond
        trial(t).contrast = design.contrast_FE;
    else
        trial(t).contrast = design.contrast_CP;
    end
    
    trial(t).bg_sigma = bg;
    trial(t).sigma = s;
    % trial(t).sigma = design.sigma_range(1) + rand(1) * (design.sigma_range(2) - design.sigma_range(1));

    trial(t).side = side;
    trial(t).gap = design.gap_dur * gap;
    
    trial(t).fixLoc = [scr.centerX scr.centerY] + round(randn(1,2)*design.fixJtStd*visual.ppd);
    trial(t).soa = (design.soa(1) + rand*design.soa(2))/1000;
    
end
end
end
end
end
end
end
end
    
design.totTrials = t;

% random order
r = randperm(design.totTrials);
trial = trial(r);

% generate blocks
design.blockOrder = 1:design.nBlocks;
design.nTrialsInBlock = design.totTrials/design.nBlocks;
beginB=1; endB=design.nTrialsInBlock;
for i = 1:design.nBlocks
    design.b(i).trial = trial(beginB:endB);
    beginB  = beginB + design.nTrialsInBlock;
    endB    = endB   + design.nTrialsInBlock;
end
