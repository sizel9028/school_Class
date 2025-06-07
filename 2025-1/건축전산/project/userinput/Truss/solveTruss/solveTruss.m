function Truss = solveTruss(Truss)
addpath('userinput\Truss\solveTruss\Force\');
   

    bool = isDeterminate(Truss);

    switch bool

        case "unstable"
            disp('불안정 구조입니다');
            return;
            
        case "indeterminate"
            if Truss.status ~= "indeterminate"
                disp('부정정 구조입니다... (chmod)로 변경');
                return;
            end
    end

    switch Truss.status
        
        case "determinate"
            force = determinate(Truss);
            Truss.memForces = force;
        case "indeterminate"
            force = indeterminate(Truss);
            Truss.memForces = force;

    end
    
        
end