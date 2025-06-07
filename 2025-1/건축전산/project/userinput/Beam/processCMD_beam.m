function Beam = processCMD_beam(cmd, Beam)

addpath('userinput\Beam\process_beam');
addpath('userinput\Beam\plotBeam');
addpath('userinput\Beam\solveBeam');
addpath('userinput\Beam\assistBeam');
addpath('userinput\Beam\Image\');

    global exitFlag
    exitFlag = false;
    global statusFlag

    switch cmd(1)

        case "mknod"
            x = str2double(cmd(2));
            y = str2double(cmd(3));

            if ~isempty(Beam.lineBeam)
                for i = 1:length(Beam.lineBeam)
                    if any(ismember(Beam.lineBeam(i).nodes, [x,y], 'rows'))
                        disp('부재에 존재하는 노드입니다');
                        return;
                    end
                end
            end

            if isempty(Beam.dummyNodes)
                Beam.dummyNodes(end+1, :) = [x, y];

            elseif ~ismember([x, y], Beam.dummyNodes, 'rows')
                Beam.dummyNodes(end+1, :) = [x, y];

            else
                disp('중복된 좌표입니다');
            end

           
        case "delnod"
            x = str2double(cmd(2));
            y = str2double(cmd(3));

            if ~isempty(Beam.dummyNodes)
                idx = find(Beam.dummyNodes(:,1) == x & Beam.dummyNodes(:,2) == y, 1);
                if ~isempty(idx)
                    Beam.dummyNodes(idx,:) = [];
                    return;  
                end
            end

            [dummy, beamIdx,nodeIdx] = findNode(Beam,x,y);

            if ~isempty(beamIdx)
                for i = length(beamIdx):-1:1
                    Beam = deleteNode(Beam, beamIdx(i), nodeIdx(i));
                end
            end

        case "mkmem"
            Beam = addMem(Beam,cmd);

        case "delmem"

            x1 = str2double(cmd{2});
            y1 = str2double(cmd{3});
            x2 = str2double(cmd{4});
            y2 = str2double(cmd{5});

            Beam = delMem(Beam, x1, y1, x2, y2);

        case "fix"
            x = str2double(cmd(3));
            y = str2double(cmd(4));

            [dummy, beamIdx, nodeIdx] = findNode(Beam,x,y);

            switch cmd(2)
                case {"pinned", "pin"}
                    support = [1 1 0];
                case {"roller", "rol"}
                    support = [0 1 0];
                case {"yroller", "yrol"}
                    support = [1 0 0];
                case {"fixed", "fix"}
                    support = [1 1 1];
                otherwise
                    disp("알 수 없는 지점 타입입니다");
                    return;
            end

            if isempty(beamIdx)
                disp("지정한 위치의 노드가 존재하지 않습니다");
                return;
            end

            for i = 1:length(beamIdx)
                Beam.lineBeam(beamIdx(i)).supports(nodeIdx(i), :) = support;
            end

        case "load"

            dir = lower(cmd(2));
            x = str2double(cmd(3));
            y = str2double(cmd(4));
            power = str2double(cmd(5));

            switch dir
                case 'x'
                    loadType = 'point_x';
                case 'y'
                    loadType = 'point_y';
                otherwise
                    disp('하중 방향은 x 또는 y만 가능합니다.');
                    return;
            end

            flag = false;

            if ~isempty(Beam.lineBeam)
                for i = 1:length(Beam.lineBeam)
                    s = Beam.lineBeam(i).startNode;
                    e = Beam.lineBeam(i).endNode;
        
                    if isLine(x, y, s, e)
                        f = Beam.lineBeam(i).Force;
                        updated = false;
        
                        % 같은 힘이 존재하는지 확인
                        for j = 1:length(f.type)
                            if isequal(f.startpoint(j,:), [x, y]) && ...
                               isequal(f.endpoint(j,:), [x, y]) && ...
                               strcmp(f.type{j}, loadType)
        
                                Beam.lineBeam(i).Force.power(j) = power;
                                updated = true;
                                disp('이미 존재하는 힘의 크기를 바꾸었습니다');
                                break;
                            end
                        end
        
                        % 없다면 새로 추가
                        if ~updated
                            Beam.lineBeam(i).Force.startpoint(end+1, :) = [x, y];
                            Beam.lineBeam(i).Force.endpoint(end+1, :)   = [x, y];
                            Beam.lineBeam(i).Force.type{end+1}          = loadType;
                            Beam.lineBeam(i).Force.eqn{end+1}           = [];
                            Beam.lineBeam(i).Force.M(end+1)             = 0;
                            Beam.lineBeam(i).Force.power(end+1)         = power;
                        end
        
                        flag = true;
                    end
                end
            end
            if ~flag
                disp('하중을 적용할 beam이 없습니다');
            end


        case "ldist"
            
            dir = cmd(2);
            x1 = str2double(cmd(3));
            y1 = str2double(cmd(4));
            x2 = str2double(cmd(5));
            y2 = str2double(cmd(6));
            power = str2double(cmd(7));

            switch dir
                case "x"
                    loadType = 'unif_x';
                case "y"
                    loadType = 'unif_y';
                otherwise
                    disp("방향은 x 또는 y만 가능합니다.");
                    return;
            end

            flag = false;

            if ~isempty(Beam.lineBeam)
                for i = 1:length(Beam.lineBeam)
                    s = Beam.lineBeam(i).startNode;
                    e = Beam.lineBeam(i).endNode;
            
                    if isLine(x1, y1, s, e) && isLine(x2, y2, s, e)
                        f = Beam.lineBeam(i).Force;
                        updated = false;
        
                        for j = 1:length(f.type)
                            if isequal(f.startpoint(j,:), [x1, y1]) && ...
                               isequal(f.endpoint(j,:), [x2, y2]) && ...
                               strcmp(f.type{j}, loadType)
        
                                Beam.lineBeam(i).Force.power(j) = power;
                                updated = true;
                                disp('이미 존재하는 힘의 크기를 바꾸었습니다');
                                break;
                            end
                        end
        
                        if ~updated
                            Beam.lineBeam(i).Force.startpoint(end+1, :) = [x1, y1];
                            Beam.lineBeam(i).Force.endpoint(end+1, :)   = [x2, y2];
                            Beam.lineBeam(i).Force.type{end+1}          = loadType;
                            Beam.lineBeam(i).Force.eqn{end+1}           = [];
                            Beam.lineBeam(i).Force.M(end+1)             = 0;
                            Beam.lineBeam(i).Force.power(end+1)         = power;
                        end
        
                        flag = true;
                    end
                end
            end

            if ~flag
                disp('하중을 적용할 빔이 없습니다');
            end

        case "ltria"

            dir = cmd(2);
            x1 = str2double(cmd(3));
            y1 = str2double(cmd(4));
            x2 = str2double(cmd(5));
            y2 = str2double(cmd(6));
            power = str2double(cmd(7));

            switch dir
                case 'x'
                    loadType = 'dist_x';
                case 'y'
                    loadType = 'dist_y';
                otherwise
                    disp("하중 방향은 x 또는 y만 가능합니다.");
                    return;
            end

            flag = false;

            if ~isempty(Beam.lineBeam)
                for i = 1:length(Beam.lineBeam)
                    s = Beam.lineBeam(i).startNode;
                    e = Beam.lineBeam(i).endNode;
            
                    if isLine(x1, y1, s, e) && isLine(x2, y2, s, e)
                        f = Beam.lineBeam(i).Force;
                        updated = false;
        
                        for j = 1:length(f.type)
                            if isequal(f.startpoint(j,:), [x1, y1]) && ...
                               isequal(f.endpoint(j,:), [x2, y2]) && ...
                               strcmp(f.type{j}, loadType)
        
                                Beam.lineBeam(i).Force.power(j) = power;
                                updated = true;
                                disp('이미 존재하는 힘의 크기를 바꾸었습니다');
                                break;
                            end
                        end
        
                        if ~updated
                            Beam.lineBeam(i).Force.startpoint(end+1, :) = [x1, y1];
                            Beam.lineBeam(i).Force.endpoint(end+1, :)   = [x2, y2];
                            Beam.lineBeam(i).Force.type{end+1}          = loadType;
                            Beam.lineBeam(i).Force.eqn{end+1}           = [];
                            Beam.lineBeam(i).Force.M(end+1)             = 0;
                            Beam.lineBeam(i).Force.power(end+1)         = power;
                        end
        
                        flag = true;
                    end
                end
            end

            if ~flag
                disp('하중을 적용할 빔이 없습니다');
            end

        case "moment"
            x = str2double(cmd(2));
            y = str2double(cmd(3));
            M = str2double(cmd(4));

            flag = false;

            if ~isempty(Beam.lineBeam)
                for i = 1:length(Beam.lineBeam)
                    s = Beam.lineBeam(i).startNode;
                    e = Beam.lineBeam(i).endNode;
            
                    if isLine(x, y, s, e)
                        f = Beam.lineBeam(i).Force;
                        updated = false;
        
                        for j = 1:length(f.type)
                            if isequal(f.startpoint(j,:), [x, y]) && ...
                               isequal(f.endpoint(j,:), [x, y]) && ...
                               strcmp(f.type{j}, 'moment')
        
                                Beam.lineBeam(i).Force.M(j) = M;
                                updated = true;
                                disp('이미 존재하는 힘의 크기를 바꾸었습니다');
                                break;
                            end
                        end
        
                        if ~updated
                            Beam.lineBeam(i).Force.startpoint(end+1, :) = [x, y];
                            Beam.lineBeam(i).Force.endpoint(end+1, :)   = [x, y];
                            Beam.lineBeam(i).Force.type{end+1}          = 'moment';
                            Beam.lineBeam(i).Force.eqn{end+1}           = [];
                            Beam.lineBeam(i).Force.M(end+1)             = M;
                            Beam.lineBeam(i).Force.power(end+1)         = 0;
                        end
        
                        flag = true;
                    end
                end
            end

            if ~flag
                disp('하중을 적용할 빔이 없습니다');
            end

        case "info"
            if numel(cmd) > 1
                runInfo(Beam, string(cmd(2)));
            else
                runInfo(Beam, "full");
            end

        case "help"
            help_beam();

            case "quit"
                exitFlag = true;

        case "clear"
            Beam = struct();
            elementBeam = struct();
            Force = struct();
            
            elementBeam.nodes = [];
            elementBeam.supports = [];
            elementBeam.reactions = [];
            elementBeam.startNode = [];
            elementBeam.endNode = [];
            
            Force.startpoint = [];
            Force.endpoint = [];
            Force.type = {};
            Force.eqn = {};
            Force.M = [];
            Force.power = [];
            
            elementBeam.Force = Force;
            
            lineBeam = elementBeam; 
            
            Beam.lineBeam = repmat(elementBeam, 0, 1); 
            Beam.dummyNodes = [];

        case "show"
            totalPlot(Beam);

        case "solve"
            Beam = calReactions(Beam);

        case "clean"
            Beam = cleanBeam(Beam);

        case "cleanF"
            Beam = cleanF(Beam);

        case "Truss"
            statusFlag = "Truss";

        case "vi"
            imagePath = getPath(cmd(2));

            if ~isempty(imagePath)
                 [dummy] = convertImage(imagePath);
            else
                 disp('이미지를 찾을 수 없습니다');
            end
           






    end

end