function [forces, moments] = extractLoads(Beam)
    forces  = [];  % [Fx, Fy, x, y]
    moments = [];  % [M, x, y]

    for i = 1:length(Beam.lineBeam)
        b = Beam.lineBeam(i);
        f = b.Force;

        for j = 1:length(f.power)
            type = f.type{j};
            sp   = f.startpoint(j, :);
            ep   = f.endpoint(j, :);

            switch type
                case 'point_x'
                    Fx = f.power(j);
                    forces(end+1, :) = [Fx, 0, sp(1), sp(2)];

                case 'point_y'
                    Fy = f.power(j);
                    forces(end+1, :) = [0, Fy, sp(1), sp(2)];

                case 'unif_x'
                    w = f.power(j);           
                    L = norm(ep - sp);
                    P = w * L;
  
                    x_eq = (sp(1) + ep(1))/2;
                    y_eq = (sp(2) + ep(2))/2;
                    forces(end+1, :) = [P, 0, x_eq, y_eq];

                case 'unif_y'
                    w = f.power(j);
                    L = norm(ep - sp);
                    P = w * L;
    
                    x_eq = (sp(1) + ep(1))/2;
                    y_eq = (sp(2) + ep(2))/2;
                    forces(end+1, :) = [0, P, x_eq, y_eq];

                case 'dist_x'
                    w_max = f.power(j);
                    L     = norm(ep - sp);
                    P     = 0.5 * w_max * L;
   
                    if ep(1) > sp(1)
                        x_eq = sp(1) + 2/3*(ep(1)-sp(1));
                    else
                        x_eq = sp(1) + 1/3*(ep(1)-sp(1));
                        w_max = -w_max;  % 반대 방향이면 부호 반전
                    end
                    y_eq = (sp(2)+ep(2))/2;
                    forces(end+1, :) = [P, 0, x_eq, y_eq];

                case 'dist_y'
                    w_max = f.power(j);
                    L     = norm(ep - sp);
                    P     = 0.5 * w_max * L;
                    if ep(2) > sp(2)
                        y_eq = sp(2) + 2/3*(ep(2)-sp(2));
                    else
                        y_eq = sp(2) + 1/3*(ep(2)-sp(2));
                        w_max = -w_max;
                    end
                    x_eq = (sp(1)+ep(1))/2;
                    forces(end+1, :) = [0, P, x_eq, y_eq];

           
                case 'moment'
                    moments(end+1, :) = [f.M(j), sp(1), sp(2)];
            end
        end
    end
end
