function force = calForce(u, Truss)

    numMembers = size(Truss.members, 1);
    force = zeros(numMembers,1);

    for i = 1:numMembers
        n1 = Truss.members(i, 1);
        n2 = Truss.members(i, 2);

        x1 = Truss.nodes(n1, 1);
        y1 = Truss.nodes(n1, 2);
        x2 = Truss.nodes(n2, 1);
        y2 = Truss.nodes(n2, 2);

        dx = x2 - x1;
        dy = y2 - y1;
        L = sqrt(dx^2 + dy^2);
        c = dx / L;
        s = dy / L;

        dof = [2*n1-1, 2*n1, 2*n2-1, 2*n2];
        u_local = u(dof);

        delta_L = [c, s, -c, -s] * u_local;
        A = Truss.A;
        E = Truss.E;
        force(i) = -A * E / L * delta_L;
    end

end