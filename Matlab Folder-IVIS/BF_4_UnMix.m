%% User Input-- Step 4
%What we are doing now is dividing channel(s) with a lot of signal from your
%fluorophore by channel(s) that should have little to no
%fluorescence from your fluorophore. This helps to normalize out regions
%that are brighter due to tissue autofluorescence, or regions that are
%brighter from being in the center or edge of the image.

SignalChannels= [18]; %Number(s) of your channels with signal
NormalizeChannels= [4]; %Number(s) of your channels to normalize the data to

PlotNumDemDivisor=false;
PlotOverlay=true;
    CleanSpace=true;
PlotHeatMap=false;
%See the following tag in the code to change the image apearance:
%Adjust to change image appearance

%% Code
close all
testBinary=imbinarize(rescale(montageImg(:,:,8)));
CleanArea=zeros(size(testBinary));

test=[];
CleanArea(test,:)=0;


testBinary(CleanArea==1)=0;

for i=SignalChannels
    for j=NormalizeChannels

Numerator=montageImg(:,:,i);
% Numerator=Numerator-min(Numerator,[],'all')+1;


Denominator=montageImg(:,:,j);
% Denominator=ones(size(montageImg(:,:,j)));

% Denominator=Denominator-min(Denominator,[],'all')+1;
QuickNorm=double(Numerator)./double(Denominator);
 QuickNorm2=QuickNorm;
QuickNorm2(isinf(QuickNorm2))=max(QuickNorm2(~isinf(QuickNorm2)));

 QuickNorm2(testBinary==0)=min(QuickNorm2(testBinary==1),[],'all');
QuickNorm3=rescale(QuickNorm2);

Numerator2=Numerator;
Denominator2=Denominator;
 Numerator2(testBinary==0)=min(Numerator2(testBinary==1),[],'all');
 Denominator2(testBinary==0)=min(Denominator2(testBinary==1),[],'all');
% QuickNorm2=0.7*QuickNorm2./mean(QuickNorm2,'all');
% QuickNorm=QuickNorm-min(QuickNorm,[],'all');
% QuickNorm(Back)=0;


PhotoforOverlayAdj=imadjust(rescale(montagePhoto(:,:,14)));
NumeratorPlot=imadjust(rescale(Numerator2));
DenominatorPlot=imadjust(rescale(Denominator2));
QuickNormPlot=imadjust(QuickNorm3,[0.175 0.45],[],1); %Adjust to change image appearance

% J = customcolormap([0 0.25 0.5 0.75 1], {'#ffffff','#2A788E','#414487','#440154','#000000'});
J = customcolormap([0 0.5 1], {'#2A788E','#414487','#000000'}); %Adjust to change image appearance

if PlotNumDemDivisor
    figure, 
    m=montage({NumeratorPlot,DenominatorPlot,QuickNormPlot});
    title(strcat('Numerator=',string(i),' Denominator=', string(j)));
    colormap hot
    colorbar
   
end

if PlotOverlay
    if CleanSpace
    PhotoforOverlayAdj(test,:)=[];
    QuickNormPlot(test,:)=[];
    end    

    [hF,hB]=imoverlaygrad(PhotoforOverlayAdj,QuickNormPlot,[0.1 0.95],[],'hot',0.6); %Adjust to change image appearance
    title(strcat('Numerator=',string(i),' Denominator=', string(j)));
    colormap hot
    colorbar
    
end

if PlotHeatMap
    figure, 
    h=heatmap(QuickNorm3); %,'ColorLimits',[0.4 0.8]
    h.GridVisible = 'off';
    colormap default
end

    end
end

