function [Beam, idx, nodeIdx] = findNode(Beam,x,y)

    idx = [];
    nodeIdx = [];
    
    if ~isempty(Beam.lineBeam)
        for i = 1:numel(Beam.lineBeam)

            if isempty(Beam.lineBeam(i).nodes)
                continue;
            end
            
            nodes = Beam.lineBeam(i).nodes;
    
            foundIdx = find((nodes(:,1) == x) & (nodes(:,2) == y), 1);
    
            if ~isempty(foundIdx)
                idx = [idx;i];
                nodeIdx = [nodeIdx;foundIdx];
            end
        end
    end

end