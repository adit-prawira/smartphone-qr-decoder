close all
clear
clc

% https://au.mathworks.com/help/vision/ug/localize-and-read-multiple-barcodes-in-image.html
IP = "192.168.1.143";

url = "http://" + IP + ":8080/shot.jpg";
ss  = imread(url);

[y, x] = size(rgb2gray(ss));
x_min = round(x/4);
y_min = round(y/4);
x_max = round(3*x/4);
y_max = round(3*y/4);
width = round(x/2);
height = round(y/2);
x_center = width;
y_center = height;

rectangleROI = true(y,x);
[x_rect, y_rect] = meshgrid(1:x, 1:y);
rectangleROI(y_min:y_max,x_min:x_max) = false;


fh = image(ss);

h = figure(1);
title("Streamed Camera")
forever = 1;

[rows, columns] = size(ss);
captured_image = zeros(rows, columns);
roi = [x_min, y_min, width, height];

while(forever)
    ss  = imread(url);
    detections = perform_detection(ss, 0);
    set(fh, 'CData', detections);
    drawnow;
    
    isKeyPressed = ~isempty(get(h,'CurrentCharacter'));
    if isKeyPressed
        captured_image = ss;
        break
    end
end

sigma = 30;

I = rgb2gray(captured_image);
I = imflatfield(I, sigma);
I = imbinarize(I);

figure(2)
imshow(captured_image, [])
title("Captured Image")
axis on

figure(3)
imshow(I, [])

