function plotBeam(Beam)

    figure;
    hold on;
    axis equal;
    grid on;
    title("Beam 구조 시각화");
    xlabel("X");
    ylabel("Y");

    nodeColor = 'bo';    
    beamColor = 'k-';    


    if isempty(Beam.lineBeam)
        disp("Beam 구조에 부재(lineBeam)가 없습니다.");
    else
        for i = 1:length(Beam.lineBeam)
            beam = Beam.lineBeam(i);
            if isempty(beam.nodes)
                continue;
            end

            nodes = beam.nodes;


            plot(nodes(:,1), nodes(:,2), beamColor, 'LineWidth', 2);


            plot(nodes(:,1), nodes(:,2), nodeColor, ...
                 'MarkerSize', 6, 'MarkerFaceColor', 'b');

            for j = 1:size(nodes,1)
                txt = sprintf('(%g, %g)', nodes(j,1), nodes(j,2));
                text(nodes(j,1)+0.1, nodes(j,2)+0.1, txt, ...
                     'FontSize', 8, 'Color', 'blue');
            end
        end
    end

    % Dummy 노드
    if ~isempty(Beam.dummyNodes)
        plot(Beam.dummyNodes(:,1), Beam.dummyNodes(:,2), 'ro', ...
             'MarkerSize', 6, 'MarkerFaceColor', 'r');

        for i = 1:size(Beam.dummyNodes,1)
            txt = sprintf('dummy (%g, %g)', Beam.dummyNodes(i,1), Beam.dummyNodes(i,2));
            text(Beam.dummyNodes(i,1)+0.1, Beam.dummyNodes(i,2)+0.1, txt, ...
                 'FontSize', 8, 'Color', 'red');
        end
    end

    hold off;

end
