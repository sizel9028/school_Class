function help()
    disp("사용 가능한 Truss 명령어:");
    disp("  mknod x1,y1                - 좌표 (x1,y1)에 노드 생성");
    disp("  delnod x1,y1               - 좌표 (x1,y1)의 노드 삭제");
    disp("  mkmem (x1,y1),(x2,y2)      - 두 노드 사이에 부재 생성");
    disp("  delmem (x1,y1),(x2,y2)     - 부재 삭제");
    disp("  fix x1,y1 pinned|(y)roller - 노드 (x1,y1)를 pinned|(y)roller로 고정");
    disp("  load X|Y x1,y1 num         - 좌표 (x1,y1)에 X|Y방향 num 크기 하중 작용");
    disp("  scale num X|Y              - num의 배율만큼 X|Y방향으로 node를 확장");
    disp("  mvn x1,y1,x2,y2            - x1,y1 노드를 x2,y2 노드로 이동");
    disp("  clear                      - 전체 구조 초기화");
    disp("  undo                       - 마지막 명령 취소");
    disp("  info nodes|members...      - 현재 구조 요약 정보 표시");
    disp("  show                       - 현재 구조 출력");
    disp("  solve                      - 트러스 힘 계산");
    disp("  help                       - 도움말 출력");
    disp("  chmod                      - determinate/indeterminate 분석 변경");
    disp("  set a|e num                - a|e의 값을 num으로 변경");
    disp("  ld|sd|rm file              - file을 불러오기|저장|삭제");
    disp("  ls|lsi                     - store|Image폴더에 저장된 모든 파일 출력");
    disp("  q|exit|quit                - 프로그램 종료");
    disp("  vision image               - 이미지를 분석후 트러스로 만듦");
    disp(" ");
    disp("좌표는 정수 또는 소수 입력 가능. 괄호 생략 가능");
    disp("여러 명령어를 '/' 로 구분하여 한 줄에 입력 가능");
    disp("예 : mkn 1,3 / mkn 2,5 / m 1 2");
end
