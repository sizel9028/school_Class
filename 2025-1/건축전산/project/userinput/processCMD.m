    function [newTruss,Stack] = processCMD(dummy,Truss,Stack)
        addpath('userinput/process');
        addpath('userinput/Stack');
        addpath('userinput/solveTruss');
        addpath('userinput/system');
        addpath('userinput/Image');
    
        global exitFlag
        exitFlag = false;
    
        newTruss = Truss;
    
        switch dummy(1)
    
            case "chmod"
                Stack = push(Stack,Truss);
                if Truss.status == "determinate"
                    Truss.status = "indeterminate";
                else
                    Truss.status = "determinate";
                end
    
            case "mknod"
                Stack = push(Stack,Truss);
                x = str2double(dummy(2));
                y = str2double(dummy(3));
             
                k = findnode(x,y,Truss);
                
         
    
                if k == -1
                    Truss.nodes(end+1, :) = [x, y];
                    Truss.loads(end+1, :) = [0, 0];
                    Truss.supports(end+1, :) = [0, 0];
                else
                    disp('이미 있는 노드입니다');
                end
    
            case "delnod"
                Stack = push(Stack,Truss);
                x = str2double(dummy(2));
                y = str2double(dummy(3));
    
                k = findnode(x,y,Truss);
    
                if k ~= -1
                    Truss.nodes(k,:) = [];
                    Truss.loads(k,:) = [];
                    Truss.supports(k,:) = [];
                    Truss = deleteMem(k,Truss);

                    if ~isempty(Truss.members)
                        for i = 1:size(Truss.members,1)
                            for j = 1:2
                                if Truss.members(i,j) > k
                                    Truss.members(i,j) = Truss.members(i,j) - 1;
                                end
                            end
                        end
                    end
                else
                    disp('존재하지 않는 노드입니다');
                end
    
            case "mkmem"
                Stack = push(Stack,Truss);
                x1 = str2double(dummy(2));
                y1 = str2double(dummy(3));
                x2 = str2double(dummy(4));
                y2 = str2double(dummy(5));
    
                [Truss, err] = saveMem(x1,y1,x2,y2,Truss);
    
                switch err
    
                    case "node"
                        disp('노드가 존재하지 않습니다');
                    case "exist"
                        disp('이미 존재하는 부재입니다');
    
                end
    
            case "mkmemi"
                Stack = push(Stack,Truss);
                x = str2double(dummy(2));
                y = str2double(dummy(3));
    
                if x > size(Truss.nodes,1) || y > size(Truss.nodes,1)
                    disp("존재하지 않는 노드 인덱스입니다");
                    return;
                end

                if x < 1 || y < 1
                    disp("존재하지 않는 노드 인덱스입니다");
                    return;
                end
    
                p1 = Truss.nodes(x, :);
                p2 = Truss.nodes(y, :);
    
                [Truss, err] = saveMem(p1(1),p1(2),p2(1),p2(2),Truss);
    
                switch err
    
                    case "node"
                        disp('노드가 존재하지 않습니다');
                    case "exist"
                        disp('이미 존재하는 부재입니다');
    
                end
    
            case "delmem"
                Stack = push(Stack,Truss);
                x1 = str2double(dummy(2));
                y1 = str2double(dummy(3));
                x2 = str2double(dummy(4));
                y2 = str2double(dummy(5));
    
                [Truss, err] = delMem(x1,y1,x2,y2,Truss);
    
                switch err
    
                    case "node"
                        disp('노드가 존재하지 않습니다');
                    case "exist"
                        disp('존재하지 않는 부재입니다');
    
                end
    
            case "fix"
                Stack = push(Stack,Truss);
                x = str2double(dummy(3));
                y = str2double(dummy(4));
    
                k = findnode(x,y,Truss);
    
                if k ~= -1
                    switch dummy(2)
                        
                        case "pinned"
                            Truss.supports(k,:) = [1, 1];
                        case "roller"
                            Truss.supports(k,:) = [0, 1];
                        case "yroller"
                            Truss.supports(k,:) = [1, 0];
    
                    end
                else
                    disp('노드가 존재하지 않습니다');
                end
    
            case "load"
                Stack = push(Stack,Truss);
                x = str2double(dummy(3));
                y = str2double(dummy(4));
                force = str2double(dummy(5));
                k = findnode(x,y,Truss);
    
                if k ~= -1
                    switch dummy(2)
                        
                        case "x"
                            Truss.loads(k,1) = force;
                        case "y"
                            Truss.loads(k,2) = force;
    
                    end
                else
                    disp('노드가 존재하지 않습니다');
                end
    
            case "set"
                Stack = push(Stack,Truss);
                type = dummy(2);
                setVal = str2double(dummy(3));
    
                switch type
    
                    case "a"
                        Truss.A = setVal;
                    case "e"
                        Truss.E = setVal;
    
                end
    
            case "clear"
                Stack = push(Stack,Truss);
                Truss.nodes = [];
                Truss.members = [];
                Truss.loads = [];
                Truss.A = 1;
                Truss.E = 1e9;
                Truss.status = "determinate";
                Truss.supports = [];
                Truss.memForces = [];
    
            case "undo"
                [Stack,undoTruss] = pop(Stack);
    
                if ~isempty(fieldnames(undoTruss))
                    Truss = undoTruss;
                end
    
            case "show"
                showTruss(Truss);
    
            case "solve"
                Stack = push(Stack,Truss);
                Truss = solveTruss(Truss);
    
            case "help"
                help();
    
            case "info"
                switch dummy(2)
    
                    case {"nodes","nod"}
                        disp(Truss.nodes);
                    case {"members","mem"}
                        disp(Truss.members);
                    case "loads"
                        disp(Truss.loads);
                    case {"a","A"}
                        disp(Truss.A);
                    case {"e","E"}
                        disp(Truss.E);
                    case {"status","stat"}
                        disp(Truss.status);
                    case {"supports","sup"}
                        disp(Truss.supports);
                    case {"memForces","force","Force","memf",'f'}
                        disp(Truss.memForces);
                    otherwise
                        disp(Truss);
    
                end
    
            case "ld"
                tmpTruss = loadTruss(dummy(2));
    
                if ~isfield(tmpTruss, 'nodes')
                    disp('파일이 존재하지 않습니다');
                    return;
                end
    
                Stack = push(Stack,Truss);
                Truss = tmpTruss;
    
            case "sd"
                saveTruss(Truss,dummy(2));
    
            case "rm"
                success = delTruss(dummy(2));
    
            case "ls"
                lsTruss();
    
            case "quit"
                exitFlag = true;

            case "vi"
                Path = findImagePath(dummy(2));
                if ~isempty(Path)
                    Stack = push(Stack,Truss);
                    [Truss, dummy] = convertImage(Path);
                else
                    disp('이미지를 찾을 수 없습니다');
                end
            
            case "scale"
                if isempty(Truss.nodes)
                    disp('배율을 곱할 노드가 없습니다');
                end

                Stack = push(Stack,Truss);
                Truss = scaleNode(Truss,str2double(dummy(3)),dummy(2));

            case "mvn"
                x1 = str2double(dummy(2));
                y1 = str2double(dummy(3));
                x2 = str2double(dummy(4));
                y2 = str2double(dummy(5));
                
                idx = findnode(x1,y1,Truss);

                if idx == -1
                    disp('해당 좌표가 없습니다');
                else
                    existIdx = findnode(x2,y2,Truss);
                    if existIdx ~= -1
                        disp('이미 존재하는 좌표입니다');
                    else

                        Stack = push(Stack,Truss);
                        Truss.nodes(idx, :) = [x2, y2];

                    end
                end

            case "lsi"
                lsImg();

                
        end
        
        newTruss = Truss;
    end