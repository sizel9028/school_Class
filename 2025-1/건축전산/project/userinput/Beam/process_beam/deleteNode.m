function Beam = deleteNode(Beam,beamIdx, nodeIdx)

    beam = Beam.lineBeam(beamIdx);

    if size(beam.nodes,1) == 2 % 빔에 정확히 노드가 2개 있을때
        otherIdx = 3 - nodeIdx;
        Beam.dummyNodes(end+1,:) = beam.nodes(otherIdx, :);
        Beam.lineBeam(beamIdx) = [];
        disp('하나의 빔 라인이 삭제되었습니다');
        return;
    end

    % 빔에 노드가 3개 이상일때
    deletedNode = beam.nodes(nodeIdx, :);

    beam.nodes(nodeIdx,:) = [];
    beam.supports(nodeIdx,:) = [];
    beam.reactions(nodeIdx,:) = []; 


    if isequal(beam.startNode, deletedNode) || isequal(beam.endNode, deletedNode)

        remainingNodes = beam.nodes;

        minIdx = 1;
        maxIdx = 1;

        for i = 2:size(remainingNodes,1)
            node = remainingNodes(i, :);
    
            if node(1) < remainingNodes(minIdx,1) || ...
               (node(1) == remainingNodes(minIdx,1) && node(2) < remainingNodes(minIdx,2))
                minIdx = i;
            end
    
            if node(1) > remainingNodes(maxIdx,1) || ...
               (node(1) == remainingNodes(maxIdx,1) && node(2) > remainingNodes(maxIdx,2))
                maxIdx = i;
            end
        end

        beam.startNode = remainingNodes(minIdx, :);
        beam.endNode   = remainingNodes(maxIdx, :);

    end

    if ~isempty(beam.Force.power)  % Force 구조체가 비어있다면
        Beam.lineBeam(beamIdx) = beam;
        return;
    end

    force = beam.Force;
    xmin = beam.startNode(1); 
    xmax = beam.endNode(1);
    ymin = beam.startNode(2);
    ymax = beam.endNode(2);

    n = size(force.type, 1);
    keepIdx = true(n, 1);

    for i = 1:n
        sp_x = force.startpoint(i, 1);
        sp_y = force.startpoint(i, 2);
        ep_x = force.endpoint(i, 1);
        ep_y = force.endpoint(i, 2);

        if sp_x < xmin || ep_x > xmax
            keepIdx(i) = false;
        end

        if sp_y < ymin || ep_y > ymax
            keepIdx(i) = false;
        end
    end

    force.startpoint = force.startpoint(keepIdx, :);
    force.endpoint   = force.endpoint(keepIdx, :);
    force.type       = force.type(keepIdx, :);
    force.eqn        = force.eqn(keepIdx, :);
    force.M          = force.M(keepIdx, :);
    force.power      = force.power(keepIdx, :);

    beam.Force = force;
    Beam.lineBeam(beamIdx) = beam;

end

  