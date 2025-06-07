function Reaction = mkReaction(beam)

    Fy = [];

    % Sort nodes, supports, and reactions
    [beam.nodes, sortIdx]    = sortrows(beam.nodes, [1 2]);
    beam.supports           = beam.supports(sortIdx, :);
    beam.reactions          = beam.reactions(sortIdx, :);

    startNode = beam.startNode;
    endNode   = beam.endNode;
    dx = abs(endNode(1) - startNode(1));
    dy = abs(endNode(2) - startNode(2));
    isX = dx > dy;

    if isX
        for i = 1:size(beam.nodes, 1)
            if any(beam.supports(i, :))  
  
                xloc = beam.nodes(i, 1) - startNode(1);
                reac = beam.reactions(i, 2); 
                Fy   = [Fy; xloc, reac];
            end
        end
    else
        for i = 1:size(beam.nodes, 1)
            if any(beam.supports(i, :))
         
                yloc = beam.nodes(i, 2) - startNode(2);
                reac = beam.reactions(i, 1); 
                Fy   = [Fy; yloc, -reac];
            end
        end
    end

    Reaction.Fy = Fy;

    
end