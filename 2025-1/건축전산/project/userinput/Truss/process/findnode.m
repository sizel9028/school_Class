function k = findnode(x,y,Truss)
    dummy = Truss.nodes;

    if isempty(dummy)
        k = -1;
        return;
    end

    idx = find(dummy(:,1) == x & dummy(:,2) == y, 1);

    if isempty(idx)
        k = -1;
    else
        k = idx;
    end

end