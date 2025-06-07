function Beam = syncNodeForces(Beam)



    allNodes    = vertcat(Beam.lineBeam.nodes);
    uniqueNodes = unique(allNodes, 'rows');

    for k = 1:size(uniqueNodes,1)
        node = uniqueNodes(k,:);

        [~, beamIdxList, ~] = findNode(Beam, node(1), node(2));
        if numel(beamIdxList) < 2
            continue; 
        end

        nb = numel(beamIdxList);

        keysList = {};
        for bi = beamIdxList(:).'
            F = Beam.lineBeam(bi).Force;
            for j = 1:numel(F.type)

                if strcmp(F.type{j}, "internal")
                    continue;
                end
                if isequal(F.startpoint(j,:), node) && isequal(F.endpoint(j,:), node)
                    key = sprintf('%s|%g|%g', F.type{j}, F.power(j), F.M(j));
                    if ~any(strcmp(keysList, key))
                        keysList{end+1} = key; 
                    end
                end
            end
        end
        nk = numel(keysList);
        if nk == 0
            continue;
        end

        currCounts = zeros(nb, nk);
        for ii = 1:nb
            bi = beamIdxList(ii);
            F = Beam.lineBeam(bi).Force;
            for j = 1:numel(F.type)
                if strcmp(F.type{j}, "internal")
                    continue;
                end
                if isequal(F.startpoint(j,:), node) && isequal(F.endpoint(j,:), node)
                    key = sprintf('%s|%g|%g', F.type{j}, F.power(j), F.M(j));
                    idx = find(strcmp(keysList, key), 1);
                    currCounts(ii, idx) = currCounts(ii, idx) + 1;
                end
            end
        end

        needed = max(currCounts, [], 1);

        for ii = 1:nb
            bi = beamIdxList(ii);
            b = Beam.lineBeam(bi);
            F = b.Force;
            for m = 1:nk
                addCnt = needed(m) - currCounts(ii, m);
                if addCnt > 0
                    parts = split(keysList{m}, '|');
                    t = parts{1};
                    p = str2double(parts{2});
                    Mv = str2double(parts{3});
                    for c = 1:addCnt
                        F.startpoint(end+1, :) = node;
                        F.endpoint(  end+1, :) = node;
                        F.type{end+1,1}        = t;
                        F.power(end+1,1)       = p;
                        F.M(end+1,1)           = Mv;
                        F.eqn{end+1,1}         = '';
                    end
                end
            end
            Beam.lineBeam(bi).Force = F;
        end
    end
end
