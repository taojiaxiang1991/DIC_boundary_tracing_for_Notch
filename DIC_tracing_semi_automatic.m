function Data = DIC_tracing_semi_automatic(Expr,Thresh_back,min_scaling)
warning('off');  %Supresses the warning message generated
% path: The directory where all the DIC images are located.
%Expr = 'Uncompressed';
%% FL Tracing
%Thresh_back =10; %Threshold below which are considered as background.
disksize = 10; %parameters to close the image.
MinNSize = 100;
%% DIC Tracing parameter
DICfilt = 5;% 20; % remove DIC background (liberally)
DICopen = 100;%remove small spots from DIC
DICclose = 4;%smear together spots in DIC
DICerode = 4;%clear boundary of smeared DIC

%% Loading the image: and initializing Data
pathname = [Expr,'/'];
DAPIfile =   dir([pathname,'*c1.tif']);
NotchFile = dir([pathname,'*c2.tif']);
FBfile = dir([pathname,'*c3.tif']);
Data = [];
for j =1:length(DAPIfile)

    FiF = double(imread([pathname,FBfile(j).name])); DA = double(imread([pathname,DAPIfile(j).name]));
    NOT = double(imread([pathname,NotchFile(j).name]));
    %% Tracing
    [Mask] = FL_tracing(DA,Thresh_back,MinNSize,disksize); Mask = double(Mask);
    Labeling = bwlabel(Mask); stats = regionprops(Labeling,'Area','Centroid');
    Area = cat(1,stats.Area); centroids = cat(1,stats.Centroid);
    %% Plotting the Bright Field, DAPI, and Notch 3 channel
    figure(1); subplot(2,2,1); imshow(FiF,[]); hold on;
    subplot(2,2,2); imshow(DA,[]); hold on;
    subplot(2,2,3); imshow(NOT,[]); hold on;
    set(gcf,'units','normalized','outerposition',[0 0 1 1]); count = 1;

    for i = 1:length(Area)
        %% Removing Background of each respective channel, based on cell boundary (local background)
        Mask_N = Labeling==i;  Bou = bwboundaries(Mask_N); Bou = Bou{1};
        figure(2); subplot(1,2,1); imshow(FiF,[]); hold on; plot(Bou(:,2),Bou(:,1),'b-','linewidth',2);
        subplot(1,2,2); imshow(DA,[]); hold on; plot(Bou(:,2),Bou(:,1),'b-','linewidth',2);
        set(gcf,'units','normalized','outerposition',[0 0 1 1]);
        if Area(i)>=MinNSize*min_scaling
            sks = input('Is this a cell? ','s');
            if sks=='y'
                [x,y] = ginput(2); x = floor(x); y = floor(y);  close 2;
                MaskN = Mask_N(min(y):max(y),min(x):max(x));
                Notch3 = NOT(min(y):max(y),min(x):max(x)); DIC = FiF(min(y):max(y),min(x):max(x));
                %% Trace Cell Boundary with selected Region
                [MaskC] = DIC_auto(DIC, DICfilt, DICopen,DICclose,DICerode); MaskC = double(MaskC);
                %[MaskC] = FL_tracing(Notch3,Thresh_back/5,MinNSize,disksize); MaskC = double(MaskC);

                Lab = bwlabel(MaskC); statsc = regionprops(Lab,'Area');
                AreaC = cat(1,statsc.Area); [AreaC,b] = max(AreaC); MaskC = Lab==b; MaskC = double(MaskC);
                BC = bwboundaries(MaskC); BC = BC{1};
                MaskP = imdilate(MaskC,strel('disk',10)); MaskP2 = imdilate(MaskC,strel('disk',25));
                MaskP = MaskP2-MaskP; clear MaskP2;
                Notch3B = Notch3.*MaskP; Notch3S = Notch3.*MaskN; Notch3B = Notch3B(Notch3B~=0); Notch3S = Notch3S-mean(Notch3B(:)); Notch3S(Notch3S<0) = 0;
                Notch3C = Notch3.*MaskC;Notch3C = Notch3C-mean(Notch3B(:)); Notch3C(Notch3C<0) = 0;
                Data = [Data; j,count,Area(i),sum(Notch3S(:)), AreaC, sum(Notch3C(:))];
                save([Expr,'_Data.mat'],'Data');
                figure(1); subplot(2,2,1); plot(BC(:,2)+min(x),BC(:,1)+min(y),'r-','linewidth',2);
                text(centroids(i,1), centroids(i,2),int2str(count),'Color',[1 1 1],'FontSize',11,'FontWeight','bold','FontName','Times');
                subplot(2,2,3); plot(BC(:,2)+min(x),BC(:,1)+min(y),'r-',Bou(:,2),Bou(:,1),'b-','linewidth',2);
                text(centroids(i,1), centroids(i,2),int2str(count),'Color',[1 1 1],'FontSize',11,'FontWeight','bold','FontName','Times');
                subplot(2,2,2); plot(Bou(:,2),Bou(:,1),'b-','linewidth',2);
                text(centroids(i,1), centroids(i,2),int2str(count),'Color',[1 1 1],'FontSize',11,'FontWeight','bold','FontName','Times');
                count = count+1;
            else
                close 2;
            end
        end
    end
    Fig = getframe(gcf); [FrameNew,~] = frame2im(Fig);
    imwrite(FrameNew,[Expr,'_Frame',num2str(j),'.tif']); close 1;
end