function key = nodeKey(pt)
% 노드를 문자열 키로 변환
    key = sprintf('%.12f_%.12f', pt(1), pt(2));
end