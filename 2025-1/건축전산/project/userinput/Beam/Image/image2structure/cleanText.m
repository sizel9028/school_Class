function commands = cleanText(rawText)
% cleanText - 여러 줄 텍스트에서 Beam 명령어 줄만 추출하여 반환
%
% 사용법:
%   commands = cleanText(rawText);
%
% 입력:
%   rawText : 명령어와 설명이 섞여 있는 여러 줄 텍스트 (char array 또는 string)
%
% 출력:
%   commands : 명령어만 담긴 cell array. 각 원소가 한 줄 명령어 문자열

    % 1️⃣ 입력을 string 배열로 변환 (char array 도 처리)
    if ischar(rawText)
        lines = splitlines(string(rawText));
    else
        lines = splitlines(rawText);
    end

    % 2️⃣ Beam 명령어 키워드 목록 정의
    cmdKeywords = { ...
        'mknod', 'delnod', 'mkmem', 'delmem', ...
        'fix', 'load', 'ldist', 'ltria', 'moment' ...
    };

    % 3️⃣ 결과용 cell array 초기화
    commands = {};

    % 4️⃣ 각 줄 검사하여, 명령어가 맞으면 commands에 추가
    for i = 1:numel(lines)
        line = strtrim(lines(i));
        if strlength(line) == 0
            continue;  % 빈 줄 무시
        end

        % 줄이 명령어로 시작하는지 확인
        isCmd = false;
        for k = 1:numel(cmdKeywords)
            if startsWith(line, cmdKeywords{k}, 'IgnoreCase', true)
                isCmd = true;
                break;
            end
        end

        if isCmd
            commands{end+1,1} = char(line);  %#ok<AGROW>
        end
    end
end
