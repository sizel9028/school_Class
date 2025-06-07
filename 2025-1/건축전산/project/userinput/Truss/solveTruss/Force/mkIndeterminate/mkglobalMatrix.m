function K = mkglobalMatrix(Truss)

    numNodes = size(Truss.nodes, 1);
    numMembers = size(Truss.members, 1);
    DOF = 2 * numNodes;
    
    K = zeros(DOF, DOF);

    for i = 1:numMembers
        k_local = mklocalMatrix(Truss, i);

        n1 = Truss.members(i, 1);
        n2 = Truss.members(i, 2);

        dof = [2*n1 - 1, 2*n1, 2*n2 - 1, 2*n2];

        for r = 1:4
            for c = 1:4
                K(dof(r), dof(c)) = K(dof(r), dof(c)) + k_local(r, c);
            end
        end

    end
 
end