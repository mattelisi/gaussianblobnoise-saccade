%% Circular pursuit #1 - eye movement analysis
%
% Matteo Lisi, 2015
%
% This makes single-trial plot (currently gaze and target positions only)
%

if welche == 1
    sfid = fopen('subjects.all','r');
else
    sfid = fopen('subjects.tmp','r');
end

%% prepare figure and axes

cout = [0.3 0.3 0.3];
cbac = [1.0 1.0 1.0];

close all;
h1 = figure;
set(gcf,'pos',[50 50 500 250],'color',cbac);
ax(1) = axes('pos',[0.01 0.3 1 0.7]);    % left bottom width height
ax(2) = axes('pos',[0.01 0.15 1 0.3]);


% select onset position to analyze
selOnsetPos_i = 4;
selDir = -1;

% accuracy th
acc_th = 2;

% clear previous traces
rmdir('traces','s');
mkdir('traces');

% TAB file conventions
%
% 1     2      3   4   5        6         7     8   9 10     11     12
% block trial3 tar dir nStepPre nStepPost sigma ecc d angVel tanVel tFix
%
% 13   14      15   16   17   18    19      20      21      22         23      24      25
% tBeg tChange tSac tEnd tClr sacRT tedfFix tedfTOn tedfSac tedfChange tedfTOf tedfClr lastStep


%% analysis

