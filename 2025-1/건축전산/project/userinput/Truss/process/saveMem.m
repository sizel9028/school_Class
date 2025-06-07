function [newTruss,err] = saveMem(x1,y1,x2,y2,Truss)
    idx1 = findnode(x1,y1,Truss);
    idx2 = findnode(x2,y2,Truss);

    if idx1 == -1 || idx2 == -1
        newTruss = Truss;
        err = "node";
        return;
    end

    if ~isempty(Truss.members)
        if any(all(Truss.members == [idx1, idx2], 2)) || ...
           any(all(Truss.members == [idx2, idx1], 2))
           newTruss = Truss;
           err = "exist";
           return;
        end
    end

    Truss.members(end+1,:) = [idx1,idx2];
    newTruss = Truss;
    err = "success";
end