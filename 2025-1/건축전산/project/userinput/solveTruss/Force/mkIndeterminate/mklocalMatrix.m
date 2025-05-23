function k = mklocalMatrix(Truss,i)

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

    A = Truss.A;
    E = Truss.E;

    k = (A * E / L) * ...
        [ c^2   c*s   -c^2   -c*s;
          c*s   s^2   -c*s   -s^2;
         -c^2  -c*s    c^2    c*s;
         -c*s  -s^2    c*s    s^2 ];

end