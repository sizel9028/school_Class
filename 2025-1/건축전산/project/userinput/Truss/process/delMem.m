function [newTruss,err] = delMem(x1,y1,x2,y2,Truss)
    
    idx1 = findnode(x1,y1,Truss);
    idx2 = findnode(x2,y2,Truss);
    newTruss = Truss;

    if idx1 == -1 || idx2 == -1
        err = "node";
        return;
    end

    if ~isempty(Truss.members)
        isMatch = (Truss.members(:,1) == idx1 & Truss.members(:,2) == idx2) | ...
          (Truss.members(:,1) == idx2 & Truss.members(:,2) == idx1);
        if any(isMatch)
            Truss.members(isMatch,:) = [];
            Truss.A(isMatch,:) = [];
            Truss.E(isMatch,:) = [];
        else
            err = "exist";
            return;
        end
    end

    err = "success";
    newTruss = Truss;
    
end