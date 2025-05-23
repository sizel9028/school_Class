function textOut = cleanText(rawText)
    % 1) ```matlab``` 태그 제거
    txt = regexprep(rawText, '```matlab|```', '');
    % 2) UTF-8 BOM 제거
    if ~isempty(txt) && double(txt(1)) == 65279
        txt(1) = [];
    end

    % 3) 특수 따옴표/대시 정리
    repl = {
        '“','"';  '”','"';
        '‘',''''; '’','''';
        '—','-';  '–','-';
        '…','...'
    };
    for k = 1:size(repl,1)
        txt = strrep(txt, repl{k,1}, repl{k,2});
    end

    % 4) 비 ASCII 문자 제거
    txt = regexprep(txt, '[^\x00-\x7F]', '');

    % 5) 줄 단위 분리
    lines = splitlines(txt);

    % 6) 변수 블록만 골라내기
    vars = {'nodes','members','supports','loads'};
    inside = false;
    bracketCount = 0;
    result = {};

    for i = 1:numel(lines)
        line = lines{i};
        t = strtrim(line);

        % 블록 시작 감지
        if ~inside
            for v = vars
                if startsWith(t, [v{1} ' ']) || startsWith(t, [v{1} '='])
                    inside = true;
                    break;
                end
            end
            if ~inside
                continue;
            end
        end

        % 주석 제거
        codeLine = regexprep(line, '%.*', '');
        % 빈 줄 건너뛰기
        if all(isspace(codeLine))
            continue;
        end

        result{end+1,1} = codeLine;  %#ok<AGROW>

        % 대괄호 열고 닫힘 개수 세기
        bracketCount = bracketCount + count(codeLine, '[') - count(codeLine, ']');
        if inside && bracketCount == 0
            inside = false;
        end
    end

    % 7) 한 문자열로 합치기
    textOut = strjoin(result, newline);
end
