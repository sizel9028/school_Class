function [nodes, members, supports, loads] = deleteError(nodes,members,supports,loads)
    
    if isempty(nodes)
        return;
    end

    n = size(nodes,1);

    if ~isempty(members)
        validMemberIdx = all(members >= 1 & members <= n, 2);
        removedMembers = sum(~validMemberIdx);
        members = members(validMemberIdx, :);

        disp(['invalid member : ', num2str(removedMembers), ' 제거']);
    end

 
    if ~isempty(supports)
        validSupportIdx = true(size(supports, 1), 1);

        for i = 1:size(supports, 1)
            a = supports(i, 1);
            x = supports(i, 2);
            y = supports(i, 3);
    
            if ~(a == 0 || a == 1)
                validSupportIdx(i) = false;
                continue;
            end
    
            if isempty(find(ismember(nodes, [x, y], 'rows'), 1))
                 validSupportIdx(i) = false;
            end
    
        end
    
        supports = supports(validSupportIdx, :);
        removedSupports = sum(~validSupportIdx);

        disp(['invalid support : ', num2str(removedSupports), ' 제거']);
    
    end

    if ~isempty(loads)
        validLoadIdx = true(size(loads, 1), 1);

        for i = 1:size(loads, 1)
            loadType = loads(i, 1);
            value = loads(i, 2);
            x = loads(i, 3);
            y = loads(i, 4);

            if ~(loadType == 0 || loadType == 1)
                validLoadIdx(i) = false;
                continue;
            end

            if isnan(value)
                validLoadIdx(i) = false;
                continue;
            end

            if isempty(find(ismember(nodes, [x, y], 'rows'), 1))
                validLoadIdx(i) = false;
            end
        end

        loads = loads(validLoadIdx, :);
        removedLoads = sum(~validLoadIdx);

        disp(['invalid load : ', num2str(removedLoads), ' 제거']);

    end


end