function bool = isLine(p1, p2, p)

    %p가 p1,p2사이 직선에 있으면 참을 반환

    area = (p2(1)-p1(1))*(p(2)-p1(2)) - (p(1)-p1(1))*(p2(2)-p1(2));

    if abs(area) > 1e-6
        bool = false;
        return;
    end

    bool = all(min(p1,p2) <= p) && all(p <= max(p1,p2));

end