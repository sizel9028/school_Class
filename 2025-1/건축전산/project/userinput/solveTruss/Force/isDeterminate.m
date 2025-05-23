function bool = isDeterminate(Truss)

    n = size(Truss.nodes,1);
    m = size(Truss.members,1);
    r = sum(Truss.supports,'all');

    k = m+r-2*n;

    if k > 0
        bool = "indeterminate";
    elseif k == 0
        bool = "determinate";
    else
        bool = "unstable";
    end

end