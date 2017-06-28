clear all
close all
clc

% --- User-defined variables
folder='C:\Documents and Settings\claudio\Desktop\Didattica\Psicofisiologia\Lab\REC\';
% folder='G:\didattica\psicofisiologia\LAB\REC\';
sampling_freq=1000;         % Sampling frequency (Hz)
low_pass_pos=300;           % Position filter (Hz)
low_pass_vel=80;            % Velocity filter (Hz)
low_pass_acc=60;            % Acceleration filter (Hz)
threshold=15;               % Velocity thershold
% -------------------------

dot_dimension=6;            % 6= large dots, 1=single dot
vert_shift=.5;              % Vertical shift of the traces
order=32;                   % Order Nth for the filter

filecode='2222a.rec';
filename=[folder filecode];

gf=32766/5;
limaxis=[-32766 32766]/gf;

% --- Read data from binary file
hf=fopen(filename);
[P, nsamples] = fread(hf,inf,'short');
fclose(hf);
PX=P(1:2:nsamples)/gf;
PY=P(2:2:nsamples)/gf;
nsamples=nsamples/2;


% --- Filter position
[PXf PYf]=FiltrSacc2D(PX,PY,nsamples,order,low_pass_pos,sampling_freq);


% --- Derivative for velocity
VX=diff(PXf);VY=diff(PYf);


% --- Filter velocity
[VXf VYf]=FiltrSacc2D(VX,VY,nsamples-1,order,low_pass_vel,sampling_freq);


% --- Derivative for acceleration
AX=diff(VXf);AY=diff(VYf);


% --- Filter acceleration
[AXf AYf]=FiltrSacc2D(AX,AY,nsamples-2,order,low_pass_acc,sampling_freq);




% --- Time Plot 
figure(4)
xlimit=[order nsamples-order];ylimit=limaxis;
xlim(xlimit);ylim(ylimit);
hold on
h=gca;set(h,'XTick', xlimit, 'XTickLabel', [], 'YTick', ylimit,'YTickLabel',[])
axis off

% -Horizontal component
% plot(PX,'g.','Markersize',dot_dimension)                            
% hold on
plot(PXf,'b.','Markersize',dot_dimension)                            
hold on
% plot(VX*20+vert_shift,'k.','Markersize',dot_dimension)                            
% hold on
plot(VXf*20+vert_shift,'r.','Markersize',dot_dimension)                            
hold on
plot(AXf*200+vert_shift*2,'y.','Markersize',dot_dimension)                            
hold on

% % -Vertical component
% % plot(PY,'g.','Markersize',dot_dimension)                            
% % hold on
% plot(PYf,'b.','Markersize',dot_dimension)                            
% hold on
% % plot(VY*20+vert_shift,'k.','Markersize',dot_dimension)                            
% % hold on
% plot(VYf*20+vert_shift,'r.','Markersize',dot_dimension)                            
% hold on
% plot(AYf*200+vert_shift*2,'y.','Markersize',dot_dimension)                            
% hold on


% --- X-Y Plot 
figure(5)
xlim(limaxis);ylim(limaxis);
h=gca;set(h,'XTick', limaxis, 'XTickLabel', [], 'YTick', limaxis,'YTickLabel',[])
axis square
hold on

plot(PXf,PYf,'b.','Markersize',dot_dimension)                            
hold on
