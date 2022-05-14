close all
clear
clc

IP = "192.168.1.143";

url = "http://" + IP + ":8080/shot.jpg";
ss  = imread(url);
fh = image(ss);

h = figure(1);
forever = 1;

[rows, columns] = size(ss);
image_capture = zeros(rows, columns);

while(forever)
    ss  = imread(url);
    set(fh,'CData',ss);
    drawnow;
    
    isKeyPressed = ~isempty(get(h,'CurrentCharacter'));
    if isKeyPressed
        image_capture = ss;
        break
    end
end