vp = 0;
cnt = 1;
while cnt ~= 0  % per tutti i soggetti
    [vpcode, cnt] = fscanf(sfid,'%s',1);
    if cnt ~= 0
        vp = vp + 1;
        
        % create file strings
        tabfile = sprintf('../tab/%s.tab',vpcode);
        datfile = sprintf('../raw/%s.dat',vpcode);
        reafile = sprintf('../rea/%s_V%iD%iT%iS%i.rea',vpcode,velSD,minDur,VELTYPE,SAMPRATE);
        btrfile = sprintf('../btr/%s_V%iD%iT%iS%i.btr',vpcode,velSD,minDur,VELTYPE,SAMPRATE);
        
        if ~exist(tabfile,'file')
            fprintf(1,'\n\ttab file %s not found!',tabfile);
        end
        if ~exist(datfile,'file')
            fprintf(1,'\n\ttab file %s not found!',datfile);
        end
        
        fprintf(1,'\n\n\tloading %s ...',vpcode);
        
        tab = load(tabfile);
        dat = load(datfile);
        
        % load experimental design specifications
        subDir=substr(vpcode, 0, 4);
        sessionDir=substr(vpcode, 5, 2);
        designfile = sprintf('../../data/%s/%s/%s.mat',subDir,sessionDir,vpcode);
        load(designfile);
        
        selOnsetPos = design.tarPositions(selOnsetPos_i);
        
        % correct the conversion factor to match the coordinates used for eyetracking
        visual.ppd = visual.ppd_out;
        
        % counting variables
        nt   = 0;   % number of trials
        
        for t = 1:size(tab,1) % per ogni trial
            nt = nt + 1;
            
            % load relevant variables
            block = tab(t,1);
            trial = tab(t,2);
            dir = tab(t,4);
            ecc = tab(t,8);
            angVel = tab(t,10);
            lastStep = tab(t,25);
            
            % load trial spec. and target trajectory
            td = design.b(block).trial(trial);
            
            % if selOnsetPos == td.tar && dir == selDir
            if 1
                
                % get edf timing information from the tab file
                tFixOnEDF = tab(t,19);
                tCueOnEDF = tFixOnEDF+tab(t,20);    % saccadic cue (target onset)
                tTarOnEDF = tCueOnEDF;
                tTarOffEDF = tTarOnEDF + round(td.nStepPost * scr.fdxx *1000);
                
                % recompute positions of the moving stimulus
                % NB these are sampled at 480Hz
                path =  detPathCircular(td.tar, td.dir, td.nStepPre, td.nStepPost, td.beta, td.ecc, visual, scrCen);
                
                for pathStep = 1:size(path,1)
                    path(pathStep,:)=DPP*[path(pathStep,1)-scrCen(1),-(path(pathStep,2)-scrCen(2))];
                end
                tarIndex = find(td.events==2);
                
                %             if ~isnan(lastStep)
                %                 path = path(1:lastStep,:);
                %             end
                
                % fixation and target position
                fixPos = [0 0];
                tarPos = path(tarIndex,:);
                tar = tab(t,3);
                tarPos = [fixPos; tarPos];
                
                nRS = size(tarPos,1)-1;     % nRS is 0 if no saccade required
                
                % reset all rejection criteria
                if nRS > 0
                    sbrs = zeros(1,nRS);
                    mbrs = zeros(1,nRS);
                    resp = zeros(1,nRS);
                    samp = zeros(1,1);
                else
                    sbrs = zeros(1,1);
                    mbrs = zeros(1,1);
                    resp = zeros(1,1);
                    samp = zeros(1,1);
                end
                
                
                %% Primary response saccade analysis
                
                % get data in response time interval
                idxrs = find(dat(:,1)>=tCueOnEDF & dat(:,1)<=tCueOnEDF+maxRT);
                timers = dat(idxrs,1);	% time stamp
                
                
                % determine sampling rate (differs across
                % trials if something went wrong)
                if ~mod(length(timers),2)   % delete last sample if even number
                    timers(end) = [];
                    idxrs(end)  = [];
                end
                samrat = round(1000/mean(diff(timers)));
                minsam = minDur*samrat/1000;
                if 0 %samrat<SAMPRATE
                    samp = 1;
                    ex.samp = ex.samp+1;
                end
                
                xrsf = DPP*([dat(idxrs,2)-scrCen(1) -(dat(idxrs,3)-scrCen(2))]);    % positions
                
                % filter eye movement data
                clear xrs;
                xrs(:,1) = filtfilt(fir1(35,0.05*SAMPRATE/samrat),1,xrsf(:,1));
                xrs(:,2) = filtfilt(fir1(35,0.05*SAMPRATE/samrat),1,xrsf(:,2));
                
                vrs = vecvel(xrs, samrat, VELTYPE);    % velocities
                vrsf= vecvel(xrsf, samrat, VELTYPE);   % velocities
                mrs = microsaccMerge(xrsf,vrsf,velSD,minsam,mergeInt);  % saccades
                mrs = saccpar(mrs);
                if size(mrs,1)>0
                    amp = mrs(:,7);
                    mrs = mrs(amp>maxMSAmp,:);
                end
                nSac = size(mrs,1);
                
                
                %% analyze position error during test interval
                
                filt_pos = fir1(forder,(low_pass_pos*2)/SAMPRATE);
                if low_pass_pos ~= 0
                    PXf = filtfilt(filt_pos,1,xrsf(:,1));
                    PYf = filtfilt(filt_pos,1,xrsf(:,2));
                    posF = [PXf PYf];
                else
                    posF = xrsf;
                end
                
                if (mrs(1,2)+testInterval(2)) < size(posF,1)
                    actTestInterval = mrs(1,2)+testInterval(1) : mrs(1,2)+testInterval(2);
                else
                    actTestInterval = mrs(1,2)+testInterval(1) : size(posF,1);
                end
                
                if length(actTestInterval) > minPursuitDur
                    % calculate target position at the landing time of the
                    % saccade landing
                    t_index = actTestInterval; % dopo la prima saccade
                    tar_angles = (2*pi-tar) +dir * deg2rad(angVel) *(t_index/1000);
                    tar_path_test = [ecc*cos(tar_angles); ecc*sin(tar_angles)]';
                    
                    pos_test = posF(t_index, :);
                    test_error = mean(sqrt((pos_test(:,1)- tar_path_test(:,1)).^2 + (pos_test(:,2)- tar_path_test(:,2)).^2));
                    
                    % fprintf(1,'\t test_error: %2f\n',test_error); %
                    % debug
                    
                else
                    test_error = NaN;
                end
                
                
                %% additional filters for plotting
                cutv = low_pass_pos/(SAMPRATE/2);
                PXf = filtfilt(fir1(35,cutv),1,xrsf(:,1));
                PYf = filtfilt(fir1(35,cutv),1,xrsf(:,2));
                posF = [PXf PYf];
                
                cutv = low_pass_vel/(SAMPRATE/2);
                VXf = filtfilt(fir1(35,cutv),1,vrsf(:,1));
                VYf = filtfilt(fir1(35,cutv),1,vrsf(:,2));
                velF = [VXf VYf];
                
                
                %% PLOT TRACES
                figure(h1);
                
                timeIndex = (timers - timers(1) +1)/1000;
                
                % add cue timing
                axes(ax(2));
                %             timeCue = (tCueOnEDF - timers(1));
                %             cueIndex = zeros(1,length(timeIndex));
                %             cueIndex(timeCue:end)=0.4;
                %             plot(timeIndex,cueIndex,'k-','linewidth',1);
                %             ylim([-0.5,1.5])
                %
                %             text(0.01,0,'cue','Fontsize',12,'hor','left','ver','bottom');
                %
                set(gca,'visible','off');
                %set(gca,'YColor',[1 1 1],'YTick',[]);
                %box off
                %xlabel('time (sec.)')
                
                % plot traces
                axes(ax(1));
                hold off;
                
                % time index for plotting target path
                tar_timeIndex = timeIndex(1) + (0:td.nStepPost) * scr.fdxx ;
                
                % this plot a grey rectangle in the pursuit analysis area
                if size(mrs,1)>1
                    if mrs(1,2)+pursuitInterval(2) <= mrs(2,1)
                        patch_x = [mrs(1,2)+pursuitInterval(1), mrs(1,2)+pursuitInterval(2), mrs(1,2)+pursuitInterval(2), mrs(1,2)+pursuitInterval(1)] / 1000;
                    else
                        patch_x = [mrs(1,2)+pursuitInterval(1), mrs(2,1), mrs(2,1), mrs(1,2)+pursuitInterval(1)] / 1000;
                    end
                else
                    patch_x = [mrs(1,2)+pursuitInterval(1), mrs(1,2)+pursuitInterval(2), mrs(1,2)+pursuitInterval(2), mrs(1,2)+pursuitInterval(1)] / 1000;
                end
                patch_y = [-10, -10, 10, 10];
                patch(patch_x, patch_y, 'r','edgecolor',[1 1 1], 'facecolor', [0.8 0.8 0.8], 'facealpha',0.8);
                
                hold on
                
                % plot horizontal position
                plot(timeIndex,posF(:,1),'-','color',[0.8 0.2 0.2],'linewidth',1);
                
                plot(tar_timeIndex, path(:,1),'--','color',[0.8 0 0]);
                
                for i = 1:size(mrs,1)
                    plot(timeIndex((mrs(i,1):mrs(i,2)),1), posF(mrs(i,1):mrs(i,2),1),'-','color',[0.8 0 0],'linewidth',3);
                end
                
                % plot vertical position
                plot(timeIndex,posF(:,2),'-','color',[0.2 0.2 0.8],'linewidth',1);
                plot(tar_timeIndex, path(:,2),'--','color',[0 0 0.8]);
                
                for i = 1:size(mrs,1)
                    plot(timeIndex((mrs(i,1):mrs(i,2)),1), posF(mrs(i,1):mrs(i,2),2),'-','color',[0 0 0.8],'linewidth',3);
                end
                
                ylim([-12,12])
                xlim([0,1.5])
                
                set(gca,'visible','off');
                
                text(0.01,10,sprintf('%s',substr(vpcode, 3, 2)),'Fontsize',8,'hor','left','ver','bottom','color',[0.5 0.5 0.5]);
                text(0.01,9,sprintf('trial %i (b. %i)',trial,block),'Fontsize',8,'hor','left','ver','bottom','color',[0.5 0.5 0.5]);
                if dir == 1 % 1 = CLOCKWISE; -1 = COUNTERCLOCKWISE
                    text(0.01,8,'clockwise','Fontsize',8,'hor','left','ver','bottom','color',[0.5 0.5 0.5]);
                else
                    text(0.01,8,'counter-clockwise','Fontsize',8,'hor','left','ver','bottom','color',[0.5 0.5 0.5]);
                end
                
                % export image
                %clear o
                %o = input('\n   Save image? [y / n]? ','s');
                %if strcmp(o,'y')
                %if selOnsetPos == td.tar && dir == selDir
                
                if test_error < acc_th
                    exportfig(h1,sprintf('traces/%s_Trace_trial%i.%i.%4f.eps',substr(vpcode, 3, 2), block, trial, td.tar),'bounds','tight','color','rgb','LockAxes',0);
                end
            end
            %end
            
            %
            cla;
        end
            
        end
        
    end

% save scale to add in final plots
cbac = [1.0 1.0 1.0];
h1 = figure;
set(gcf,'pos',[50 50 500 250],'color',cbac);
ax(1) = axes('pos',[0.01 0.3 0.98 0.7]); 
%set(gca,'visible','off'); 
axes(ax(1));
hold on;
ylim([-12,12])
xlim([0,1.5])

line([1,1],[0,5],'color',[0 0 0],'linewidth',2)
line([1,1.1],[0,0],'color',[0 0 0],'linewidth',2)

text(0.98,2,'5dva','Fontsize',12,'hor','right','ver','bottom','color',[0 0 0]);
text(1.05,-2,'100ms','Fontsize',12,'hor','center','ver','bottom','color',[0 0 0]);
exportfig(h1,'traces/scale2.eps','bounds','tight','color','rgb','LockAxes',0);

