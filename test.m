close all
clear
clc
img = imread("multiple1DBarcodesRotated.jpg");
detections = perform_detection(img,0);
imshow(detections, [])