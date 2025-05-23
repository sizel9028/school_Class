function force = indeterminate(Truss)
addpath('userinput\solveTruss\Force\mkIndeterminate');

    K = mkglobalMatrix(Truss);
    f = reshape(Truss.loads.',[],1);
    DOF = length(f);

    fixedDOF = find(reshape(Truss.supports.', [], 1) == 1);
    freeDOF = setdiff(1:DOF, fixedDOF);

    u = zeros(DOF,1);
    u(freeDOF) = K(freeDOF, freeDOF) \ f(freeDOF);

    force = calForce(u,Truss);

    reactions = K * u - f;
    isSupport = reshape(Truss.supports.',[],1);
    force = [force;reactions(isSupport==1)];

end