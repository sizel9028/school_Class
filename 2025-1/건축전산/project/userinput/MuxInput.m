function [Truss, Beam, Stack] = MuxInput(cmd,Truss,Beam,Stack)
addpath('userinput\Truss\');
addpath('userinput\Beam\');

    global statusFlag
    
    switch statusFlag

        case "Beam"
            cmd = userinput_beam(cmd);
            Beam = processCMD_beam(cmd, Beam);
        case "Truss"
            cmd = userinput(cmd);
            [Truss, Stack] = processCMD(cmd,Truss,Stack);

    end

end