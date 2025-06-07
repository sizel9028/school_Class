function [nodes, members, supports, loads,err] = assistText(nodes,members,supports,loads)

    err = false;

    if ~isnumeric(nodes) || size(nodes,2) ~= 2
        disp('노드에서 오류가 발생했습니다. 분석 결과를 모두 지웁니다');
        nodes = [];
        members = [];
        supports = [];
        loads = [];
        return;
    end

    if ~isnumeric(members) || size(members,2) ~= 2
        disp('부재에서 오류가 발생했습니다. 부재 배열을 초기화합니다')
        members = [];
    end

    if any(members(:) < 1) || any(members(:) > size(nodes,1))
        disp('부재에서 오류가 발생했습니다');
        err = true;
    end

    if ~isnumeric(supports) || size(supports, 2) ~= 3
        disp('고정점에서 오류가 발생했습니다. 고정점 배열을 초기화합니다');
        supports = [];
    end

    if ~isnumeric(loads) || size(loads,2) ~= 4
        disp('하중에서 오류가 발생했습니다. 하중 배열을 초기화합니다');
        loads = [];
    end
        
end