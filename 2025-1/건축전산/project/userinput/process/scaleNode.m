function Truss = scaleNode(Truss,scale,dir)

    if isempty(Truss.nodes)
        return;
    end

    switch dir
        case "x"
            Truss.nodes(:,1) = Truss.nodes(:,1) * scale;
        case "y"
            Truss.nodes(:,2) = Truss.nodes(:,2) * scale;
    end

end