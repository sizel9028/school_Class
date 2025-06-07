function [dummy] = convertImage(imageFile)
addpath('userinput\Beam\Image\image2structure\');

    AItext = image2Text(imageFile);
    %disp(AItext);
    dummy = AItext;
    %Structure = text2Beam(AItext);
    text2Cmd(AItext);
end