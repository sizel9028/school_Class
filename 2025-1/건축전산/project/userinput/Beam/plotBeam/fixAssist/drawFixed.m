function drawFixed(pos)
    x = pos(1);
    y = pos(2) - 0.225;
    dx = 0.225; dy = 0.225;

    % 고정지점은 사다리꼴 또는 직사각형
    fill([x-dx, x+dx, x+dx, x-dx], [y, y, y+dy, y+dy], 'k');
end
