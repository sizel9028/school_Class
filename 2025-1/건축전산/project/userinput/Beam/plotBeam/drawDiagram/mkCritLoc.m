function CritLoc = mkCritLoc(beam)

    if ~isempty(beam.Force.startpoint)
        [~, sortIdx] = sortrows(beam.Force.startpoint, [1 2]);
        beam.Force.type       = beam.Force.type(sortIdx);
        beam.Force.startpoint = beam.Force.startpoint(sortIdx, :);
        beam.Force.endpoint   = beam.Force.endpoint(sortIdx, :);
        beam.Force.power      = beam.Force.power(sortIdx);
        beam.Force.M          = beam.Force.M(sortIdx);
    end

    startNode = beam.startNode;
    endNode   = beam.endNode;
    dx = abs(endNode(1) - startNode(1));
    dy = abs(endNode(2) - startNode(2));
    isX = dx > dy;

    CritLoc = [];

    % Include distributed load bounds (relative)
    if ~isempty(beam.Force.startpoint)
        if isX
            for i = 1:length(beam.Force.type)
                t = beam.Force.type{i};
                if ismember(t, {'unif_y','dist_y'})
                    sp = beam.Force.startpoint(i,1) - startNode(1);
                    ep = beam.Force.endpoint(i,1)   - startNode(1);
                    CritLoc = [CritLoc, sp, ep];
                end
            end
        else
            for i = 1:length(beam.Force.type)
                t = beam.Force.type{i};
                if ismember(t, {'unif_x','dist_x'})
                    sp = beam.Force.startpoint(i,2) - startNode(2);
                    ep = beam.Force.endpoint(i,2)   - startNode(2);
                    CritLoc = [CritLoc, sp, ep];
                end
            end
        end
    end

    if ~isempty(beam.Force.startpoint) % point, internal 추가
        if isX
            for i = 1:length(beam.Force.type)
                t = beam.Force.type{i};
                if ismember(t, {'point_y','internal'})
                    % point/internal force 위치는 startpoint 기준
                    pos = beam.Force.startpoint(i,1) - startNode(1);
                    CritLoc = [CritLoc, pos];
                end
            end
        else
            for i = 1:length(beam.Force.type)
                t = beam.Force.type{i};
                if ismember(t, {'point_x','internal'})
                    pos = beam.Force.startpoint(i,2) - startNode(2);
                    CritLoc = [CritLoc, pos];
                end
            end
        end
    end

    % Include reaction positions (nodes with any reaction)
    for i = 1:size(beam.nodes,1)
        react = beam.reactions(i, :);
        if any(react ~= 0)
            if isX
                pos = beam.nodes(i,1) - startNode(1);
            else
                pos = beam.nodes(i,2) - startNode(2);
            end
            CritLoc = [CritLoc, pos];
        end
    end

    if ~isempty(beam.Force.startpoint)
        for i = 1:length(beam.Force.type)
            if strcmp(beam.Force.type{i}, 'moment')
                if isX
                    pos = beam.Force.startpoint(i,1) - startNode(1);
                else
                    pos = beam.Force.startpoint(i,2) - startNode(2);
                end
                CritLoc = [CritLoc, pos];
            end
        end
    end

    if isX
        CritLoc = [CritLoc, 0, dx];
    else
        CritLoc = [CritLoc, 0, dy];
    end

    % Unique and sort
    CritLoc = unique(CritLoc);
end
