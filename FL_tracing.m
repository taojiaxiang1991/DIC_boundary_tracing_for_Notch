function [MaskORGr,AreaN] = FL_tracing(N1,Thresh_back,MinCellSize,disksize)
%% Tracing: Creating the primary Binary images.
Mask = false(size(N1)); K = N1(N1>0);
Mask(N1>=mean(K)+Thresh_back.*std(K)) = true;  %When intensity is above certerin threshold, it is marked with 1.
%% Morphological filtering elements
Mask = bwareaopen(Mask,MinCellSize); %Remove small objects from binary image: Any eonclosed areas that's smaller than MinCellSize is considered as fragmenets
Mask = imclose(Mask,strel('disk',disksize)); % close image.
Mask = imfill(Mask,'holes'); %filling up all the holes in the image
%Mask = imclearborder(Mask); % The region that toches the border is not counted
MaskORGr = bwareaopen(Mask,MinCellSize); clear Mask; % Further removing the small spots.
% MaskNewA1 = imdilate(MaskORGr,strel('disk',24));
% MaskNewA1 = MaskNewA1-MaskORGr;

Labeling = bwlabel(MaskORGr); %Labeling each traced binary region.
stats = regionprops(Labeling,'Area','Perimeter','Centroid');
AreaN = cat(1,stats.Area);



