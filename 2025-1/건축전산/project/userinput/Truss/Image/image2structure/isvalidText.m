function [bool, text] = isvalidText(text)

    text = cleanText(text);

    bool = ~contains(text, 'nodes') && ...
           ~contains(text, 'members') && ...
           ~contains(text, 'supports') && ...
           ~contains(text, 'loads');

    switch contains(text, 'nodes')
        case true
            disp('node 인식 성공');
        case false
            disp('node 인식 실패');
    end
    
    switch contains(text, 'members')
        case true
            disp('member 인식 성공');
        case false
            disp('member 인식 실패');
    end

    switch contains(text, 'supports')
        case true
            disp('support 인식 성공');
        case false
            disp('support 인식 실패');
    end

    switch contains(text, 'loads')
        case true
            disp('load 인식 성공');
        case false
            disp('load 인식 실패');
    end

end