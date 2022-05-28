function [detections, existing_regions, connected_components_img, ...
    edge_detected_img, h, t, r, hough_lines, ...
    barcodes] = perform_detection(img, use_segmentation)
    % input is the rbg image fromthe camera
    I = img;
    img_gray = rgb2gray(img); % convert rgb to gray scale
    
    % apply method for blob detections in image with 
    % Maximally Stable External Regions algorithm to find regions within
    % the image
    [regions, cc] = detectMSERFeatures(img_gray); % get connected components
    existing_regions = regions;
    
    % get region pixel length in MajorAxisLength and MinorAxisLength 
    region_statistics = regionprops(cc, 'MajorAxisLength','MinorAxisLength');

    % set the criteria for our minimum aspect ratio
    min_aspect_ratio = 10;

    % get the indices of the candidate regions that has aspect ratio of 
    % MajorAxisLength/MinorAxisLength > min_aspect_ratio
    % This is used to eliminated any regions that are suitable to be
    % considered as the barcode region candidates
    candidate_regions = find(([region_statistics.MajorAxisLength]./...
        [region_statistics.MinorAxisLength] > min_aspect_ratio));
 
    % Initialize a binary image of a the same size of the 
    % frame dimension
    img_binary = false(size(img_gray));

    % iterate indices of the candidate_regions, get the Pixel index list
    % of the connected components at the position for each candidate
    % region index and assign the value of true to indicates regions
    for i = 1:length(candidate_regions)
        img_binary(cc.PixelIdxList{candidate_regions(i)}) = true;
    end
    
    connected_components_img = img_binary;

    img_binary = edge(img_binary, 'canny'); % use canny edge detection

    [H, T, R] = hough(img_binary); % apply hough transform on the binary image
    edge_detected_img = img_binary;
    h = H;
    t = T;
    r = R;

    % get the size of the supression neighborhood
    reduction_ratio = 500;
    nh_size = floor(size(H)/reduction_ratio);
    index = mod(nh_size,2) < 1;
    nh_size(index) = nh_size(index) + 1;
    hough_lines=  [];

    if(~isempty(candidate_regions))
        % get hough transform peaks
        P = houghpeaks(H, length(candidate_regions), 'NHoodSize', nh_size);
        lines = houghlines(img_binary, T, R, P); % use hough transform peaks to detect lines
        
        if(~isempty(lines))
            if use_segmentation == 1
                % get the start and end points of the detected lines
                start_points = reshape([lines(:).point1], 2, length(lines))';
                end_points = reshape([lines(:).point2], 2, length(lines))';
                
                img_hough_lines = ones(size(img_binary));
                img_hough_lines = insertShape(img_hough_lines, 'Line', ...
                    [start_points, end_points] ,'LineWidth',10, 'Color', ...
                    'blue');
                % feed image with hough lines to segmentation_localization
                % and get bounding boxes and the orientation 
                % of the localization
                [bounding_box, orientation, ~] = ...
                    segmentation_localization(img_hough_lines);
                hough_lines = img_hough_lines;
            else
                % feed lines from hough transform peak to
                % clustering_localization
                [bounding_box, orientation, ~] = clustering_localization(lines, size(img_gray));
            end
            
            corrected_images = cell(1, length(orientation));

            % draw bounding box around localized barcodes
            % and corrected the orientation of the images of the barcode
            for i = 1: length(orientation)
                I = insertShape(I, "Rectangle", bounding_box(i, :),...
                    'LineWidth', 10, 'Color', 'cyan');
                if orientation > 0
                    orientation(i) = -(90 - orientation(i));
                else
                    orientation(i) = 90 + orientation(i);
                end
                corrected_images{i} = imrotate(imcrop(I, bounding_box(i, :)), ...
                    orientation(i));
            end
        end
    end
    
    barcodes = corrected_images; % return cropped barcodes
    detections = I; % return image with bounding boxes
end

