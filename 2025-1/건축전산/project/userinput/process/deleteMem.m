function newTruss = deleteMem(k,Truss)
    
    if isempty(Truss.members) 
        newTruss = Truss;
        return;
    end
   
    isConnected = Truss.members(:,1) == k | Truss.members(:,2) == k;
    Truss.members(isConnected, :) = [];
    newTruss = Truss;

end