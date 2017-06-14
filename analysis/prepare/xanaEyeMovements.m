% xanaEyeMovements.m
%
% Input:
% 1. vpcode.tabc
% 2. vpcode.dat
%
% Output:
% 2. vpcode.rea - saccadic responses
% 3. vpcode.btr - exclusion criteria 
%


clear;
home;

addpath('functions/');
addpath('../../Functions/');

% switches
welche    = 1;          % which files shall be analysed (1=all, 2=tmp)

plotData  = 0;          % show figure with raw data
printImages = 0;

SAMPRATE  = 1000;       % Eyetracker sampling rate 
maxRT     = 1000;       % time window for corrective saccades
timBefCue = 300;        % time window to be analysed before saccade cue
velSD     = 5;          % lambda for microsaccade detectionc
minDur    = 8;          % threshold duration for microsaccades (ms)
VELTYPE   = 2;          % velocity type for saccade detection
maxMSAmp  = 1;          % maximum microsaccade amplitude
crit_cols = [2 3];      % critical gaps in dat files to find missings data
maxMiss   = 0;          % max prop. missing data in presaccadic interval 
mergeInt  = 10;         % merge interval for subsequent saccadic events

% target radius for fixation and saccadic eye movements
tarRad = 2.5;

% Paris
MO_WIDE   = 1920;            % x resolution
ABSTAND   = 77;             % subject distance in cm
MO_PHYS   = 51.5;           % monitor width in cm
scrCen    = [1920, 1200]/2;  % screen center (intial fixation position)

DPP = pix2deg(MO_WIDE,MO_PHYS,ABSTAND,1); % degrees per pixel
PPD = deg2pix(MO_WIDE,MO_PHYS,ABSTAND,1); % pixels per degree

% perform analysis
anaEyeMovementsFilter;
xcombineData;

% just plot traces
% anaEyeMovements_singleTrialPlot;

% to save single traces
% exportfig(1,'ML02_1.9.eps','Color','rgb')
% exportfig(h3,'SB01_PS.eps','Color','rgb')

fprintf(1,'\n\nOK!!\n');
