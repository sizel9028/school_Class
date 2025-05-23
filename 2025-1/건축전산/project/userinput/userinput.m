function dummy = userinput(myInput)
    parts = strsplit(strtrim(myInput),' ');
    dummy = "nothing";

    if isempty(parts{1})
        return;
    end

    switch parts{1}
        case 'help'
            dummy = "help";

        case 'chmod'
            dummy = "chmod";

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

        case 'm'
            if numel(parts) < 3
                disp('좌표가 필요합니다');
                return;
            end

            x = parts{2};
            y = parts{3};

            numX = str2double(x);
            numY = str2double(y);

            if isnan(numX) || isnan(numY)
                disp('숫자가 아닙니다');
                return;
            end

            dummy = ["mkmemi",x,y];

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
                otherwise
                    disp('없는 타입입니다');
                    return;
            end

        case 'load'
            if numel(parts) < 4
                disp('좌표와 타입, 힘이 필요합니다');
                return;
            end

            newStr = erase(parts{2},{'(',')',' '});
            numDummy = strsplit(newStr,',');
            force = parts{3};

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

            type = parts{4};
            switch type
                case {'x','X'}
                    dummy = ["load","x",numDummy,force];
                case {'y','Y'}
                    dummy = ["load","y",numDummy,force];
                otherwise
                    disp('없는 타입입니다');
                    return;
            end

        case 'set'
            if numel(parts) < 3
                disp('숫자와 타입이 필요합니다');
                return;
            end

            newStr = erase(parts{3},{'(',')',' '});
            numDummy = strsplit(newStr,',');

            if numel(numDummy) ~= 1
                disp('좌표 형식이 잘못되었습니다');
                return;
            end

            checkNum = str2double(numDummy);
            if any(isnan(checkNum))
                disp('숫자 좌표가 아닙니다');
                return;
            end

            type = parts{2};
            switch type
                case {'e','E'}
                    dummy = ["set","e",numDummy];
                case {'a','A'}
                    dummy = ["set","a",numDummy];
                otherwise
                    disp('없는 타입입니다');
                    return;
            end


        case 'clear'
            dummy = "clear";

        case 'info'
            if numel(parts) > 1 && ischar(parts{2})
                dummy = ["info",string(parts{2})];
            else
                dummy = ["info","full"];
            end

        case 'undo'
            dummy = "undo";

        case 'show'
            dummy = "show";

        case {'solve','sol'}
            dummy = "solve";

        case 'ld'
            if numel(parts) < 2
                disp('파일 이름이 필요합니다');
                return;
            end

            dummy = ["ld",parts{2}];

        case 'sd'
            if numel(parts) < 2
                disp('파일 이름이 필요합니다');
                return;
            end

            dummy = ["sd",parts{2}];

        case 'rm'
            if numel(parts) < 2
                disp('파일 이름이 필요합니다');
                return;
            end

            dummy = ["rm",parts{2}];

        case 'ls'
            dummy = "ls";

        case {'q','exit','quit'}
            dummy = "quit";

        case {'vision'}
            if numel(parts) < 2
                disp('파일 이름이 필요합니다');
                return;
            end

            dummy = ["vi",parts{2}];

        case {'scale'}
            if numel(parts) < 3
                disp('인자가 부족합니다');
                return;
            end

            newStr = erase(parts{2},{'(',')',' '});
            numDummy = strsplit(newStr,',');

            if numel(numDummy) ~= 1
                disp('형식이 잘못되었습니다');
                return;
            end

            checkNum = str2double(numDummy);
            if any(isnan(checkNum))
                disp('숫자 배율이 아닙니다');
                return;
            end

            type = parts{3};
            switch type
                case {'x','X'}
                    dummy = ["scale","x",numDummy];
                case {'y','Y'}
                    dummy = ["scale","y",numDummy];
                otherwise
                    disp('없는 타입입니다');
                    return;
            end

        case {'mvn','mvnode'}
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

            dummy = ["mvn",numDummy];

        case {'lsimg','lsi'}
            dummy = "lsi";

       
    end

end