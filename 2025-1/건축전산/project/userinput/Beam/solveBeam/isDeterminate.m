function bool = isDeterminate(Beam)
addpath('userinput\Beam\solveBeam\assistDeterminate\');

    r = calR(Beam);
    m = calM(Beam);
    k = calK(Beam);
    j = calJ(Beam);

    D = r + m + k - 2*j;

    if D == 0
        disp('정정구조 입니다...');
        bool = true;
    elseif D > 0
        disp('부정정구조 입니다. 해석이 불가능합니다');
        bool = false;
    else
        disp('불안정구조 입니다. 해석이 불가능합니다');
        bool = false;
    end

end