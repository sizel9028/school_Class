function r = calR(Beam)


    r = 0;
    if ~isfield(Beam, 'lineBeam') || isempty(Beam.lineBeam)
        return;
    end

    allNodeRefs = [];
    nodeSupportMap = containers.Map();  

    for i = 1:length(Beam.lineBeam)
        beam = Beam.lineBeam(i);
        nodes = beam.nodes;
        supports = beam.supports;

        for j = 1:size(nodes, 1)
            node = nodes(j, :);
            nodeStr = nodeKey(node);

            if any(supports(j, :))
                if isKey(nodeSupportMap, nodeStr)
                    nodeSupportMap(nodeStr) = nodeSupportMap(nodeStr) + sum(supports(j, :));
                else
                    nodeSupportMap(nodeStr) = sum(supports(j, :));
                end
            end

            allNodeRefs = [allNodeRefs; node];
        end
    end

    uniqueNodes = unique(allNodeRefs, 'rows');

    for i = 1:size(uniqueNodes, 1)
        node = uniqueNodes(i, :);
        nodeStr = nodeKey(node);

        if ~isKey(nodeSupportMap, nodeStr)
            continue;
        end

        connectionCount = 0;
        for j = 1:length(Beam.lineBeam)
            if any(ismember(Beam.lineBeam(j).nodes, node, 'rows'))
                connectionCount = connectionCount + 1;
            end
        end
        
        supportVal = nodeSupportMap(nodeStr);
        r = r + (supportVal / connectionCount);
    end

    r = round(r);
end