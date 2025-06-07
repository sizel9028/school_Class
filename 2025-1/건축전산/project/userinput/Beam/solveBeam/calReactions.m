function Beam = calReactions(Beam)
addpath('userinput\Beam\solveBeam\calReact\');
    
    bool = isDeterminate(Beam);

    if bool
        Beam = solveReaction(Beam);
        Beam = mkjointForce(Beam);
        Beam = mkInternM(Beam);

    end

end