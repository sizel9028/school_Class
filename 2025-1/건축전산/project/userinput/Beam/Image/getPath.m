function imagePath = getPath(imageName)

    baseFolder = fullfile(pwd, 'myImage');
    
    testPath = fullfile(baseFolder, imageName);
    
    if isfile(testPath)
        imagePath = testPath;
    else
        imagePath = '';
    end

end
