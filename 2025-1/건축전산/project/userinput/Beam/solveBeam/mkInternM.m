function Beam = mkInternM(Beam)
% mkInternM   각 부재의 교차 노드에서만 작용·반작용 모멘트(internalM)를 추가·갱신

    addpath('userinput\Beam\solveBeam\calInternM\');
    tol = 1e-6;
    N = numel(Beam.lineBeam);


    nodeCount = containers.Map('KeyType','char','ValueType','double');
    for j = 1:N
        b = Beam.lineBeam(j);
        for k = 1:size(b.nodes,1)
            key = nodeKey(b.nodes(k,:), tol);
            if isKey(nodeCount, key)
                nodeCount(key) = nodeCount(key) + 1;
            else
                nodeCount(key) = 1;
            end
        end
    end

    for i = 1:N
        b = Beam.lineBeam(i);
        F = b.Force;

        for ni = 1:size(b.nodes,1)
            refPt = b.nodes(ni,:);
            key   = nodeKey(refPt, tol);

            % 교차가 아닌 단일 빔 노드면 건너뛰기
            if nodeCount(key) < 2
                continue;
            end

            Mi = -calcStartNodeMoment(Beam, i, refPt);

            found = false;
            idxs  = find(strcmp(F.type, 'internalM'));
            for m = idxs
                if norm(F.startpoint(m,:) - refPt) < tol
                    F.M(m)            = Mi;
                    F.power(m)        = 0;
                    F.startpoint(m,:) = refPt;
                    F.endpoint(m,:)   = refPt;
                    F.eqn{m}          = {};
                    found = true;
                    break;
                end
            end

            if ~found
  
                F.type{end+1}         = 'internalM';
                F.startpoint(end+1,:) = refPt;
                F.endpoint(end+1,:)   = refPt;
                F.M(end+1)            = Mi;
                F.power(end+1)        = 0;
                F.eqn{end+1}          = {};
            end
        end

        b.Force = F;
        Beam.lineBeam(i) = b;
    end
end
