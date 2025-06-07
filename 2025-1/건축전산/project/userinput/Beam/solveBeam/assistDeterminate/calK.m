function K = calK(Beam)


    K = 0;

    if ~isfield(Beam, 'lineBeam') || isempty(Beam.lineBeam)
        return;
    end

    for i = 1:length(Beam.lineBeam)
        beam = Beam.lineBeam(i);
        nodes = beam.nodes;
        supports = beam.supports;

        k_count = 0;

        for j = 1:size(nodes, 1)
            nh = nodeHelper(Beam, i, j);

            if nh >= 2
                k_count = k_count + (nh - 1);
            else
                isStart = isequal(nodes(j, :), beam.startNode);
                isEnd   = isequal(nodes(j, :), beam.endNode);

                if isStart || isEnd
                    continue;
                end

                if any(supports(j, :))
                    k_count = k_count + 2;
                end
            end
        end

        K = K + k_count;
    end


    K = K / 2;
end
