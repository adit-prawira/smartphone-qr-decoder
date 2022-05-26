function detections = perform_detection(img, use_segmentation)
    % input is the rbg image fromthe camera
    I = img;
    img_gray = rgb2gray(img);
    
    % apply method for blob detections in image
    [~, cc] = detectMSERFeatures(img_gray); % get connected components
    region_statistics = regionprops(cc, 'MajorAxisLength','MinorAxisLength');
    min_aspect_ratio = 10;
    candidate_regions = find(([region_statistics.MajorAxisLength]./[region_statistics.MinorAxisLength] > min_aspect_ratio));
    img_binary = false(size(img_gray));
    for i = 1:length(candidate_regions)
        img_binary(cc.PixelIdxList{candidate_regions(i)}) = true;
    end
    img_binary = edge(img_binary, 'canny'); % use canny edge detection
    [H, T, R] = hough(img_binary); % apply hough transform on the binary image
    
    % get the zie of the supression neighborhood
    reduction_ratio = 500;
    nh_size = floor(size(H)/reduction_ratio);
    index = mod(nh_size,2) < 1;
    nh_size(index) = nh_size(index) + 1;

    % get hough transform peak
    P = houghpeaks(H, length(candidate_regions), 'NHoodSize', nh_size);
    lines = houghlines(img_binary, T, R, P);

    
    if use_segmentation == 1
        % get the start and end points of the detected lines
        start_points = reshape([lines(:).point1], 2, length(lines))';
        end_points = reshape([lines(:).point2], 2, length(lines))';
        
        img_hough_lines = ones(size(img_binary));
        img_hough_lines = insertShape(img_hough_lines, 'Line', ...
            [start_points, end_points] ,'LineWidth', 2, 'Color', ...
            'green');
        [bounding_box, orientation, ~] = ...
            segmentation_localization(img_hough_lines);
    else
        [bounding_box, orientation, ~] = clustering_localization(lines, size(img_gray));
    end
    
    corrected_images = cell(1, length(orientation));
    for i = 1: length(orientation)
        I = insertShape(I, "Rectangle", bounding_box(i, :),...
            'LineWidth', 3, 'Color', 'red');
        if orientation > 0
            orientation(i) = -(90 - orientation(i));
        else
            orientation(i) = 90 + orientation(i);
        end
        corrected_images{i} = imrotate(imcrop(I, bounding_box(i, :)), ...
            orientation(i));
    end
    detections = I;
end

