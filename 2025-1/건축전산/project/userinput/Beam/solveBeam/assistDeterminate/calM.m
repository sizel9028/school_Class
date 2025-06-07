function m = calM(Beam)
% 각 beam의 끝점, 고정, 교차노드 기준으로 m을 계산 (m_count - 1 누적)

    m = 0;

    if ~isfield(Beam, 'lineBeam') || isempty(Beam.lineBeam)
        return;
    end

    for i = 1:length(Beam.lineBeam)
        beam = Beam.lineBeam(i);
        nodes = beam.nodes;
        supports = beam.supports;

        m_count = 0;

        for j = 1:size(nodes, 1)
            node = nodes(j, :);

            isStart = isequal(node, nodes(1, :));
            isEnd   = isequal(node, nodes(end, :));

            if isStart || isEnd
                m_count = m_count + 1;
                continue;
            end

            if any(supports(j, :))
                m_count = m_count + 1;
                continue;
            end

            nh = nodeHelper(Beam, i, j);
            if nh >= 2
                m_count = m_count + 1;
            end
        end

        m = m + (m_count - 1);
    end
    
end
