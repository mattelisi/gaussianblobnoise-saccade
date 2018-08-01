%% make a dataset of saccade traces for importing into R
clear all
load('alltraces.mat');

outpath = 'traces/';
timetosaccade = -50:100;
nsamples = length(timetosaccade);
IDs = unique([traces.vp]);

for i=IDs
    traces_i = traces([traces.vp]==i);
    tab = [];
    for t = 1:length(traces_i)
        trialinfo = repmat([traces_i(t).sigma, ...
            traces_i(t).sacRT, traces_i(t).ecc, traces_i(t).sacDur, ...
            traces_i(t).sacVPeak, traces_i(t).sacXResp, ...
            traces_i(t).min_ecc, traces_i(t).max_ecc,...
            traces_i(t).block, traces_i(t).trial],nsamples,1);
        tab = [tab; timetosaccade', traces_i(t).x, traces_i(t).y, traces_i(t).vx, traces_i(t).vy, trialinfo];
    end
    outname = sprintf('%s%s.txt',outpath, traces_i(1).vpcode);
    fout = fopen(outname,'w');
    tab_format = strcat(repmat('%.4f\t', 1,size(tab,2)-1), '%.4f\n');
    fprintf(fout,tab_format,tab');
    fclose(fout);
end
% time x y vx vy sigma RT ecc dur VPeak xResp minecc maxecc block trial