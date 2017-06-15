function [xLP, yLP]=FiltrSacc2D(data,numberData,dimFilt,cutoff,sampling_freq)

% La funzione FIR1 costruisce un filtro di dimensioni dimFilt+1 quindi diamo a dimFilt un valore positivo
% dimFilt=32;             % Nth order filter
% cutoff=300;             % Cut-off frequency (Hz)
% sampling_freq=1000;     % Sampoing frequency (Hz)

Wn=cutoff/(sampling_freq/2);

%data(1,:)=x';
%data(2,:)=y';
delayFilt=dimFilt/2;
cornice=zeros(1,delayFilt);

b=fir1(dimFilt,Wn);

a=zeros(1,length(b));

a(1)=1;
meanInitialX=mean(data(1,1:delayFilt));
meanFinalX=mean(data(1,numberData-delayFilt:numberData));
meanInitialY=mean(data(2,1:delayFilt));
meanFinalY=mean(data(2,numberData-delayFilt:numberData));
data=[data, [meanFinalX*ones(1,delayFilt); meanFinalY*ones(1,delayFilt)]]';
dataFiltr=filter(b,a,data);
dataFiltr=[dataFiltr((delayFilt+1:length(data)),:)];
xLP=dataFiltr(:,1);
yLP=dataFiltr(:,2);
xLP(1:delayFilt)=meanInitialX;
yLP(1:delayFilt)=meanInitialY;
xLP(length(xLP)-delayFilt:length(xLP))=meanFinalX;
yLP(length(yLP)-delayFilt:length(yLP))=meanFinalY;

return