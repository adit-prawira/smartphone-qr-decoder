close all
clear
clc

img = imread("test_images/image1.jpeg");
[detections, existing_regions, connected_components_img, ...
    edge_detected_img, H, T, R, hough_lines] = perform_detection(img, 1);

figure(1)
title("Detected barcode")
imshow(detections, [])
axis on

figure(2)
title("Explicit existing regions")
imshow(img);
hold on;
plot(existing_regions,'showPixelList',true,'showEllipses',false);

figure(3)
title("Regions")
imshow(img);
hold on;
plot(existing_regions,'showPixelList',true,'showEllipses',false);

figure(4)
title("Connected components")
imshow(connected_components_img, []);

figure(5)
title("Canny Edge Detection")
imshow(edge_detected_img, []);

figure(6)
imshow(H,'XData',T,'YData',R,...
      'InitialMagnification','fit');
title('Hough transform');
xlabel('\theta'), ylabel('\rho');
axis on, axis normal, hold on;
colormap(gca,hot);

if(~isempty(hough_lines))
    figure(7)
    title("Hough Lines")
    imshow(imoverlay(img, ~hough_lines(:,:,1)), [])
    axis on
end


