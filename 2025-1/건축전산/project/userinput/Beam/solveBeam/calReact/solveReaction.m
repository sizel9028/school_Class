function Beam = solveReaction(Beam)

    [forces, moments] = extractLoads(Beam);
    % forces: [Fx, Fy, x, y]
    % moments: [M, x, y]

    supportNodes = zeros(0,2);
    supportDOFs  = zeros(0,3);
    for i = 1:numel(Beam.lineBeam)
        b = Beam.lineBeam(i);
        for k = 1:size(b.nodes,1)
            dof = b.supports(k,:);  % [ux uy rz]
            if any(dof)
                pt = b.nodes(k,:);
    
                idx = find( all(supportNodes==pt,2), 1 );
                if isempty(idx)
                    supportNodes(end+1,:) = pt;      
                    supportDOFs(end+1,:)  = dof;     
                end
            end
        end
    end

    nReac = sum(supportDOFs(:));
    if nReac ~= 3
        error('정정 보가 아닙니다! 반력 미지수 개수 = %d (필요 3)', nReac);
    end


    syms R [1 nReac] real
    eqs = sym.zeros(3,1);


    eqs(1) = sum(forces(:,1));
    idxR = 1;
    for i = 1:size(supportDOFs,1)
        if supportDOFs(i,1)
            eqs(1) = eqs(1) + R(idxR);
            idxR = idxR + 1;
        end
    end


    eqs(2) = sum(forces(:,2));

    idxR = sum(supportDOFs(:,1));
    for i = 1:size(supportDOFs,1)
        if supportDOFs(i,2)
            idxR = idxR + 1;
            eqs(2) = eqs(2) + R(idxR);
        end
    end


    cx = supportNodes(1,1);
    cy = supportNodes(1,2);
    eqs(3) = sym(0);

    for k = 1:size(forces,1)
        Fx = forces(k,1); Fy = forces(k,2);
        x0 = forces(k,3); y0 = forces(k,4);
        eqs(3) = eqs(3) + (x0-cx)*Fy - (y0-cy)*Fx;
    end

    for k = 1:size(moments,1)
        eqs(3) = eqs(3) + moments(k,1);
    end

    idxR = 1;
    for i = 1:size(supportDOFs,1)
        xi = supportNodes(i,1);
        yi = supportNodes(i,2);
        % Rx
        if supportDOFs(i,1)
            eqs(3) = eqs(3) - R(idxR)*(yi-cy);
            idxR = idxR + 1;
        end
        % Ry
        if supportDOFs(i,2)
            eqs(3) = eqs(3) + R(idxR)*(xi-cx);
            idxR = idxR + 1;
        end
        % Mz
        if supportDOFs(i,3)
            eqs(3) = eqs(3) + R(idxR);
            idxR = idxR + 1;
        end
    end


    sol   = solve(eqs, R);
   valsC = struct2cell(sol);           
   Rvals = cellfun(@double, valsC).';

    idxR = 1;
    for i = 1:size(supportDOFs,1)
        node = supportNodes(i,:);
        for dir = 1:3     % 1=Rx,2=Ry,3=Mz
            if supportDOFs(i,dir)
                for j = 1:numel(Beam.lineBeam)
                    b = Beam.lineBeam(j);
                    loc = find( ismember(b.nodes, node,'rows'), 1 );
                    if ~isempty(loc)
                        if ~isfield(b,'reactions') || isempty(b.reactions)
                            b.reactions = zeros(size(b.nodes,1),3);
                        end
                        b.reactions(loc,dir) = Rvals(idxR);
                        Beam.lineBeam(j)    = b;
                    end
                end
                idxR = idxR + 1;
            end
        end
    end

    %fprintf('Computed reactions [Rx, Ry, Mz]: %s\n', mat2str(Rvals,6));
end
