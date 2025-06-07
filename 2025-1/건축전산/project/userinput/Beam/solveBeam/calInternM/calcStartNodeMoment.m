function M = calcStartNodeMoment(Beam, beamIdx, refPoint)
% calcStartNodeMoment   시작점에 연결된 모든 부재의 외력+반력 모멘트 합


    tol = 1e-6;
    b0        = Beam.lineBeam(beamIdx);
    startNode = refPoint;

    N   = numel(Beam.lineBeam);
    adj = containers.Map('KeyType','char','ValueType','any');
    for j = 1:N
        if j == beamIdx, continue; end
        b = Beam.lineBeam(j);
        for k = 1:size(b.nodes,1)
            key = nodeKey(b.nodes(k,:), tol);
            if isKey(adj, key)
                arr    = adj(key);   
                arr(end+1) = j;    
                adj(key)   = arr;  
            else
                adj(key) = j;       
            end
        end
    end


    visitedNodes = containers.Map('KeyType','char','ValueType','logical');
    visitedBeams = false(1, N);
    queueNodes   = { nodeKey(startNode, tol) };
    visitedNodes(queueNodes{1}) = true;

    M = 0;

    while ~isempty(queueNodes)
        curKey = queueNodes{1};
        queueNodes(1) = [];
        if ~isKey(adj, curKey), continue; end

        beamList = adj(curKey);  
        for j = beamList
            if visitedBeams(j), continue; end
            visitedBeams(j) = true;
            b = Beam.lineBeam(j);

     
            for m = 1:numel(b.Force.type)
                type = b.Force.type{m};
                P    = b.Force.power(m);
                sp   = b.Force.startpoint(m,:);
                ep   = b.Force.endpoint(m,:);
                L    = norm(ep - sp);

                switch type
                    case {'point_x','point_y'}
                        F = [ strcmp(type,'point_x')*P, strcmp(type,'point_y')*P ];
                        r = sp - startNode;
                    case {'unif_x','unif_y'}
                        F = [ strcmp(type,'unif_x')*P*L, strcmp(type,'unif_y')*P*L ];
                        r = (sp + ep)/2 - startNode;
                    case {'dist_x','dist_y'}
                        F = [ strcmp(type,'dist_x')*P*L/2, strcmp(type,'dist_y')*P*L/2 ];
                        r = sp + (ep-sp)/3 - startNode;
                    otherwise
                        continue;
                end

                M = M + (r(1)*F(2) - r(2)*F(1));
            end


            for k = 1:size(b.reactions,1)
                R = b.reactions(k,1:2);
                if any(abs(R)>tol)
                    pos = b.nodes(k,:);
                    r   = pos - startNode;
                    M   = M + (r(1)*R(2) - r(2)*R(1));
                end
            end

            for k = 1:size(b.nodes,1)
                nk = nodeKey(b.nodes(k,:), tol);
                if ~isKey(visitedNodes, nk)
                    visitedNodes(nk)    = true;
                    queueNodes{end+1} = nk;
                end
            end
        end
    end
end
