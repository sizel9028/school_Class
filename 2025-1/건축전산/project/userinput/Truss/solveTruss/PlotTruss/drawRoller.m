function drawRoller(pos)
    
    r = 0.075;  % 원하는 좌표 단위 반지름
    theta = linspace(0, 2*pi, 100);
    x_circ = r * cos(theta);
    y_circ = r * sin(theta);

    %if type == "x"
        center = [pos(1), pos(2) - r];
    %else   type == "y"
        %center = [pos(1) - r, pos(2)];
    %end

    fill(center(1) + x_circ, center(2) + y_circ, 'k');
end