function lsTruss()
    folder = fullfile('userinput','Truss', 'system', 'store');

    if ~isfolder(folder)
        disp(['폴더가 없습니다 :' + folder]);
        return;
    end

    files = dir(fullfile(folder, '*.mat'));

    if isempty(files)
        disp('저장된 .mat 파일이 없습니다');
        return;
    end
    
    filenames = {files.name};
    for i = 1:numel(filenames)
        fprintf('  %2d. %s\n', i, filenames{i});
    end

end 


