function [] = run_all_analyses()
% run analyses

% move edf files
current_dir = pwd;
destination_dir = '/Users/matteo/Dropbox/works 2017/city/blobcloud-saccade/analysis/edf';
nameFolds = listSubFolders;

s_all = fopen('/Users/matteo/Dropbox/works 2017/city/blobcloud-saccade/analysis/prepare/subjects.all','w');
s_tmp = fopen('/Users/matteo/Dropbox/works 2017/city/blobcloud-saccade/analysis/prepare/subjects.tmp','w');

x = '/*.edf';
for i=1:length(nameFolds)
    sub_Dir = (strjoin(strcat(current_dir,'/',strcat(nameFolds(i)))));
    cd(sub_Dir);
    sessDir = listSubFolders;
    for s_i = 1:length(sessDir)
        edf_name = dir(strjoin(strcat(current_dir,'/',strcat(nameFolds(i)),'/',sessDir(s_i),x)));
        copyfile(strjoin(strcat(current_dir,'/',strcat(nameFolds(i)),'/',sessDir(s_i),'/',edf_name.name)), destination_dir);
        fprintf(s_all, strcat(edf_name.name(1:6),'\n'));
        fprintf(s_tmp, strcat(edf_name.name(1:6),'\n'));
    end
end

% convert edf files
cd(destination_dir);
! sh prepare.sh

% run eye movememnt analyses
cd('/Users/matteo/Dropbox/works 2017/city/blobcloud-saccade/analysis/prepare');
xmsg2tab;
xanaEyeMovements;

end

function nameFolds = listSubFolders()
d = dir;
isub = [d(:).isdir]; %# returns logical vector
nameFolds = {d(isub).name}';
nameFolds(ismember(nameFolds,{'.','..'})) = [];
end