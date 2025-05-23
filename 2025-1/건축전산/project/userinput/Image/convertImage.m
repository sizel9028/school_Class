function [Structure, dummy] = image(imageFile)
addpath('userinput\Image\image2structure');
%addpath('image2structure');

    AItext = image2Text(imageFile);
    disp(AItext);
    dummy = AItext;
    Structure = text2Truss(AItext);

end