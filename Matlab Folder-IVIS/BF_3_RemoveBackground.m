%% User Input--Step 3
BackgroundNumbers= [3]; %Input numbers from "FindBackground" here.

%The numbers you enter will be removed from teh image so things don't get
%confusing. This is important because areas that are not animal tissue will
%throw off the next step

%After all the background is removed, move on to "UnMix"

%% Code

NoBack=matchingIdx;
Back=ismember(NoBack, BackgroundNumbers);
 NoBack(Back)=0;
BWMask=imbinarize(NoBack);


figure,  imagesc(NoBack)
axis off
title('Indices of Matching Endmembers')
colorbar
%

% 
% for m=1:size(CatNorm,3) 
%     CurrImg=CatNorm(:,:,m);
%     CurrImg(~BWMask)=0;
%    CatNormNoBack2(:,:,m)=CurrImg; 
% end