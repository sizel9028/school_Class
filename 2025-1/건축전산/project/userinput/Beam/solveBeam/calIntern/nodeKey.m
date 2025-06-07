function key = nodeKey(pt, tol)
    % 숫자 오차 무시하고 키 만들기
    key = sprintf('%.6f_%.6f', pt(1), pt(2));
end