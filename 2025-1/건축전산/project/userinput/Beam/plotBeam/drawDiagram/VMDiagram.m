function VMDiagram(Beam)

    if isempty(Beam.lineBeam)
        disp('VM 다이어그램을 그릴 인자가 부족합니다');
        return;
    end


    for k = 1:length(Beam.lineBeam)
        lb = Beam.lineBeam(k);

        % 임계위치, 하중, 반력 계산
        CritLoc  = mkCritLoc(lb);
        Force    = mkForce(lb, CritLoc);
        Reaction = mkReaction(lb);


        %disp(Force);
        %disp(CritLoc);
        %disp(Reaction.Fy);


        % 각 빔마다 별도의 figure 창으로 다이어그램 그리기
        plotDiagram(CritLoc, Force, Reaction, lb);
    end

end