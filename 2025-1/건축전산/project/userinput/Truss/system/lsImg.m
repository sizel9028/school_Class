function lsImg()
    folder = fullfile('myImage');

    if ~isfolder(folder)
        fprintf('폴더가 없습니다: %s\n', folder);
        return;
    end

    files = [ ...
        dir(fullfile(folder, '*.png')); 
        dir(fullfile(folder, '*.jpg')); 
        dir(fullfile(folder, '*.jpeg')) ...
    ];

    if isempty(files)
        disp('이미지 파일이 없습니다');
        return;
    end
    
    for i = 1:length(files)
        fprintf('  %2d. %s\n', i, files(i).name);
    end
end