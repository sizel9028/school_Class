function F = sumExternalForces(Beam, pt, excludeBeamIdx)
% sumExternalForces   pt에서 제외된 부재(excludeBeamIdx)를 잘라냈을 때
%                     남은 서브계에 작용하는 외부하중+반력의 합 [Fx,Fy]


    tol = 1e-6;
    N   = numel(Beam.lineBeam);

    adj = containers.Map('KeyType','char','ValueType','any');
    for j = 1:N
        if j == excludeBeamIdx
            continue;
        end
        b = Beam.lineBeam(j);

        for k = 1:size(b.nodes,1)
            key = nodeKey(b.nodes(k,:), tol);
            if isKey(adj, key)
                lst = adj(key);
                lst(end+1) = j;
                adj(key) = lst;
            else
                adj(key) = j;
            end
        end
    end

    [supportNodes, supportDOFs] = extractSupportsUnique(Beam);
    supMap = containers.Map('KeyType','char','ValueType','any');
    for s = 1:size(supportNodes,1)
        supMap(nodeKey(supportNodes(s,:),tol)) = supportDOFs(s,:);
    end
    visitedSupports = containers.Map('KeyType','char','ValueType','logical');


    startKey      = nodeKey(pt,tol);
    visitedNodes  = containers.Map('KeyType','char','ValueType','logical');
    visitedNodes(startKey) = true;
    visitedBeams  = false(1,N);
    queue         = {startKey};

    Fx = 0; Fy = 0;


    while ~isempty(queue)
        curKey = queue{1}; queue(1) = [];
        if ~isKey(adj,curKey), continue; end

        for idx = adj(curKey)
            if visitedBeams(idx), continue; end
            visitedBeams(idx) = true;
            b = Beam.lineBeam(idx);

      
            for m = 1:numel(b.Force.type)
                P    = b.Force.power(m);
                type = b.Force.type{m};
                sp   = b.Force.startpoint(m,:);
                ep   = b.Force.endpoint(m,:);

                if (strcmp(type,'point_x')||strcmp(type,'point_y')) && ...
                   norm(sp-pt)<tol
                    continue;
                end

                switch type
                    case 'point_x'
                        deg = numel(adj(nodeKey(sp,tol)));
                        Fx = Fx + P*(1/deg);
                    case 'point_y'
                        deg = numel(adj(nodeKey(sp,tol)));
                        Fy = Fy + P*(1/deg);

                    case 'unif_x'
                        L  = norm(ep-sp); Fx = Fx + P*L;
                    case 'unif_y'
                        L  = norm(ep-sp); Fy = Fy + P*L;

                    case 'dist_x'
                        L  = norm(ep-sp); Fx = Fx + P*L/2;
                    case 'dist_y'
                        L  = norm(ep-sp); Fy = Fy + P*L/2;
                end
            end

            for s = 1:size(supportNodes,1)
                node = supportNodes(s,:);
                if norm(node-pt)<tol, continue; end  
                sk = nodeKey(node,tol);
                if ~isKey(supMap,sk), continue; end

                if     norm(b.startNode-node)<tol, loc = 1;
                elseif norm(b.endNode  -node)<tol, loc = size(b.nodes,1);
                else   continue;
                end

                if ~isKey(visitedSupports,sk)
                    dof = supMap(sk);
                    r   = b.reactions(loc,1:2);  % [Rx, Ry]
                    if dof(1), Fx = Fx + r(1); end
                    if dof(2), Fy = Fy + r(2); end
                    visitedSupports(sk) = true;
                end
            end

            for k = 1:2
                nk = nodeKey(b.nodes(k,:),tol);
                if ~isKey(visitedNodes,nk)
                    visitedNodes(nk) = true;
                    queue{end+1}     = nk;
                end
            end
        end
    end

    F = [Fx, Fy];
end