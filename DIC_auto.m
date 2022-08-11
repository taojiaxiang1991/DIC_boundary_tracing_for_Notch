function [Mask] = DIC_auto(DICName, DICfilt, DICopen,DICclose,DICerode)
DICName = DICName - mean(DICName(:));
%Filters image A with a 2D Gussian smoothing kernel
SubMat = imgaussfilt(DICName,DICfilt);
ContMat = DICName-SubMat; bw = lt(ContMat,0);
dist = bwdist(bw)+bwdist(~bw);
bw2 = gt(dist,1); bw3 = bwareaopen(bw2,DICopen); bw4 = imclose(bw3,strel('disk',DICclose));
bw5 = bwareaopen(bw4,DICopen); bw6 = imfill(bw5,'holes');
Mask = imerode(bw6,strel('disk',DICerode));
% Labeling = bwlabel(Mask); %Labeling each traced binary region.
% stats = regionprops(Labeling,'Area','Perimeter','Centroid');
% Perimeter = cat(1,stats.Perimeter); Area = cat(1,stats.Area);
% if ~isempty(Area)
%     [Area,b] = max(Area); Perimeter = Perimeter(b); Shape = (4.*pi.*Area)./(Perimeter.^2);
%     Mask = Labeling==b; Mask(Mask>=1)=1;
% end