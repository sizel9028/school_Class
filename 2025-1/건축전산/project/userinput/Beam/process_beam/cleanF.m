function Beam = cleanF(Beam)

    if isempty(Beam.lineBeam)
        return;
    end

    for i = 1:numel(Beam.lineBeam)
        Beam.lineBeam(i).Force.startpoint = [];
        Beam.lineBeam(i).Force.endpoint   = [];
        Beam.lineBeam(i).Force.type       = {};
        Beam.lineBeam(i).Force.power      = [];
        Beam.lineBeam(i).Force.M          = [];
        Beam.lineBeam(i).Force.eqn        = {};
    end
end
