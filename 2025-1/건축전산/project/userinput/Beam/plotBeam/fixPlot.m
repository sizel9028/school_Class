function fixPlot(Beam)
addpath('userinput\Beam\plotBeam\fixAssist');

    hold on;

    if isempty(Beam.lineBeam)
        return;
    end

    for i = 1:length(Beam.lineBeam)
        beam = Beam.lineBeam(i);
        nodes = beam.nodes;
        supports = beam.supports;

        if isempty(supports)
            continue;
        end

        for j = 1:size(supports,1)
            pos = nodes(j,:);
            s = supports(j,:);

            if isequal(s, [1 1 1])
                drawFixed(pos);  
            elseif isequal(s, [1 1 0])
                drawPinned(pos);
            elseif isequal(s, [0 1 0])
                drawRoller(pos);
            elseif isequal(s, [1 0 0])
                drawRoller(pos);
            end
        end
    end
end