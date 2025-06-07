function drawPinned(pos)

    x = pos(1);
    y = pos(2)-0.225;
    dx = 0.225; dy = 0.225;
    fill([x-dx, x+dx, x], [y, y, y+dy], 'k');

end