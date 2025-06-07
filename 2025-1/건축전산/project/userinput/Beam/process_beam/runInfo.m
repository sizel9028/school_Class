function runInfo(Beam, mode)

    if nargin < 2
        mode = "full";
    end

    switch mode
        case "full"
            disp("=== Beam Info: FULL ===");
            runInfo(Beam, "n");
            runInfo(Beam, "m");
            runInfo(Beam, "s");
            runInfo(Beam, "f");
            runInfo(Beam, "r");
            
        case "n"
            disp("=== Nodes (dummyNodes) ===");
            if isempty(Beam.dummyNodes)
                disp("No dummy nodes.");
            else
                disp(Beam.dummyNodes);
            end

        case "m"
            disp("=== Members (lineBeam) ===");
            if isempty(Beam.lineBeam)
                disp("No beam members.");
            else
                for i = 1:length(Beam.lineBeam)
                    beam = Beam.lineBeam(i);
                    fprintf("Beam %d: start (%.2f, %.2f) → end (%.2f, %.2f)\n", ...
                        i, beam.startNode(1), beam.startNode(2), beam.endNode(1), beam.endNode(2));
                    disp("  nodes:");
                    disp(beam.nodes);
                end
            end

        case "s"
            disp("=== Supports ===");
            if isempty(Beam.lineBeam)
                disp("No supports (no beams).");
            else
                for i = 1:length(Beam.lineBeam)
                    fprintf("Beam %d:\n", i);
                    disp(Beam.lineBeam(i).supports);
                end
            end

        case "f"
            disp("=== Forces ===");
            if isempty(Beam.lineBeam)
                disp("No force data.");
            else
                for i = 1:length(Beam.lineBeam)
                    force = Beam.lineBeam(i).Force;
                    fprintf("Beam %d:\n", i);
                    fprintf("  Types: "); disp(force.type);
                    fprintf("  Startpoints:\n"); disp(force.startpoint);
                    fprintf("  Endpoints:\n"); disp(force.endpoint);
                    fprintf("  Moments:\n"); disp(force.M);
                    fprintf("  Power:\n"); disp(force.power);
                end
            end

            case "r"
            disp("=== Reactions ===");
            if isempty(Beam.lineBeam)
                disp("No reaction data.");
            else
                for i = 1:length(Beam.lineBeam)
                    fprintf("Beam %d:\n", i);
                    disp(Beam.lineBeam(i).reactions);
                end
            end

        otherwise
            disp("Unknown info mode.");
    end

end
