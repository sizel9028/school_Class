function members = delMember(nodes, members)

    if isempty(members)
        return;
    end
   
    n = size(nodes,1);
    removeMem = false(size(members,1),1);

    for i = 1:size(members,1)
        i1 = members(i,1);
        i2 = members(i,2);

        p1 = nodes(i1,:);
        p2 = nodes(i2,:);

        for j = 1:n
            if j == i1 || j == i2
                continue;
            end

            pj = nodes(j,:);

            if isLine(p1,p2,pj)
                removeMem(i) = true;
            end
        end
    end

    members = members(~removeMem, :);
    removedCount = sum(removeMem);

    disp(['중복 부재 : ', num2str(removedCount), ' 제거']);

end