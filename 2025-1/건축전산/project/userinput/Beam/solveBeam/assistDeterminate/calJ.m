function j = calJ(Beam)


    j = 0;

    if ~isfield(Beam, 'lineBeam') || isempty(Beam.lineBeam)
        return;
    end

    for i = 1:length(Beam.lineBeam)
        beam = Beam.lineBeam(i);
        nodes = beam.nodes;
        supports = beam.supports;

        for k = 1:size(nodes, 1)
            node = nodes(k, :);
            nh = nodeHelper(Beam, i, k);  

            if nh >= 2
                val = 0.5;
            else
                val = 1.0;
            end

            isStart = isequal(node, beam.startNode);
            isEnd   = isequal(node, beam.endNode);

            if isStart || isEnd
                j = j + val;
                continue;
            end

            if any(supports(k, :))
                j = j + val;
                continue;
            end

            if val == 0.5
                j = j + val;
            end
        end
    end
end
