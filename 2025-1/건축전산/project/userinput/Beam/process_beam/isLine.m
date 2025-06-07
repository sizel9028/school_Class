function bool = isLine(x,y,p1,p2)
    dx = p2(1) - p1(1);
    dy = p2(2) - p1(2);
    dx0 = x - p1(1);
    dy0 = y - p1(2);

    cross = dx * dy0 - dy * dx0;

    withinX = x >= min(p1(1), p2(1)) - 1e-6 && x <= max(p1(1), p2(1)) + 1e-6;
    withinY = y >= min(p1(2), p2(2)) - 1e-6 && y <= max(p1(2), p2(2)) + 1e-6;

    bool = abs(cross) < 1e-6 && withinX && withinY;
end
