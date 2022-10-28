%% User Input--Step 1
clear all %#ok<*CLALL> 


%Put all of your "_SEQ" folders into one "Grandpa" folder and Type the path to that folder below in the quotations 
GrandpaFold="D:\Dropbox (VU Basic Sciences)\Brock Shared\Publications\First Paper\FigureDraftsData\ALL MATLAB\IVIS\Input\2022-09-29-Matlab IVIS";

%Put your ideal output image size here [x_size y_size]
sizeImage=[512 512];

%% Get the Images, Data, and Analyze
GrandpaFold=strcat(GrandpaFold,'\RBF*'); %Replace RBF with your IVIS name that starts the name of all the subfolders
D=dir(GrandpaFold); %Working Directory    


for k=1:size(D,1) %For all the of the directories within GrandapFold
    ImgName=D(k).name %Take the current Folder Name
    currD=fullfile(D(k).folder,D(k).name); %make a filepath to the particular folder

        % Use Text Data from Files
            F=dir(strcat(currD,'\**\AnalyzedClickInfo.txt'));%Get Text Data from AnalyzedClickInfo File     
            for m = 1:length(F) %For all of the text files  
               text = fileread(fullfile(F(m).folder,F(m).name));    %Read the Text Data
               splittext=strsplit(text,'\n');   %Split up the text by "enter" or new line
               if m==1      %Get the text from a specific spot in order to extract key data, here we're looking for the exposure Time
                    ExpoTime=strsplit(splittext{29},':'); %Sometimes different folders or files have different locations for the data, so you can adjust for that in this if statement
               else
                   ExpoTime=strsplit(splittext{29},':');
               end
               ExpoTimeNum=str2double(ExpoTime{2}); %Turn the data into numeric
               newStr{k,m}=ExpoTimeNum; %Store the data by SEQ folder (k) and wavelength Folder (m)
               % Do further operations
            end
    
    %Get Images
    imds=imageDatastore(currD,'IncludeSubfolders',true,'FileExtensions',{'.tif'},'LabelSource','foldernames'); %Creates a datastore of all hte images in the current folder
    Signal=2:4:length(imds.Files); %All the actual signal image, because there should be 4 images, may need to change the spacing for different machines
    FileList=table(imds.Files); %A list of all the files so you can check everything is okay
    SignalImages=zeros(sizeImage(1),sizeImage(2),length(Signal)); %Container for IVIS Signal images to make things faster
    Photo=zeros([size(readimage(imds,3)),length(Signal)]); %Container for IVIS Photographs to make things faster
    plane=1; %reset image plane each Loop
        for i=Signal
        
            FlourRef=imresize(readimage(imds,i-1),[size(readimage(imds,i))]);%Resize the fluorescence background reference image to the correct size
            
            %Important Note: Choose the "SignalImages" Function of your
            %choice and comment the rest out. Each one has different
            %degrees of background subtraction/ image correction, etc,
            %consistent with the IVIS software "FLbackground"

            %     SignalImages(:,:,plane)=imresize(double(readimage(imds,i)),sizeImage); %UnComment For RawSignal Image
            %     SignalImages(:,:,plane)=imresize(double(readimage(imds,i)-readimage(imds,i+2)),sizeImage); %Uncomment For Signal Image with Bias Subtraction
            %     SignalImages(:,:,plane)=imresize(double(readimage(imds,i)-readimage(imds,i+2))./double(FlourRef),sizeImage); %Uncomment For Signal Image with Reference Norm and Bias Subtraction
                 SignalImages(:,:,plane)=(imresize(double(readimage(imds,i)-readimage(imds,i+2))./double(FlourRef),sizeImage))./newStr{k,plane}; %Uncomment For Signal Image with TimeNorm, Reference Norm, and Bias Subtraction
            %      SignalImages(:,:,plane)=(imresize(double(readimage(imds,i)),sizeImage))./newStr{k,plane}; %Uncomment For Signal Image with TimeNorm
            %      SignalImages(:,:,plane)=(imresize(double(readimage(imds,i))./double(FlourRef),sizeImage))./newStr{k,plane}; %Uncomment For Signal Image with TimeNorm and ReferenceNorm
             
        
            SizeDif=size(readimage(imds,i))/sizeImage;
            plane=plane+1;
             Photo(:,:,plane)=imadjust(imresize(readimage(imds,i+1),[size(readimage(imds,i+1))]));
        end
    SignalImagesRaw=SignalImages;
    % SignalImages=uint16(SignalImages);
    PerPixSum=sum(SignalImages,3);
    PerPixNorm=double(SignalImages)./double(PerPixSum);
    
    RawImg(:,:,:,k)=SignalImages;
    NormImg(:,:,:,k)=PerPixNorm;
    Photos(:,:,:,k)=Photo;
    
end

%% Make Easier to look at image by making a montage

 DivK=divisors(k);
if rem(length(DivK), 2) == 1
   m=median(DivK,'all');
    [ImgsCat]=[m m];
else
     m= length(DivK(:)) ;% : treats as column even if this is actually a multidimensional array
midpoint = round(m/2);
select = DivK(midpoint:midpoint+1); % slightly unsymmetrical 1 before, 2 after
    [ImgsCat]=[select];

end

run=1;
RawImgCell=cell(ImgsCat(1),ImgsCat(2));
RawPhotoCell=cell(ImgsCat(1),ImgsCat(2));

for xPlacement=1:ImgsCat(1)
       for yPlacement=1:ImgsCat(2)
        RawImgCell{xPlacement,yPlacement}=RawImg(:,:,:,run);
        RawPhotoCell{xPlacement,yPlacement}=Photos(:,:,:,run);
        run=run+1;
       end
end
montageImg=cell2mat(RawImgCell);
figure,imshow(imadjust(rescale(montageImg(:,:,16))))
montagePhoto=cell2mat(RawPhotoCell);
figure,imshow(imadjust(rescale(montagePhoto(:,:,16))))


%% Make Hypercube and remove background
Wavelength=[480:10:690];
hcube= hypercube(montageImg,Wavelength); %Use matlab hyperspectral viewer and associated functions to explore this
