function plotTruss(Truss)
    figure;
    hold on;
    axis equal;
    grid off;
    box on;
    title('Truss Structure');
    xlabel('X');
    ylabel('Y');
    text_offset = 0.1;

    if isempty(Truss.nodes)
        disp('출력할 노드가 없습니다');
        return;
    end

    x_min = min(Truss.nodes(:,1)) - 1;
    x_max = max(Truss.nodes(:,1)) + 1;
    y_min = min(Truss.nodes(:,2)) - 1;
    y_max = max(Truss.nodes(:,2)) + 1;

    xlim([x_min, x_max]);
    ylim([y_min, y_max]);


    if ~isempty(Truss.members) && isempty(Truss.memForces)

        for i = 1:size(Truss.members, 1)
            n1 = Truss.members(i, 1);
            n2 = Truss.members(i, 2);
            x = [Truss.nodes(n1, 1), Truss.nodes(n2, 1)];
            y = [Truss.nodes(n1, 2), Truss.nodes(n2, 2)];
            plot(x, y, 'k-', 'LineWidth', 2);
        end

    elseif ~isempty(Truss.members) && ~isempty(Truss.memForces)

        for i = 1:size(Truss.members, 1)

            n1 = Truss.members(i, 1);
            n2 = Truss.members(i, 2);
            x = [Truss.nodes(n1, 1), Truss.nodes(n2, 1)];
            y = [Truss.nodes(n1, 2), Truss.nodes(n2, 2)];
    
            force = Truss.memForces(i);
            abs_force = abs(force);

            if abs_force < 1e-4
                color = 'k';
            elseif force > 0
                color = 'b';  
            else
                color = 'r';  
            end
    
            plot(x, y, '-', 'Color', color, 'LineWidth', 2);
        end
    end
  
    if ~isempty(Truss.nodes)
        scatter(Truss.nodes(:,1), Truss.nodes(:,2), 60, 'ro', 'filled');
    end

    if ~isempty(Truss.supports)
        for i = 1:size(Truss.supports, 1)
            pos = Truss.nodes(i, :);
            sx = Truss.supports(i, 1);
            sy = Truss.supports(i, 2);
    
            if sx == 1 && sy == 1
                drawPinned(pos);
            elseif sx == 1 && sy == 0
                drawRoller(pos);
            elseif sx == 0 && sy == 1
                drawRoller(pos);
            end
        end
    end

    if ~isempty(Truss.memForces)
        memberNum = size(Truss.members,1);
    
        for i = 1:memberNum
            n1 = Truss.members(i,1);
            n2 = Truss.members(i,2);

            x_mid = (Truss.nodes(n1, 1)*2 + Truss.nodes(n2, 1)) / 3;
            y_mid = (Truss.nodes(n1, 2)*2 + Truss.nodes(n2, 2)) / 3;

            str = sprintf('%.2f', Truss.memForces(i));

            text(x_mid-text_offset, y_mid+text_offset, str, ...
                'FontSize', 10, 'Color', 'k', ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle');
        end

        reactionidx = memberNum;
        fixed_length = 0.5;

        for i = 1:size(Truss.supports, 1)
            pos = Truss.nodes(i, :);
            x = pos(1);
            y = pos(2);

            if Truss.supports(i,1) == 1
                reactionidx = reactionidx + 1;
                force = Truss.memForces(reactionidx);
                dir = sign(force);

                text(pos(1) + 0.3*dir-text_offset, pos(2)+text_offset, sprintf('%.2f', force), ...
                'FontSize', 10, 'Color', 'k', ...
                'HorizontalAlignment', 'right');
                
                quiver(x, y, fixed_length * dir, 0, 0, ...
                   'Color', 'm', 'LineWidth', 2, 'MaxHeadSize', 2);
                
            end

            if Truss.supports(i,2) == 1
                reactionidx = reactionidx + 1;
                force = Truss.memForces(reactionidx);
                dir = sign(force);

                text(pos(1)-text_offset, pos(2) + 0.3*dir+text_offset, sprintf('%.2f', force), ...
                'FontSize', 10, 'Color', 'k', ...
                'HorizontalAlignment', 'center');
 
                quiver(x, y, 0, fixed_length * dir, 0, ...
                   'Color', 'm', 'LineWidth', 2, 'MaxHeadSize', 2);
            end
        end
    end

        
    if ~isempty(Truss.loads)
        fixed_length = 0.5;

        for i = 1:size(Truss.loads, 1)
            Fx = Truss.loads(i, 1);
            Fy = Truss.loads(i, 2);

            if Fx ~= 0
                pos = Truss.nodes(i, :);
                dir_x = sign(Fx);
                text(pos(1)+dir_x*0.3-text_offset, pos(2)+text_offset, sprintf('%.2f', Fx), ...
                'FontSize', 10, 'Color', 'k', ...
                'HorizontalAlignment', 'center');
                
                quiver(pos(1), pos(2), fixed_length * dir_x, 0, 0, ...
                   'Color', 'm', 'LineWidth', 2, 'MaxHeadSize', 2);
            end

            if Fy ~= 0
                pos = Truss.nodes(i, :);
                dir_y = sign(Fy);
                text(pos(1)-text_offset, pos(2) + 0.3*dir_y+text_offset, sprintf('%.2f', Fy), ...
                'FontSize', 10, 'Color', 'k', ...
                'HorizontalAlignment', 'center');
                
                quiver(pos(1), pos(2), 0, fixed_length * dir_y, 0, ...
                   'Color', 'm', 'LineWidth', 2, 'MaxHeadSize', 2);
            end
               
        end
    end


end
