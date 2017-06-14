% xmsg2tab.m
%
% Experiment: saccade task - sampled motion
%
% Creates tab-File containing information specified
% for a certain trial.
%
% tab-Files have the following columns
% (predefined by defNaNVariables.m):

clear;

addpath('functions/');

msgpath = '../raw/';
tabpath = '../tab/';

subfid = fopen('subjects.tmp','r');
cnt = 1;
while cnt ~= 0
    [vpcode, cnt] = fscanf(subfid,'%s',1);
    if cnt ~= 0
        msgstr = sprintf('%s%s.msg',msgpath,vpcode);
        msgfid = fopen(msgstr,'r');

        fprintf(1,'\nprocessing ... %s.msg',vpcode);
        stillTheSameSubject = 1;
        tab = [];
        while stillTheSameSubject
            % predefine critical variables
            defNaNVariables;

            stillTheSameTrial = 1;
            while stillTheSameTrial

                line = fgetl(msgfid);
                if ~ischar(line)    % end of file
                    stillTheSameSubject = 0;
                    break;
                end

                if ~isempty(line) && stillTheSameSubject   % skip empty lines
                    la = strread(line,'%s');    % array of strings in line

                    if length(la) >= 3
                        switch char(la(3))
                            case 'TRIAL_START'
                                trial = str2double(char(la(4)));
                            case 'EVENT_FixationDot'
                                tedfFix = str2double(char(la(2)));
                            case 'EVENT_TargetOnset'
                                tedfTOn = str2double(char(la(2)));
                            case 'EVENT_Saccade1Started'
                                tedfSac = str2double(char(la(2)));
                            case 'EVENT_TargetOffset'
                                tedfTOf = str2double(char(la(2)));
                            case 'TRIAL_ENDE'
                                trial2 = str2double(char(la(4)));
                            case 'TrialData'
                                
                                % 4 5     6       7      8         9         10  11  12         13         14      15      16      17   18  19   20   21    22
                                % b trial td.side td.ecc td.tarDur td.sigma  cxm cym tar_loc(x) tar_loc(y) td.soa  mu_disp sd_disp tFix tOn tOff tSac sacRT td.n
                                
                                block  = str2double(char(la(4)));
                                trial3 = str2double(char(la(5)));
                                side   = str2double(char(la(6)));
                                ecc    = str2double(char(la(7)));
                                tarDur = str2double(char(la(8)));
                                sigma  = str2double(char(la(9)));
                                cxm    = str2double(char(la(10)));
                                cym    = str2double(char(la(11)));
                                tarx   = str2double(char(la(12)));
                                tary   = str2double(char(la(13)));
                                soa    = str2double(char(la(14)));
                                mu_disp  = str2double(char(la(15)));
                                sd_disp  = str2double(char(la(16)));
                                
                                tFix   = str2double(char(la(17))); 
                                tOn    = str2double(char(la(18))); 
                                tOff   = str2double(char(la(19))); 
                                tSac   = str2double(char(la(20)));
                                sacRT  = str2double(char(la(21)));
                                
                                if length(la) > 21
                                    n = str2double(char(la(22)));
                                else
                                    n= NaN;
                                end
                                
                                stillTheSameTrial = 0;
         
                        end
                    end
                end
            end
            
            % check if trial ok and all messages available
            if trial==trial3 && sum(isnan([trial trial3 tedfFix tedfTOn tedfSac]))==0
                everythingAvailable = 1;
            else
                everythingAvailable = 0;
            end

            if everythingAvailable
                tedfTOn = tedfTOn - tedfFix;
                tedfSac = tedfSac - tedfFix;
                tedfTOf = tedfTOf - tedfFix;
                
                % create uniform data matrix containing any potential
                % information concerning a trial
                tab = [tab; block trial3 side ecc tarDur sigma soa tFix tOn tOff tSac sacRT tedfTOn tedfSac tedfTOf tedfFix cxm cym tarx tary mu_disp sd_disp n];
                
            elseif trial~=trial2
                fprintf(1,'\nMissing Message between TRIALID %i and trialData %i (ignore if last trial)',trial,trial2);
            end
        end
        fclose(msgfid);

        outname = sprintf('%s%s.tab',tabpath,vpcode);
        fout = fopen(outname,'w');
        tab_format = strcat(repmat('%.4f\t', 1,size(tab,2)-1), '%.4f\n');
        fprintf(fout,tab_format,tab');
        
        fclose(fout);
    end
end
fclose(subfid);
fprintf(1,'\n\nOK!!\n');
