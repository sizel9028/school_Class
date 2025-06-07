function Beam = delMem(Beam,x1,y1,x2,y2)

    [Beam, beamIdxList1, nodeIdx1] = findNode(Beam, x1, y1);
    [Beam, beamIdxList2, nodeIdx2] = findNode(Beam, x2, y2);

    commonBeamIdx = intersect(beamIdxList1, beamIdxList2);

    if isempty(commonBeamIdx)
        disp("두 점을 이어주는 부재가 없습니다");
        return;
    end

    beamIdx = commonBeamIdx(1);
    beam = Beam.lineBeam(beamIdx);
    nodes = beam.nodes;

    idx1 = nodeIdx1(beamIdxList1 == beamIdx);
    idx2 = nodeIdx2(beamIdxList2 == beamIdx);

    if isempty(idx1) || isempty(idx2)
        disp("해당 노드가 beam에 없습니다.");
        return;
    end

    % 노드 2개만 있다면

    if size(nodes, 1) == 2

        for i = 1:2
            node = nodes(i, :);
            usedElsewhere = false;
            for b = 1:length(Beam.lineBeam)
                if b == beamIdx, continue; end
                if any(all(Beam.lineBeam(b).nodes == node, 2))
                    usedElsewhere = true;
                    break;
                end
            end
            if ~usedElsewhere
                Beam.dummyNodes(end+1, :) = node;
            end
        end    

        Beam.lineBeam(beamIdx) = [];
        disp("해당 빔은 삭제되었습니다");
        return;
    end

    node1 = [x1 y1];
    node2 = [x2 y2];

    startPt = beam.startNode;
    endPt = beam.endNode;



    if ( (isequal(node1, startPt) || isequal(node1, endPt)) && ...
         (isequal(node2, startPt) || isequal(node2, endPt)) )

        % 1) 삭제 대상 빔의 모든 노드 목록을 미리 저장
        allNodes = beam.nodes;

        % 2) 원래 부재(lineBeam) 삭제
        Beam.lineBeam(beamIdx) = [];

        % 3) 저장해 둔 모든 노드에 대해 dummyNodes 처리
        for i = 1:size(allNodes, 1)
            node = allNodes(i, :);
            usedElsewhere = false;
            % 남아 있는 다른 빔에 이 노드가 사용 중인지 확인
            for b = 1:length(Beam.lineBeam)
                if any(all(Beam.lineBeam(b).nodes == node, 2))
                    usedElsewhere = true;
                    break;
                end
            end
            % 사용 중이 아니면 dummyNodes에 추가
            if ~usedElsewhere
                Beam.dummyNodes(end+1, :) = node;
            end
        end

        disp("끝점-끝점 부재 삭제 및 모든 노드 dummyNodes로 이동 완료");
        return;
    end


    % 하나는 끝점 노드 하나는 중간 노드
    isvalid = false;


    % 끝점 중간 노드 사이에 있는 노드를 제거
    [~, sortIdx] = sortrows(beam.nodes, [1 2]);
    beam.nodes = beam.nodes(sortIdx, :);
    beam.supports = beam.supports(sortIdx, :);
    beam.reactions = beam.reactions(sortIdx, :);

    if (isequal(node1, startPt) || isequal(node1, endPt)) && ...
       ~(isequal(node2, startPt) || isequal(node2, endPt))
        endNode = node1;
        endIdx = nodeIdx1(beamIdxList1 == beamIdx);
        midNode = node2;
        midIdx = nodeIdx2(beamIdxList2 == beamIdx);
        isvalid = true;

    elseif (isequal(node2, startPt) || isequal(node2, endPt)) && ...
           ~(isequal(node1, startPt) || isequal(node1, endPt))
        endNode = node2;
        endIdx = nodeIdx2(beamIdxList2 == beamIdx);
        midNode = node1;
        midIdx = nodeIdx1(beamIdxList1 == beamIdx);
        isvalid = true;

    end    

    if (isempty(midIdx) || isempty(endIdx)) && isvalid
        disp("정렬 후 인덱스를 찾을 수 없습니다");
        return;
    end

    if isvalid
    
        if midIdx < endIdx
            delIdx = (midIdx+1):endIdx;  % 정방향: mid → end 포함
        elseif midIdx > endIdx
            delIdx = (endIdx+1):midIdx;  % 역방향: mid → end 포함
        else
            delIdx = [];  % 같은 노드인 경우 아무것도 삭제 안 함
        end
    
        delNodes = beam.nodes(delIdx, :);
    
        for i = 1:size(delNodes, 1)
            node = delNodes(i, :);
            usedElsewhere = false;
            for b = 1:length(Beam.lineBeam)
                if b == beamIdx, continue; end
                if any(all(Beam.lineBeam(b).nodes == node, 2))
                    usedElsewhere = true;
                    break;
                end
            end
            if ~usedElsewhere
                Beam.dummyNodes(end+1, :) = node;
            end
        end
    
        beam.nodes(delIdx, :) = [];
        beam.supports(delIdx, :) = [];
        beam.reactions(delIdx, :) = [];
    
        if ~isempty(beam.nodes)
            % startN, endN 재설정
            beam.startNode = min(beam.nodes, [], 1);
            beam.endNode   = max(beam.nodes, [], 1);

        end

        Beam.lineBeam(beamIdx) = beam;

    end

    % 내부 노드 2개일 경우 beam 쪼개기
    if ~(isequal(node1, startPt) || isequal(node1, endPt)) && ...
       ~(isequal(node2, startPt) || isequal(node2, endPt))
    
        % 정렬 후 인덱스 재지정
        [~, sortIdx] = sortrows(beam.nodes, [1 2]);
        sortedNodes = beam.nodes(sortIdx, :);
        sortedSupports = beam.supports(sortIdx, :);
        sortedReactions = beam.reactions(sortIdx, :); 
        
        idx1 = nodeIdx1(beamIdxList1 == beamIdx);
        idx2 = nodeIdx2(beamIdxList2 == beamIdx);
        i1 = find(sortIdx == idx1);
        i2 = find(sortIdx == idx2);

        tmp_i1 = i1;
        tmp_i2 = i2;
        i1 = min(tmp_i1, tmp_i2);
        i2 = max(tmp_i1, tmp_i2);
    
        for k = (i1+1):(i2-1)
            node = sortedNodes(k, :);
            usedElsewhere = false;
            for b = 1:length(Beam.lineBeam)
                if any(all(Beam.lineBeam(b).nodes == node, 2))
                    usedElsewhere = true;
                    break;
                end
            end
            if ~usedElsewhere
                Beam.dummyNodes(end+1, :) = node;
            end
        end
    
        Beam.lineBeam(beamIdx) = [];  % 원래 beam 삭제
    
        beamLeft = beam;  
        beamLeft.nodes    = sortedNodes(1:i1, :);
        beamLeft.supports = sortedSupports(1:i1, :);
        beamLeft.reactions = sortedReactions(1:i1, :);
        beamLeft.startNode = beamLeft.nodes(1, :);
        beamLeft.endNode   = beamLeft.nodes(end, :);
        beamLeft.Force     = initEmptyForce();
        Beam.lineBeam(end+1) = beamLeft;

        beamRight = beam;
        beamRight.nodes    = sortedNodes(i2:end, :);
        beamRight.supports = sortedSupports(i2:end, :);
        beamRight.reactions = sortedReactions(i2:end, :);
        beamRight.startNode = beamRight.nodes(1, :);
        beamRight.endNode   = beamRight.nodes(end, :);
        beamRight.Force     = initEmptyForce();
        Beam.lineBeam(end+1) = beamRight;


        disp("beam이 두 개 또는 세 개로 분할되었습니다.");
        return;
    end



end