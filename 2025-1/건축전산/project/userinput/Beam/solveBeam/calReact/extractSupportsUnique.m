function [supportNodes, supportDOFs] = extractSupportsUnique(Beam)
    rawN = []; rawD = [];

    if isempty(Beam.lineBeam)
        return;
    end

    for i = 1:numel(Beam.lineBeam)
        b = Beam.lineBeam(i);
        for j = 1:size(b.supports,1)
            d = b.supports(j,1:2);
            if any(d)
                rawN = [rawN; b.nodes(j,:)];   
                rawD = [rawD; d];              
            end
        end
    end
    % 중복 행 제거, 첫 번째만 남김
    [supportNodes, ia] = unique(rawN, 'rows', 'stable');
    supportDOFs = rawD(ia,:);
end