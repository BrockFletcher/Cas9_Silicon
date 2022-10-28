%% User Input-- Step 2 (takes a while to run)
currCube=hcube;
%Look at the image that pops up. Figure out which color(s) look like
%background/unneeded areas you'd like to remove. 
% 
% Open this image, called "matchingIdx" from the workspace. 
% 
% Scroll through the matrix (that is the "matchingIDX" image) that pops up
% and make sure the colors that you thought you'd like to remove match up
% with the numbers actually in this matrix. In the example, it should be 3.
% 
% Once you know which Number(s) you'd like to remove, go to the next step
% "RemoveBackground"
%step

%% Code
numEndmembers = countEndmembersHFC(hcube);
endmembers = ppi(currCube,numEndmembers);
% endmembers = nfindr(hcube,numEndmembers);
score = zeros(size(hcube.DataCube,1),size(hcube.DataCube,2),numEndmembers);
for i = 1:numEndmembers
    score(:,:,i) = jmsam(hcube,endmembers(:,i));
end

[~,matchingIdx] = min(score,[],3);

figure,  imagesc(matchingIdx)
axis off
title('Indices of Matching Endmembers')
colorbar
%