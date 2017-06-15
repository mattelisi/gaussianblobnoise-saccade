% takes all subjects data and combines then
% with same initals being the same subjects
% and numbers after initials being the session

clear;

addpath('functions/');

reapath = '../rea/';

specs = 'V5D8T2S1000';

reaAllFile = sprintf('../rea/AllSubjects_%s.rea',specs);
freaAll = fopen(reaAllFile,'w');

exsubject = '';
sub = 0;

subfid = fopen('subjects.all','r');
cnt = 1;
subject = 0;
while cnt ~= 0
    [vpcode, cnt] = fscanf(subfid,'%s',1);
    if cnt ~= 0
        reastr = sprintf('%s%s_%s.rea',reapath,vpcode,specs);
        
        fprintf(1,'\n ... adding file %s',reastr);
        
        m = load(reastr);
        
        subject = vpcode(1:2);
        
        if ~strcmp(subject,exsubject)
            sub = sub+1;
        end
        ses = str2double(vpcode(5:6));
        
        mSub = [sub*ones(size(m,1),1) ses*ones(size(m,1),1) m];
        tab_format = strcat(repmat('%.4f\t', 1,size(mSub,2)-1), '%.4f\n');
        fprintf(freaAll,tab_format,mSub');
        
        exsubject = subject;
    end
end

fclose(subfid);
fclose(freaAll);
fprintf(1,'\n\nOK!!\n');
