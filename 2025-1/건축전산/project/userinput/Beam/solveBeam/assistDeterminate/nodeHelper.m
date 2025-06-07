function mCount = nodeHelper(Beam, beamIdx, nodeIdx)  


    if ~isfield(Beam, 'lineBeam') || isempty(Beam.lineBeam)
        mCount = 0;
        return;
    end


    targetNode = Beam.lineBeam(beamIdx).nodes(nodeIdx, :);
    mCount = 0;
    flag = 0;

    for i = 1:length(Beam.lineBeam)
        beam = Beam.lineBeam(i);
        nodes = beam.nodes;

        if any(ismember(nodes, targetNode, 'rows'))
            
            isStart = isequal(beam.startNode, targetNode);
            isEnd   = isequal(beam.endNode, targetNode);
            flag = flag + 1; 
            if ~(isStart || isEnd)
                mCount = mCount + 1;  
            end
        end
    end

    if flag == 2
        mCount = mCount + 2;
    end
end
