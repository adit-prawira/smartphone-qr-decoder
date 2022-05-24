close all
clear
clc

I = imread("multiple1DBarcodesRotated.jpg");
I = rgb2gray(I);

% Apply method for blob detections in image
[~, cc] = detectMSERFeatures(I);
region_statistics = regionprops(cc, 'MajorAxisLength', 'MinorAxisLength');
min_aspect_ratio = 10;
candidate_regions = find(([region_statistics.MajorAxisLength]./[region_statistics.MinorAxisLength] > min_aspect_ratio));

% binarize image on filtered components;
BW = false(size(I));

for i = 1:length(candidate_regions)
    BW(cc.PixelIdxList{candidate_regions(i)}) = true;
end

BW = edge(BW, 'canny');
[H, T, R] = hough(BW);

% Determine size of the suppression neighborhood
reduction_ratio = 500;
nh_size = floor(size(H)/reduction_ratio);
idx = mod(nh_size, 2) < 1;
nh_size(idx) = nh_size(idx) + 1;

% get the peak of hough transform 
P = houghpeaks(H, length(candidate_regions), 'NHoodSize', nh_size);

% detect line based on detected peaks;
lines = houghlines(BW, T, R, P);

% display lines
Ihoughlines = ones(size(BW));


% start and end points of detected lines
start_points = reshape([lines(:).point1], 2, length(lines))';
end_points = reshape([lines(:).point2], 2, length(lines))';

Ihoughlines = insertShape(Ihoughlines, 'Line', [start_points, end_points], ...
    'LineWidth', 2, 'Color', 'green');
% [bounding_box, orientation, dilated_img] = segmentation_localization(Ihoughlines);
[bounding_box, orientation, Iclusters] = clustering_localization(lines, size(I));

Ibarlines = imoverlay(I, ~Ihoughlines(:,:,1));
corrected_images = cell(1, length(orientation));
for i = 1:length(orientation)
    I = insertShape(I, 'Rectangle', bounding_box(i,:), 'LineWidth', 3, 'Color', 'red');
    if orientation > 0
        orientation(i) = -(90 - orientation(i));
    else
        orientation(i) = 90 + orientation(i);
    end
    corrected_images{i} = imrotate(imcrop(I, bounding_box(i,:)), orientation(i));
end

figure(1)
imshow(Ibarlines, [])
% figure(2)
% imshow(dilated_img, [])
figure(3)
imshow(I, [])