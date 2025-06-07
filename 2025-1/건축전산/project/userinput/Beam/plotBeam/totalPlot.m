function totalPlot(Beam)
addpath('userinput\Beam\plotBeam\drawDiagram\');

    plotBeam(Beam);
    hold on;
    plotForce(Beam);
    hold on;
    fixPlot(Beam);

    xl = xlim;
    yl = ylim;
    
    padding = 1;
  
    xlim([xl(1) - padding, xl(2) + padding]);
    ylim([yl(1) - padding, yl(2) + padding]);

    VMDiagram(Beam);


end