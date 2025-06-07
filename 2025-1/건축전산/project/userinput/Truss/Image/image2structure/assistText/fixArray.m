function [nodes, members, supports, loads] = fixArray(nodes, members, supports, loads)

    if isempty(nodes)
        return;
    end

    n = size(nodes,1);
    supp = zeros(n,2);
    load = zeros(n,2);

    if ~isempty(supports)
        for i = 1:size(supports,1)
            type = supports(i,1);
            x = supports(i,2);
            y = supports(i,3);
    
            idx = find(ismember(nodes,[x,y],'rows'),1);

            if ~isempty(idx)
                if type == 0
                    supp(idx,:) = [1,1];
                elseif type == 1
                    supp(idx,:) = [0,1];
                end
            end
        end
    end

    supports = supp;

    if ~isempty(loads)
        for i = 1:size(loads,1)
            dir = loads(i,1);
            force = loads(i,2);
            x = loads(i,3);
            y = loads(i,4);

            idx = find(ismember(nodes, [x, y], 'rows'), 1);

            if ~isempty(idx)
                if dir == 0
                    load(idx, 1) = force; 
                elseif dir == 1
                    load(idx, 2) = force; 
                end
            end
        end
    end

    loads = load;
    
end