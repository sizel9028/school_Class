function drawPinned(pos)

    x = pos(1);
    y = pos(2)-0.15;
    dx = 0.15; dy = 0.15;
    fill([x-dx, x+dx, x], [y, y, y+dy], 'k');

end