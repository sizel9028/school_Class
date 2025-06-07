function force = determinate(Truss)
    
    numNodes = size(Truss.nodes,1);
    numMembers = size(Truss.members,1);
    numReactions = sum(Truss.supports,'all');

    A = zeros(2*numNodes,numMembers+numReactions);
    b = -reshape(Truss.loads.',[],1);

    for i = 1:numMembers
        n1 = Truss.members(i,1);
        n2 = Truss.members(i,2);

        dx = Truss.nodes(n2,1) - Truss.nodes(n1,1);
        dy = Truss.nodes(n2,2) - Truss.nodes(n1,2);
        L = (dx^2+dy^2)^(1/2);
        cx = dx / L;
        cy = dy / L;

        A(2*n1-1,i) = cx;
        A(2*n1,i) = cy;
        A(2*n2-1,i) = -cx;
        A(2*n2,i) = -cy;
    end

    reactionIdx = numMembers;

    for i = 1:length(Truss.supports)
        if Truss.supports(i,1) == 1
            reactionIdx = reactionIdx + 1;
            A(2*i-1, reactionIdx) = 1;
        end
        if Truss.supports(i,2) == 1
            reactionIdx = reactionIdx + 1;
            A(2*i, reactionIdx) = 1;
        end
    end

    force = A \ b;
    
end