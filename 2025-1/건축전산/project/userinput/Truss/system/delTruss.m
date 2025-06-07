function success = delTruss(filename)
    filepath = fullfile('userinput','Truss', 'system', 'store', filename);

    if ~isfile(filepath)
        disp('파일이 존재하지 않습니다');
        success = false;
        return;
    end

    delete(filepath);
    disp(['삭제 완료: ' + filepath]);
    success = true;
end