function [bounding_box, orientation, dilated_img] = segmentation_localization(Ihoughlines)
    % convert detected lines to binary
    img = ~Ihoughlines(:,:,1);
    img(img > 0) = true;
    
    % perform dilation using disk structuring element
    disk_radius = 50;
    se = strel("disk", disk_radius, 8);
    dilated_img = imdilate(img, se);
    
    % perform barcode localization
    region_statistics = regionprops(dilated_img, "Orientation", "BoundingBox");

    % padding for the croped images
    padding = 40; % 40 pixels of padding
    bounding_box = zeros(length(region_statistics), 4);
    
    for i = 1:length(region_statistics)
        bounding_box(i, :) = region_statistics(i).BoundingBox;
        
        % create bounding box with padding
        bounding_box(i, 1) = bounding_box(i, 1) - padding;
        bounding_box(i, 2) = bounding_box(i, 2) - padding;
        bounding_box(i, 3) = bounding_box(i, 3) + 2*padding;
        bounding_box(i, 4) = bounding_box(i, 4) + 2*padding;
    end
    
    orientation = [region_statistics(:).Orientation];
    
end

