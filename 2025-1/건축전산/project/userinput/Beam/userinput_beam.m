function dummy = userinput_beam(myInput)
    cleanInput = regexprep(strtrim(myInput), ',\s*', ',');

    parts = strsplit(cleanInput, ' ');
    dummy = "nothing";

    if isempty(parts{1})
        return;
    end

    switch parts{1}

        case {'mknod','mkn'}
            if numel(parts) < 2
                disp('좌표가 필요합니다');
                return;
            end

            newStr = erase(parts{2},{'(',')',' '});
            numDummy = strsplit(newStr,',');
            if numel(numDummy) ~= 2
                disp('좌표 형식이 잘못되었습니다');
                return;
            end
            
            x = str2double(numDummy{1});
            y = str2double(numDummy{2});

            if isnan(x) || isnan(y)
                disp('숫자 좌표가 아닙니다');
                return;
            end

            dummy = ["mknod",num2str(x),num2str(y)];

            case {'delnod','deln'}
            if numel(parts) < 2
                disp('좌표가 필요합니다');
                return;
            end

            newStr = erase(parts{2},{'(',')',' '});
            numDummy = strsplit(newStr,',');
            if numel(numDummy) ~= 2
                disp('좌표 형식이 잘못되었습니다');
                return;
            end
            
            x = str2double(numDummy{1});
            y = str2double(numDummy{2});

            if isnan(x) || isnan(y)
                disp('숫자 좌표가 아닙니다');
                return;
            end

            dummy = ["delnod",num2str(x),num2str(y)];

            case {'mkmem','mkm'}
            if numel(parts) < 2
                disp('좌표쌍이 필요합니다');
                return;
            end

            newStr = erase(parts{2},{'(',')',' '});
            numDummy = strsplit(newStr,',');

            if numel(numDummy) ~= 4
                disp('좌표 형식이 잘못되었습니다');
                return;
            end

            checkNum = str2double(numDummy);
            if any(isnan(checkNum))
                disp('숫자 좌표가 아닙니다');
                return;
            end

            dummy = ["mkmem",numDummy];

            case {'delmem','delm'}
            if numel(parts) < 2
                disp('좌표쌍이 필요합니다');
                return;
            end

            newStr = erase(parts{2},{'(',')',' '});
            numDummy = strsplit(newStr,',');

            if numel(numDummy) ~= 4
                disp('좌표 형식이 잘못되었습니다');
                return;
            end

            checkNum = str2double(numDummy);
            if any(isnan(checkNum))
                disp('숫자 좌표가 아닙니다');
                return;
            end

            dummy = ["delmem",numDummy];

            case 'fix'
            if numel(parts) < 3
                disp('좌표와 타입이 필요합니다');
                return;
            end

            newStr = erase(parts{2},{'(',')',' '});
            numDummy = strsplit(newStr,',');

            if numel(numDummy) ~= 2
                disp('좌표 형식이 잘못되었습니다');
                return;
            end

            checkNum = str2double(numDummy);
            if any(isnan(checkNum))
                disp('숫자 좌표가 아닙니다');
                return;
            end

            type = parts{3};
            switch type
                case {'pinned','pin'}
                    dummy = ["fix","pinned",numDummy];
                case {'roller','rol'}
                    dummy = ["fix","roller",numDummy];
                case {'yroller','yrol'}
                    dummy = ["fix","yroller",numDummy];
                case {'fixed','fix'}
                    dummy = ["fix","fix",numDummy];
                otherwise
                    disp('없는 타입입니다');
                    return;
            end

            case 'load'
            if numel(parts) < 4
                disp('좌표와 타입, 힘이 필요합니다');
                return;
            end

            newStr = erase(parts{3},{'(',')',' '});
            numDummy = strsplit(newStr,',');
            force = parts{4};

            if numel(numDummy) ~= 2
                disp('좌표 형식이 잘못되었습니다');
                return;
            end

            checkNum = str2double(numDummy);
            numForce = str2double(force);
            if any(isnan(checkNum)) && isnan(numForce)
                disp('숫자 좌표 또는 힘이 아닙니다');
                return;
            end

            type = parts{2};
            switch type
                case {'x','X'}
                    dummy = ["load","x",numDummy,force];
                case {'y','Y'}
                    dummy = ["load","y",numDummy,force];
                otherwise
                    disp('없는 타입입니다');
                    return;
            end

        case 'ldist'

            if numel(parts) < 4
                disp('좌표쌍과 타입, 하중 크기가 필요합니다');
                return;
            end
        
            newStr = erase(parts{3},{'(',')',' '});
            numDummy = strsplit(newStr,',');
        
            if numel(numDummy) ~= 4
                disp('좌표쌍 형식이 잘못되었습니다');
                return;
            end
        
            checkNum = str2double(numDummy);
            numForce = str2double(parts{4});
        
            if any(isnan(checkNum)) || isnan(numForce)
                disp('숫자 좌표 또는 하중이 아닙니다');
                return;
            end
        
            type = lower(parts{2});
            switch type
                case 'x'
                    dummy = ["ldist", "x", numDummy, parts{4}];
                case 'y'
                    dummy = ["ldist", "y", numDummy, parts{4}];
                otherwise
                    disp('없는 방향입니다');
                    return;
            end

        case 'ltria'

            if numel(parts) < 4
                disp('좌표쌍과 타입, 최대 하중 크기가 필요합니다');
                return;
            end
        
            newStr = erase(parts{3},{'(',')',' '});
            numDummy = strsplit(newStr,',');
        
            if numel(numDummy) ~= 4
                disp('좌표쌍 형식이 잘못되었습니다');
                return;
            end
        
            checkNum = str2double(numDummy);
            numForce = str2double(parts{4});
        
            if any(isnan(checkNum)) || isnan(numForce)
                disp('숫자 좌표 또는 하중이 아닙니다');
                return;
            end
        
            type = lower(parts{2});
            switch type
                case 'x'
                    dummy = ["ltria", "x", numDummy, parts{4}];
                case 'y'
                    dummy = ["ltria", "y", numDummy, parts{4}];
                otherwise
                    disp('없는 방향입니다');
                    return;
            end

        case 'moment'  % 반시계가 +

            if numel(parts) < 3
                disp('좌표와 모멘트 크기가 필요합니다');
                return;
            end
        
            newStr = erase(parts{2},{'(',')',' '});
            numDummy = strsplit(newStr,',');
        
            if numel(numDummy) ~= 2
                disp('좌표 형식이 잘못되었습니다');
                return;
            end
        
            checkNum = str2double(numDummy);
            numM = str2double(parts{3});
        
            if any(isnan(checkNum)) || isnan(numM)
                disp('숫자 좌표 또는 모멘트 값이 아닙니다');
                return;
            end
        
            dummy = ["moment", numDummy, parts{3}];

        case 'help'
            dummy = "help";

        case 'solve'
            dummy = "solve";

        case 'show'
            dummy = "show";

            case 'info'
            if numel(parts) > 1 && ischar(parts{2})
                dummy = ["info",string(parts{2})];
            else
                dummy = ["info","full"];
            end

            case {'q','exit','quit'}
            dummy = "quit";

            case {'vision'}
            if numel(parts) < 2
                disp('파일 이름이 필요합니다');
                return;
            end

            dummy = ["vi",parts{2}];

            case 'clear'
            dummy = "clear";

        case 'clean'
            dummy = "clean";

        case 'cleanF'
            dummy = "cleanF";

            %TODO set flag to Truss

        case {'chTruss','Truss','truss'}
            dummy = "Truss";



    end
end