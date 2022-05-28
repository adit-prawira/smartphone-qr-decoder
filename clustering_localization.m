function [bounding_box, orientation, Iclusters] = clustering_localization(lines, img_size)
    % Generate table to save the properties of the detected lines bisectors
    lines_bisector = array2table(zeros(length(lines), 4), 'Variablenames', ...
        {'theta','phi','x', 'y'});
    
    % determine orientation from the lines' angle
    i_negative = find([lines.theta] < 0);
    i_positive= find([lines.theta] >= 0);
    
    lines_bisector.theta(i_negative) = 90 + [lines(i_negative).theta];
    lines_bisector.theta(i_positive) = [lines(i_positive).theta] - 90;
    
    % get center point of detected lines
    center_points = zeros(length(lines), 2);
    
    % get phi values
    for i = 1:length(lines)
        center_points(i,:) = (lines(i).point1 + lines(i).point2)/2;
        lines_bisector.phi(i) = abs(center_points(i,2) - tand(lines(i).theta) * center_points(i,1))/...
            ((tand(lines(i).theta)^2 + 1) ^ 0.5);
    end
    
    % update [x, y] pf bisectors using their polar coordinates
    [lines_bisector.x, lines_bisector.y] = pol2cart(deg2rad(lines_bisector.theta), lines_bisector.phi, 'ro');
    
    % store [x, y] values of the bisectors to be used for clustering
    X = [lines_bisector.x, lines_bisector.y];
    
    % get pairwise distance between points
    D = pdist2(X, X);
    
    % calculate density-based spatial clustering (DBSCAN) algorithm which 
    % will separate the different barcodes in the image (classification).
    search_radius = max(img_size/5);
    min_points = 10;
    index = dbscan(D, search_radius, min_points);
    
    % get number of clusters (barcodes)
    num_clusters = unique(index(index > 0));
    
    % store endpoints of the detected lines
    data_X_Y = cell(1, length(num_clusters));
    Iclusters = ones(img_size);
    
    for i = 1:length(num_clusters)
        class_index = find(index == i); % get target class index
        rgb_color = rand(1, 3); % use random rgb color
        start_points = reshape([lines(class_index).point1], 2, length(class_index))';
        end_points = reshape([lines(class_index).point2], 2, length(class_index))';
        
        % render lines with of the current class
        Iclusters = insertShape(Iclusters, 'Line', [start_points, end_points], ...
            'LineWidth', 2, 'Color', rgb_color);
        
        % update the end points of the each cluster's line
        data_X_Y{i} = [start_points; end_points];
    end
    
    % Barcode localization
    orientation = zeros(1, length(num_clusters));

    % initialize bounding box
    bounding_box = zeros(length(num_clusters), 4);
    
    padding = 40;
    for i = 1:length(num_clusters)
        x1 = min(data_X_Y{i}(:, 1)) - padding;
        x2 = max(data_X_Y{i}(:, 1)) + padding;
        y1 = min(data_X_Y{i}(:, 2)) - padding;
        y2 = max(data_X_Y{i}(:, 2)) + padding;
        bounding_box(i,:) = [x1, y1, x2-x1, y2-y1];

        % get orientation of detected regions
        orientation(i) = mean(lines_bisector.theta(index == i));
    end
    
end
