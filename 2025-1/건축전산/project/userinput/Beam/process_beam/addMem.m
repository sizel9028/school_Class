function Beam = addMem(Beam,cmd)

            x1 = str2double(cmd(2));
            y1 = str2double(cmd(3));
            x2 = str2double(cmd(4));
            y2 = str2double(cmd(5));

            isDummy1 = false;
            isDummy2 = false;

            if ~isempty(Beam.dummyNodes)
                isDummy1 = any(Beam.dummyNodes(:,1) == x1 & Beam.dummyNodes(:,2) == y1);
                isDummy2 = any(Beam.dummyNodes(:,1) == x2 & Beam.dummyNodes(:,2) == y2);
            end
        
            [Beam, beamIdx1, nodeIdx1] = findNode(Beam, x1, y1);
            [Beam, beamIdx2, nodeIdx2] = findNode(Beam, x2, y2);

            if (isempty(beamIdx1) && ~isDummy1) || (isempty(beamIdx2) && ~isDummy2)
                disp('노드가 존재하지 않습니다');
                return;
            end

            if isDummy1 && isDummy2  % 둘다 더미에 있을때
                newBeam = struct();
                newBeam.nodes = [x1 y1; x2 y2];
                newBeam.reactions = zeros(2, 3);
                newBeam.supports = zeros(2, 3);  
                if x1 < x2 || (x1 == x2 && y1 < y2)
                    newBeam.startNode = [x1 y1];
                    newBeam.endNode   = [x2 y2];
                else
                    newBeam.startNode = [x2 y2];
                    newBeam.endNode   = [x1 y1];
                end

                newForce = struct();
                newForce.startpoint = [];
                newForce.endpoint = [];
                newForce.type = {};
                newForce.eqn = {};
                newForce.M = [];
                newForce.power = [];
                newBeam.Force = newForce;

                Beam.lineBeam(end+1) = newBeam;

                idx1 = find(Beam.dummyNodes(:,1) == x1 & Beam.dummyNodes(:,2) == y1, 1);
                idx2 = find(Beam.dummyNodes(:,1) == x2 & Beam.dummyNodes(:,2) == y2, 1);
                Beam.dummyNodes([idx1, idx2], :) = [];

                disp('새로운 빔라인을 만들었습니다');
                return;
            end

            % 하나는 더미 하나는 빔에 있을때
            if (isDummy1 && ~isempty(beamIdx2)) || (isDummy2 && ~isempty(beamIdx1))
                dummyX = isDummy1 * x1 + isDummy2 * x2; % 삼항연산자
                dummyY = isDummy1 * y1 + isDummy2 * y2;

                 if isDummy1
                    beamIdxList = beamIdx2;
                else
                    beamIdxList = beamIdx1;
                 end

                validBeamIdxList = [];
                for k = 1:length(beamIdxList)
                    beamIdx = beamIdxList(k);
                    beam = Beam.lineBeam(beamIdx);
                
                    x0 = beam.startNode(1); y0 = beam.startNode(2);
                    xEnd = beam.endNode(1); yEnd = beam.endNode(2);
                
                    dx = xEnd - x0;
                    dy = yEnd - y0;
                    dx_new = dummyX - x0;
                    dy_new = dummyY - y0;
                
                    if abs(dx * dy_new - dy * dx_new) < 1e-6
                        validBeamIdxList(end+1) = beamIdx;
                    end
                end
    
                    if ~isempty(validBeamIdxList)

                        beamIdx = validBeamIdxList(1);

                        % 이 부분 ↓ dummyX 비교할 기준을 정확하게 가져와야 함
                        x0 = Beam.lineBeam(beamIdx).startNode(1);
                        y0 = Beam.lineBeam(beamIdx).startNode(2);
                        xEnd = Beam.lineBeam(beamIdx).endNode(1);
                        yEnd = Beam.lineBeam(beamIdx).endNode(2);
    
                        Beam.lineBeam(beamIdx).nodes(end+1, :) = [dummyX dummyY];
                        Beam.lineBeam(beamIdx).reactions(end+1,:) = [0 0 0];
                        Beam.lineBeam(beamIdx).supports(end+1, :) = [0 0 0]; 

                
                        if dummyX < x0 || (dummyX == x0 && dummyY < y0)
                            Beam.lineBeam(beamIdx).startNode = [dummyX dummyY];
                        elseif dummyX > xEnd || (dummyX == xEnd && dummyY > yEnd)
                            Beam.lineBeam(beamIdx).endNode = [dummyX dummyY];
                        end
                
                        Beam.dummyNodes = Beam.dummyNodes(~(Beam.dummyNodes(:,1) == dummyX & Beam.dummyNodes(:,2) == dummyY), :);
                
                        disp('기존 빔라인에 노드를 추가했습니다');
                        return;
                    else
                        newBeam = struct();
                        newBeam.nodes = [dummyX dummyY];
    
                        if isDummy1
                            newBeam.nodes(end+1, :) = [x2 y2];
                        else
                            newBeam.nodes(end+1, :) = [x1 y1];
                        end
    
                        if dummyX < (isDummy1 * x2 + isDummy2 * x1) || ...
                           (dummyX == (isDummy1 * x2 + isDummy2 * x1) && dummyY < (isDummy1 * y2 + isDummy2 * y1))
                            newBeam.startNode = [dummyX dummyY];
                            newBeam.endNode   = isDummy1 * [x2 y2] + isDummy2 * [x1 y1];
                        else
                            newBeam.endNode   = [dummyX dummyY];
                            newBeam.startNode = isDummy1 * [x2 y2] + isDummy2 * [x1 y1];
                        end
    
                        newBeam.supports = zeros(2,3);
                        newBeam.reactions = zeros(2,3);
    
                        newForce = struct();
                        newForce.startpoint = [];
                        newForce.endpoint = [];
                        newForce.type = {};
                        newForce.eqn = {};
                        newForce.M = [];
                        newForce.power = [];
                        newBeam.Force = newForce;
    
                        Beam.lineBeam(end+1) = newBeam;
    
                        Beam.dummyNodes = Beam.dummyNodes(~(Beam.dummyNodes(:,1) == dummyX & Beam.dummyNodes(:,2) == dummyY), :);
    
                        disp('새로운 빔을 만들었습니다');
                    end

                
            end

           tol = 1e-6;

            if ~isempty(beamIdx1) && ~isempty(beamIdx2)
                for i = 1:length(beamIdx1)
                    for j = 1:length(beamIdx2)
                        b1 = beamIdx1(i);
                        b2 = beamIdx2(j);
            
                        if b1 == b2
                            disp('이미 같은 빔에 속합니다');
                            return;
                        end
            
                        beam1 = Beam.lineBeam(b1);
                        beam2 = Beam.lineBeam(b2);
            
                        % 방향 벡터 계산
                        dx1 = beam1.endNode(1)   - beam1.startNode(1);
                        dy1 = beam1.endNode(2)   - beam1.startNode(2);
                        dx2 = beam2.endNode(1)   - beam2.startNode(1);
                        dy2 = beam2.endNode(2)   - beam2.startNode(2);
            
                        % 1) 평행 여부 (기울기 비교)
                        slopeMatch = abs(dx1*dy2 - dy1*dx2) < tol;
                        % 2) 같은 직선상에 있는지 (한 점 검사)
                        collinear  = abs((beam2.startNode(1)-beam1.startNode(1))*dy1 ...
                                        - (beam2.startNode(2)-beam1.startNode(2))*dx1) < tol;
            
                        if slopeMatch && collinear
                  
                            newBeam = struct();
                            newBeam.nodes = [beam1.nodes; beam2.nodes];
                            [newBeam.nodes, ia, ~] = unique(newBeam.nodes, 'rows', 'stable');
            
   
                            xA = beam1.startNode(1); yA = beam1.startNode(2);
                            xB = xA;              yB = yA;
            
                            x = beam2.startNode(1); y = beam2.startNode(2);
                            if x < xA || (x == xA && y < yA)
                                xA = x; yA = y;
                            end
                            if x > xB || (x == xB && y > yB)
                                xB = x; yB = y;
                            end
            
                            % beam2.endNode 고려
                            x = beam2.endNode(1); y = beam2.endNode(2);
                            if x < xA || (x == xA && y < yA)
                                xA = x; yA = y;
                            end
                            if x > xB || (x == xB && y > yB)
                                xB = x; yB = y;
                            end
            
                            newBeam.startNode = [xA, yA];
                            newBeam.endNode   = [xB, yB];
            
                            % supports, reactions 병합
                            allSupports = [beam1.supports; beam2.supports];
                            allReacts   = [beam1.reactions; beam2.reactions];
                            newBeam.supports  = allSupports(ia, :);
                            newBeam.reactions = allReacts(ia, :);
            
                            % Force 초기화
                            newBeam.Force = struct( ...
                                'startpoint', [], ...
                                'endpoint',   [], ...
                                'type',       {{}}, ...
                                'eqn',        {{}}, ...
                                'M',          [], ...
                                'power',      []  ...
                            );
            
                            % 기존 두 빔 삭제 후 새 빔 추가
                            toDel = sort([b1, b2], 'descend');
                            Beam.lineBeam(toDel) = [];
                            Beam.lineBeam(end+1) = newBeam;
            
                            disp('두 빔을 합칩니다');
                            return;
                        else
                            disp('같은 직선 위에 있지 않아 합치지 않습니다.');
                        end
                    end
                end
            end



end