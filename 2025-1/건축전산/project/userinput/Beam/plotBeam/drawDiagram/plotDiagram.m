function plotDiagram(CritLoc, Force, Reaction,beam)

    
    syms x C1 C2
    
    V0 = [0 0];
    M0 = [0 0];
    V_temp = 0;

    fig = figure( ...
        'NumberTitle','off', ...
        'Name',sprintf('Beam [%.2f, %.2f] → [%.2f, %.2f]', ...
            beam.startNode(1), beam.startNode(2), ...
            beam.endNode(1),   beam.endNode(2)) ...
    );

    subplot(2,1,1);
    hold on; grid on;
    subplot(2,1,2);
    hold on; grid on;
        
    for jj = 1:length(CritLoc)-1
        Type = Force.type{jj};
        switch Type
            case {'unif', 'dist'}
                Loc1 = CritLoc(jj); 
                Loc2 = CritLoc(jj+1); 
                xtemp = linspace(Loc1, Loc2, 100);
                
                if ~isempty(Reaction.Fy)              
                    idx = find(Reaction.Fy(:,1) == Loc1, 1);
                    if ~isempty(idx)
                        V0 = vertcat(V0, [Loc1, V_temp(end) + Reaction.Fy(find(Reaction.Fy(:,1)' == Loc1), 2)]);
                    end
                end
                
                w_temp = Force.eqn{jj};
                V_temp = int(w_temp, x) + C1;
                M_temp = int(V_temp, x) + C2;
                
                c1 = vpasolve(subs(V_temp, x, V0(end,1)) == V0(end,2), C1);
                    
                if ~isempty(Force.M)
                    if (Force.M(:,1) == Loc1 || Force.M(:,1) == Loc2) 
                        c2 = vpasolve(subs(M_temp, x, Force.M(1,1)) == Force.M(1,2), C2);
                    else
                        M_temp = subs(M_temp, C1, c1);
                        c2 = vpasolve(subs(M_temp, x, M0(end,1)) == M0(end,2), C2);
                    end
                else
                    M_temp = subs(M_temp, C1, c1);
                    c2 = vpasolve(subs(M_temp, x, M0(end,1)) == M0(end,2), C2);
                end
                
                V_temp = subs(subs(V_temp, C1, c1), x, xtemp);
                M_temp = subs(subs(subs(M_temp, C1, c1), C2, c2), x, xtemp);
                
                
                subplot(211); plot(xtemp, V_temp); hold on; grid on
                subplot(212); plot(xtemp, M_temp); hold on; grid on

                if ~isempty(Force.M)
                    % 현재 Loc1에서 외부 모멘트가 있는 경우
                    idxM = (Force.M(:,1) == Loc1);
                    if any(idxM)
                        for k = find(idxM)'
                            M_add = Force.M(k, 2); % 추가할 외부 모멘트
                            M0 = vertcat(M0, [Force.M(k,1), M0(end,2) + M_add]); % 기존 M 에 누적 추가
                        end
                    end
                end
                            
                V0 = vertcat(V0, [Loc2, V_temp(end)]);
                M0 = vertcat(M0, [Loc2, M_temp(end)]);
                
            case {'point'}
                Loc1 = CritLoc(jj); 
                Loc2 = CritLoc(jj+1); 
                xtemp = linspace(Loc1, Loc2, 100);
                PLoc = Force.loc{jj}; 

                idxM1 = (Force.M(:,1) == Loc1);
                if any(idxM1)
                    M_add = Force.M(idxM1, 2); % 추가할 모멘트
                    M0 = vertcat(M0, [Force.M(idxM1,1), M0(end,2) + M_add]);
                end
                        
                if ~isempty(Reaction.Fy)              
                    idx = find(Reaction.Fy(:,1) == Loc1, 1);
                    if ~isempty(idx)
                        V0 = vertcat(V0, [Loc1, V_temp(end) + Reaction.Fy(find(Reaction.Fy(:,1)' == Loc1), 2)]);
                    end
                end
                V_temp = zeros(1, length(xtemp));
                w_temp = Force.eqn{jj};
                
                V_temp(xtemp < PLoc) = V0(end, 2); 
                V_temp(xtemp >= PLoc) = V0(end, 2) + w_temp; 
                
                M_temp = cumtrapz(xtemp, V_temp) + M0(end, 2);
                
                 hold on
                subplot(211); plot(xtemp, V_temp); grid on
                subplot(212); plot(xtemp, M_temp); grid on
                
                V0 = vertcat(V0, [Loc2, V_temp(end)]);
                M0 = vertcat(M0, [Loc2, M_temp(end)]);
                
                locs = cell2mat(Force.loc);

    
                idxF = find(locs == Loc2, 1);
                if ~isempty(idxF)
                    if ~isempty(Reaction.Fy)
                        idxR = find(Reaction.Fy(:,1) == Loc2, 1);
                        if ~isempty(idxR)
                            V0(end+1, :) = [Loc2, V_temp(end) + Reaction.Fy(idxR, 2);];
                        end
                    end
                end
                
            case {'non'} 
                Loc1 = CritLoc(jj); 
                Loc2 = CritLoc(jj+1); 
                if ~isempty(Reaction.Fy)              
                    idx = find(Reaction.Fy(:,1) == Loc1, 1);
                    if ~isempty(idx)
                        V0 = vertcat(V0, [Loc1, V_temp(end) + Reaction.Fy(find(Reaction.Fy(:,1)' == Loc1), 2)]);
                    end
                end
                
                if ~isempty(Force.M)
                    idxM = (Force.M(:,1) == Loc1);
                    if any(idxM)
                        for k = find(idxM)' % 여러 개 있을 경우 for loop로 처리
                            M_add = Force.M(k, 2);
                            M0 = vertcat(M0, [Force.M(k,1), M0(end,2) + M_add]); % 기존 M에 추가
                        end
                    end 
                end
                
                xtemp = linspace(Loc1, Loc2, 100);
                V_temp = ones(1, length(xtemp)) * V0(end, 2);
                M_temp = cumtrapz(xtemp, V_temp) + M0(end, 2);
                
                subplot(211); plot(xtemp, V_temp); hold on; grid on
                subplot(212); plot(xtemp, M_temp); hold on; grid on
                
                V0 = vertcat(V0, [Loc2, V_temp(end)]);
                M0 = vertcat(M0, [Loc2, M_temp(end)]);
        end
    end

    sgtitle(fig, fig.Name);

end