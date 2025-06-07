function plotForce(Beam)
    hold on;
    axis equal;
    grid on;
    xlabel("X");
    ylabel("Y");

    Force_scale = 1;

    % 색상 설정
    pointColor = 'r';
    uniformColor = 'g';
    triangleColor = [1 0.5 0];
    momentColor = 'm';

    for i = 1:length(Beam.lineBeam)
        beam = Beam.lineBeam(i);
        f = beam.Force;

        for j = 1:length(f.type)
            t = f.type{j};
            sp = f.startpoint(j,:);
            ep = f.endpoint(j,:);  % 일부 항목에만 쓰임
            mag = f.power(j);

            switch t
                case "point_x"
                    quiver(sp(1), sp(2), Force_scale*sign(mag), 0, 2, ...
                        'Color', pointColor, 'LineWidth', 2, 'MaxHeadSize', 1);

                    txt = sprintf('%.1f', mag);
                    text(ep(1)+sign(mag), ep(2), txt, ...
                         'FontSize', 9, 'FontWeight', 'bold', ...
                         'Color', [0 0 0], ...
                         'HorizontalAlignment', 'left', ...
                         'VerticalAlignment', 'middle');


                case "point_y"
                    quiver(sp(1), sp(2), 0, Force_scale*sign(mag), 2, ...
                        'Color', pointColor, 'LineWidth', 2, 'MaxHeadSize', 1);

                    txt = sprintf('%.1f', mag);
                    text(ep(1), ep(2)+sign(mag), txt, ...
                         'FontSize', 9, 'FontWeight', 'bold', ...
                         'Color', [0 0 0], ...
                         'HorizontalAlignment', 'left', ...
                         'VerticalAlignment', 'middle');


                case "unif_x"
                len = norm(ep - sp);
                n_arrows = max(floor(len / 0.5), 2);
            
                arrowVec = [Force_scale * sign(mag), 0];   % → 오른쪽 (또는 ← 왼쪽)
                offset = -arrowVec;                        % ← 왼쪽(또는 → 오른쪽)으로 평행이동
            
                % 보조선: beam에서 떨어진 위치
                plot([sp(1), ep(1)] + offset(1), [sp(2), ep(2)] + offset(2), ...
                     '--', 'Color', uniformColor, 'LineWidth', 1, 'DisplayName', '');
            
                % 화살표들: offset 위치에서 beam을 향해
                for k = 0:n_arrows
                    targetPos = sp + k/n_arrows * (ep - sp);     % beam 위
                    startPos  = targetPos + offset;              % offset된 시작점
                    quiver(startPos(1), startPos(2), arrowVec(1), arrowVec(2), 0, ...
                        'Color', uniformColor, 'LineWidth', 1.5, 'DisplayName', '');
                end

                txt = sprintf('%.1f', mag);
                    text(ep(1) + offset(1)*0.8, ep(2), txt, ...
                         'FontSize', 9, 'FontWeight', 'bold', ...
                         'Color', [0 0 0], ...
                         'HorizontalAlignment', 'left', ...
                         'VerticalAlignment', 'middle');

                case "unif_y"
  
                len = norm(ep - sp);
                n_arrows = max(floor(len / 0.5), 2);
            
                arrowVec = [0, Force_scale * sign(mag)];
                offset = -arrowVec;  % ← 보조선 이동 방향
            
                % 보조선도 평행 이동된 위치에 그림
                plot([sp(1), ep(1)] + offset(1), [sp(2), ep(2)] + offset(2), ...
                     '--', 'Color', uniformColor, 'LineWidth', 1, 'DisplayName', '');
            
                % 각 화살표는 보조선에서 beam을 향해
                for k = 0:n_arrows
                    targetPos = sp + k/n_arrows * (ep - sp);       % beam 위 점
                    startPos  = targetPos + offset;                % offset만큼 평행이동된 시작점
                    quiver(startPos(1), startPos(2), arrowVec(1), arrowVec(2), 0, ...
                        'Color', uniformColor, 'LineWidth', 1.5, 'DisplayName', '');
                end

                txt = sprintf('%.1f', mag);
                    text(ep(1), ep(2) + offset(2)*0.8, txt, ...
                         'FontSize', 9, 'FontWeight', 'bold', ...
                         'Color', [0 0 0], ...
                         'HorizontalAlignment', 'left', ...
                         'VerticalAlignment', 'middle');

                case "dist_x"
           
                beamVec       = ep - sp;
                len           = norm(beamVec);
            
                % 원하는 간격 (m)으로 분할
                arrow_spacing = 0.5;
                n_intervals   = max(floor(len / arrow_spacing), 1);
                n_arrows      = n_intervals + 1;
            
                % 화살표 방향 (x축)
                signDir = sign(mag);
                dirUnit = [1, 0] * signDir;
            
                % beam에 수직인 단위벡터로 offset 계산
                normalDir = [ beamVec(2); -beamVec(1) ] / len;
                offset    = 0;  % 0.2m 만큼 떨어뜨림
            
                % 팁 좌표 저장용
                tipPosAll = zeros(n_arrows, 2);
            
                % 1) 화살표 그리기
                for idx = 1:n_arrows
                    t_rel    = (idx-1) / n_intervals;      % 0 → 1
                    pos      = sp + t_rel * beamVec;       % beam 위 점
                    startPos = pos + offset';              % offset 위치
            
                    % Force_scale에 맞춘 길이 (0 → Force_scale)
                    arrowLen = Force_scale * t_rel;
                    tipPos   = startPos + dirUnit * arrowLen;
                    tipPosAll(idx, :) = tipPos;
            
                    if arrowLen > 0
                        quiver( startPos(1), startPos(2), ...
                                dirUnit(1)*arrowLen, dirUnit(2)*arrowLen, ...
                                0, 'Color', triangleColor, ...
                                   'LineWidth', 1.5, ...
                                   'MaxHeadSize', 0.5 );
                    end
                end
            
                % 2) 보조선: 첫 번째 팁 → 마지막 팁
                firstTip = tipPosAll(1, :);
                lastTip  = tipPosAll(end, :);
                plot( [firstTip(1), lastTip(1)], ...
                      [firstTip(2), lastTip(2)], ...
                      '--', 'Color', triangleColor, 'LineWidth', 1 );

                txt = sprintf('%.1f', mag);
                    text((ep(1)+lastTip(1))/2, ep(2), txt, ...
                         'FontSize', 9, 'FontWeight', 'bold', ...
                         'Color', [0 0 0], ...
                         'HorizontalAlignment', 'left', ...
                         'VerticalAlignment', 'middle');


                case "dist_y"
                    beamVec = ep - sp;
                    len = norm(beamVec);
                
                    % 원하는 간격 (m)으로 분할
                    arrow_spacing = 0.5;
                    n_intervals   = max(floor(len / arrow_spacing), 1);
                    n_arrows      = n_intervals + 1;
                
                    % 화살표 방향 (y축)
                    signDir = sign(mag);
                    dirUnit = [0, 1] * signDir;  % y축 방향 (아래로 작용 시 -1)
                
                    % beam에 수직인 단위벡터로 offset 계산
                    normalDir = [ beamVec(2); -beamVec(1) ] / len;
                    offset    = 0;  % 0.2m 만큼 떨어뜨림 → 현재 0으로 설정됨
                
                    % 팁 좌표 저장용
                    tipPosAll = zeros(n_arrows, 2);
                
                    % 1) 화살표 그리기
                    for idx = 1:n_arrows
                        t_rel    = (idx-1) / n_intervals;       % 0 → 1
                        pos      = sp + t_rel * beamVec;        % beam 위 점
                        startPos = pos + offset';               % offset 위치
                
                        % Force_scale에 맞춘 길이 (0 → Force_scale)
                        arrowLen = Force_scale * t_rel;
                        tipPos   = startPos + dirUnit * arrowLen;
                        tipPosAll(idx, :) = tipPos;
                
                        if arrowLen > 0
                            quiver( startPos(1), startPos(2), ...
                                    dirUnit(1)*arrowLen, dirUnit(2)*arrowLen, ...
                                    0, 'Color', triangleColor, ...
                                       'LineWidth', 1.5, ...
                                       'MaxHeadSize', 0.5 );
                        end
                    end
                
                    % 2) 보조선: 첫 번째 팁 → 마지막 팁
                    firstTip = tipPosAll(1, :);
                    lastTip  = tipPosAll(end, :);
                    plot( [firstTip(1), lastTip(1)], ...
                          [firstTip(2), lastTip(2)], ...
                          '--', 'Color', triangleColor, 'LineWidth', 1 );


                    txt = sprintf('%.1f', mag);
                    text(ep(1), (ep(2)+lastTip(2))/2, txt, ...
                         'FontSize', 9, 'FontWeight', 'bold', ...
                         'Color', [0 0 0], ...
                         'HorizontalAlignment', 'left', ...
                         'VerticalAlignment', 'middle');

                case "moment"

                Mval = f.M(j);
                if Mval ~= 0
                    % 1) 모멘트 커브(arc) 그리기
                    cp     = sp;            % 모멘트 중심
                    radius = 0.5;           % 반지름
                    angle = linspace(0, 2*pi*0.75, 100);
                    if Mval > 0
                        x = cp(1) + radius * cos(angle);
                        y = cp(2) + radius * sin(angle);
                    else
                        x = cp(1) + radius * cos(-angle);
                        y = cp(2) + radius * sin(-angle);
                    end
                    plot(x, y, 'Color', momentColor, 'LineWidth', 1.5);
            
                    % 2) 화살표(arrow head) 그리기
                    quiver(x(end-1), y(end-1), x(end)-x(end-1), y(end)-y(end-1), ...
                           0, 'Color', momentColor, 'MaxHeadSize', 2);
            
                    % 3) 텍스트 라벨 추가
                    txt = sprintf('M : %.1f', Mval);
                    text(cp(1), cp(2) + radius + 0.1, txt, ...
                         'HorizontalAlignment', 'center', ...
                         'VerticalAlignment', 'bottom', ...
                         'FontSize', 9, 'FontWeight', 'bold', ...
                         'Color', momentColor);
                end


            end
        end
    end

end
