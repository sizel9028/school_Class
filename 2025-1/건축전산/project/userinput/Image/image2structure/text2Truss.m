function Truss = text2Truss(text)
    addpath('userinput\Image\image2structure\assistText');
    %addpath('image2structure\assistText');

    [bool, text] = isvalidText(text);

    if bool
        disp('추출에 실패하였습니다... 트러스 사진이 아닐 가능성이 높습니다');
        Truss = struct();
        return;
    end

    try
        eval(text);
    catch e
        disp('유효하지 않는 분석입니다...');
        disp(e.message);
        Truss = struct();
        return;
    end

    if ~exist('nodes', 'var')
        nodes = [];
    end

    if ~exist('members', 'var')
        members = [];
    end

    if ~exist('supports', 'var')
        supports = [];
    end

    if ~exist('loads', 'var')
        loads = [];
    end

    disp('유효한 트러스인지 분석합니다...');

    nodes = unique(nodes, 'rows', 'stable');

    [nodes,members,supports,loads,err ] = assistText(nodes,members,supports,loads);

    if err
        disp('오류가 생긴 부분을 제거합니다...');
    end

    [nodes,members,supports,loads] = deleteError(nodes,members,supports,loads);

    [nodes,members,supports,loads] = fixArray(nodes,members,supports,loads);

    members = delMember(nodes,members);

    Truss.nodes = nodes;
    Truss.members = members;
    Truss.loads = loads;
    Truss.A = 1;
    Truss.E = 1e9;
    Truss.status = "determinate";
    Truss.supports = supports;
    Truss.memForces = [];

end