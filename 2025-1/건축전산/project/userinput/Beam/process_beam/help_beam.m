function help_beam()

    disp("사용 가능한 Beam 명령어:");
    disp("  mknod (x,y)                     - 좌표에 노드 생성 (더미 노드)");
    disp("  delnod (x,y)                   - 해당 노드 삭제 (포함된 부재도 삭제)");
    disp("  mkmem (x1,y1),(x2,y2)          - 두 노드를 연결하여 Beam 부재 생성");
    disp("  delmem (x1,y1),(x2,y2)         - 두 노드 사이의 Beam 부재 삭제");
    disp("  fix (x,y) fixed|pinned|roller|yroller");
    disp("                                   - 해당 노드에 지점 조건 설정");
    disp("  load X|Y (x,y) f               - (x,y) 위치에 집중하중 fx 또는 fy");
    disp("  ldist x|y (x1,y1),(x2,y2) f    - 등분포하중 fx 또는 fy");
    disp("  ltria x|y (x1,y1),(x2,y2) f    - 삼각형 분포하중 최대값 f");
    disp("  moment (x,y) M                 - 위치 (x,y)에 반시계방향 모멘트 M 작용");
    disp(" ");
    disp("  info [full|n|m|s|f]            - 구조 정보 출력");
    disp("     full - 전체 / n - 노드 / m - 부재");
    disp("     s - 지점조건 / f - 하중");
    disp("  show                           - 현재 구조 시각적으로 출력");
    disp("  solve                          - 구조 해석 실행");
    disp("  clear                          - 전체 Beam 구조 초기화");
    disp("  clean                          - 구조 전체 보정");
    disp("  cleanF                         - 구조 전체 힘 초기화");
    disp("  vision image                   - 이미지에서 Beam 구조 자동 추출");
    disp("  q | exit | quit                - 프로그램 종료");
    disp("───────────────────────────────────────────────");
    disp("좌표는 (x,y) 형식, 여러 명령은 '/'로 구분해 한 줄 입력 가능");
    disp("예: mknod (0,0) / mknod (4,0) / mkmem (0,0),(4,0)");
end