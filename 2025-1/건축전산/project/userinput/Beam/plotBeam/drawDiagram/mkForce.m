function newForce = mkForce(beam,CritLoc)

    syms x

    % Sort forces
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


    if isempty(beam.Force.startpoint)
        newForce.type = {'non'};
        newForce.eqn  = {0};
        newForce.loc  = {0};
        newForce.M    = [0 0];
        return;
    end

    nSeg = length(CritLoc) - 1;
    type = cell(1, nSeg);
    eqn  = cell(1, nSeg);
    loc  = cell(1, nSeg);
    M    = beam.Force.M;


    for j = 1:nSeg
        L = CritLoc(j);
        R = CritLoc(j+1);
        segType = 'non';
        segIdx  = 0;

        for i = 1:length(beam.Force.type)
            if (isX && strcmp(beam.Force.type{i}, 'unif_y')) || (~isX && strcmp(beam.Force.type{i}, 'unif_x'))
                sp = beam.Force.startpoint(i, isX*1 + (~isX)*2) - startNode(isX*1 + (~isX)*2);
                ep = beam.Force.endpoint(i,   isX*1 + (~isX)*2) - startNode(isX*1 + (~isX)*2);
                if sp <= L && ep >= R
                    segType = 'unif'; segIdx = i;
                    break;
                end
            end
        end

        if strcmp(segType, 'non')
            for i = 1:length(beam.Force.type)
                if (isX && strcmp(beam.Force.type{i}, 'dist_y')) || (~isX && strcmp(beam.Force.type{i}, 'dist_x'))
                    sp = beam.Force.startpoint(i, isX*1 + (~isX)*2) - startNode(isX*1 + (~isX)*2);
                    ep = beam.Force.endpoint(i,   isX*1 + (~isX)*2) - startNode(isX*1 + (~isX)*2);
                    if sp <= L && ep >= R
                        segType = 'dist'; segIdx = i;
                        break;
                    end
                end
            end
        end
        if strcmp(segType, 'non')
            for i = 1:length(beam.Force.type)
                if (isX && ismember(beam.Force.type{i}, {'point_y','internal'})) || (~isX && ismember(beam.Force.type{i}, {'point_x','internal'}))
                    pLoc = beam.Force.startpoint(i, isX*1 + (~isX)*2) - startNode(isX*1 + (~isX)*2);
                    if pLoc >= L && pLoc < R
                        segType = 'point'; segIdx = i;
                        break;
                    end
                end
            end
        end

        dirFactor = 2*isX - 1;  

        switch segType
            case 'unif'

                eqn{j} = dirFactor * beam.Force.power(segIdx);
        
            case 'dist'

                pLoc = beam.Force.startpoint(segIdx, isX*1 + (~isX)*2) ...
                       - startNode(isX*1 + (~isX)*2);
                eLoc = beam.Force.endpoint(  segIdx, isX*1 + (~isX)*2) ...
                       - startNode(isX*1 + (~isX)*2);
                p    = beam.Force.power(segIdx);
        
                if pLoc < eLoc
                    eq0 = p * (x - pLoc);
                else
                    eq0 = -p * (x - eLoc) + p;
                end
        
                eqn{j} = dirFactor * eq0;
        
            case 'point'

                eqn{j} = dirFactor * beam.Force.power(segIdx);
        
            otherwise  
                eqn{j} = 0;
        end

        if strcmp(segType, 'point')
            loc{j} = beam.Force.startpoint(segIdx, isX*1 + (~isX)*2) - startNode(isX*1 + (~isX)*2);
        else
            loc{j} = CritLoc(j);
        end

        type{j} = segType;
    end

    newForce.type = type;
    newForce.eqn  = eqn;
    newForce.loc  = loc;


momentMat = zeros(0,2);
for ii = 1:numel(beam.Force.type)
    if strcmp(beam.Force.type{ii}, 'moment')
        if isX
            pos = beam.Force.startpoint(ii,1) - startNode(1);
        else
            pos = beam.Force.startpoint(ii,2) - startNode(2);
        end
        momentMat(end+1,:) = [pos, -beam.Force.M(ii)];
    end
end


idx_int = strcmp(beam.Force.type, 'internalM');
if any(idx_int)

    if isX
        pos_ints = beam.Force.startpoint(idx_int,1) - startNode(1);
    else
        pos_ints = beam.Force.startpoint(idx_int,2) - startNode(2);
    end
    internMs = beam.Force.M(idx_int);

    newEntries = [pos_ints(:), internMs(:)];
    momentMat = [momentMat; newEntries];


    [~, order] = sort(momentMat(:,1));
    momentMat = momentMat(order, :);
end

if ~isempty(beam.reactions)

    idx = ismember(beam.nodes, beam.startNode, 'rows');
    rowIdx = find(idx,1);
    if ~isempty(rowIdx)

        tol = 1e-6;
        zeroRows = abs(momentMat(:,1)) < tol;
        if any(zeroRows)
            momentMat(zeroRows,2) = momentMat(zeroRows,2) ...
                                   - beam.reactions(rowIdx,3);
        end
    end
end


if isempty(momentMat)
    momentMat = [0, 0];
end


    newForce.type = type;
    newForce.eqn  = eqn;
    newForce.loc  = loc;
    newForce.M    = momentMat;

end
