function [Structure, dummy] = convertImage(imageFile)
addpath('userinput\Truss\Image\image2structure\');
%addpath('image2structure');

    AItext = image2Text(imageFile);
    %disp(AItext);
    dummy = AItext;
    Structure = text2Truss(AItext);

end