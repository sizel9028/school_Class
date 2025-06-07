function Beam = mkjointForce(Beam)
addpath('userinput\Beam\solveBeam\calIntern\');
    tol = 1e-6;
    N   = numel(Beam.lineBeam);

    adj = containers.Map('KeyType','char','ValueType','any');
    for bi = 1:N
        b = Beam.lineBeam(bi);
        for k = 1:size(b.nodes,1)
            key = nodeKey(b.nodes(k,:), tol);
            if isKey(adj, key)
                adj(key) = [adj(key), bi];
            else
                adj(key) = bi;
            end
        end
    end

    for i = 1:N
        b   = Beam.lineBeam(i);
        isX = abs(b.startNode(2)-b.endNode(2)) < tol;

        for k = 1:size(b.nodes,1)
            pt  = b.nodes(k,:);
            key = nodeKey(pt, tol);
            if ~isKey(adj, key), continue; end

            deg = numel(adj(key));
            if deg < 2, continue; end 

            F  = sumExternalForces(Beam, pt, i);
            Fi = isX * F(2) + (~isX) * F(1);

            existing = [];
            for m = 1:numel(b.Force.type)
                if strcmp(b.Force.type{m}, 'internal') && ...
                   norm(b.Force.startpoint(m,:) - pt) < tol
                    existing = m; break;
                end
            end
            if isempty(existing)
                b.Force.type{end+1}        = 'internal';
                b.Force.startpoint(end+1,:) = pt;
                b.Force.endpoint(end+1,:)   = pt;
                b.Force.power(end+1)        = Fi;
                b.Force.M(end+1)            = 0;
            else
                b.Force.power(existing)     = Fi;
            end
        end

        Beam.lineBeam(i) = b;
    end
end