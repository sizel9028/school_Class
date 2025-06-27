#include <stdio.h>
#include <stdlib.h>
#include <string.h>    // 문자열로 받아 gg받으면 게임 끝나기 위해서
#include <ctype.h>
#include <unistd.h>    // sleep() 사용하기 위해서
#include <time.h>      // random함수에서 time을 null로 만들기 위해서
#include <math.h>      // pow 함수 쓰기 위해서

#define SIZE 15

#define ADD_NUM_1(i, j, num) \
    (board4_1[(i)][(j)] += (num))
#define ADD_NUM_2(i, j, num) \
    (board4_2[(i)][(j)] += (num))

char board[SIZE][SIZE];  // Game board
int board1[25][25]; //1:player1 2:player2 0:can put stone 4:4x4 fork 6:six stones 5:cant put stone edge 3: 3x3 fork
int player = 1;          // Player 1 or 2
int board2[25][25]={}; // save count stone 1 : count stone 0 : not count stone
int dx[]={1,0,1,1};
int dy[]={0,1,1,-1};
int board4_1[25][25]={0};  // player1 가중치 계산 (방어수)
int board3_1[25][25]={0}; // board3_ 은 각 시행이 중복되지 않기위해 횟수체크를 2진법으로 나타냄 ex 1101이면 dir 0 2 3일때는 더해졌다는 뜻
int board3_2[25][25]={0};
int board4_2[25][25]={0}; // player2(computer) 가중치 계산 (공격수)
int board4[25][25]={0}; // board4 = board4_1 + board4_2 공격 방어 가중치 차이를 두기위함
int board5[25][25]={0}; // computer mode에서 비어있는 원소를 찾기 위함
int computer;           // computer와 할지 player과 할지
int a[20][2]={0};
int b[2];

int find_34[25][25][4]={0};
int find34[25][25]={0};
// Clear the screen based on the operating system
void clearScreen() {
#ifdef _WIN32
    system("cls");    // Windows
#else
    system("clear");  // Ubuntu, macOS
#endif
}

int close_three_1(int,int,int);
int close_three_2(int,int,int);
int close_three_3(int,int,int);
int close_three_4(int,int,int);
int close_three_5(int,int,int);

void zero_board2(){
    for(int i=0;i<25;i++){
        for(int j=0;j<25;++j){
            board2[i][j] = 0;
        }
    }
}

void initalize_board1(){
    for(int i=0;i<25;++i){
        for(int j=0;j<25;++j){
            board1[i][j] = 5;
        }
    }
}

void zero_board1(){
    initalize_board1();
    for(int i=0;i<25;i++){
        for(int j=0;j<25;j++)
            if((i>=5&&i<20)&&(j>=5&&j<20))board1[i][j] = 0;
    }
}

// Initialize the board with '.'
void countingBoard(){
    for(int i=0;i<SIZE;i++){
        for(int j=0;j<SIZE;j++){
            if(board[i][j] == 'O') board1[i+5][j+5] = 1;  // 1 is 1 player stone
            else if(board[i][j] == 'X') board1[i+5][j+5] = 2; // 2 is 2 player stone
        }
    }
}

int find_4_space(int x,int y,int dir){
    int count = 0;
    while(board2[x][y]==1){
        if(board2[x][y]==1) count++;
        x+=dx[dir]; y+=dy[dir];
    }
    if(count==4) return 0;
    else return 1;
}

int really_4(int i,int j,int dir){
    int x=i,y=j;
    while(board1[x][y]!=5){
        x-=dx[dir]; y-=dy[dir];
    }
    while(board2[x][y]!=1){
        x+=dx[dir]; y+=dy[dir];
    }
    if(find_4_space(x,y,dir)==0){
        int count=0;
        x-=dx[dir]; y-=dy[dir];
        if(board1[x][y]==1) return 0;
        else if(board1[x][y]%3==2) count++;
        for(int k=0;k<5;++k){
            x+=dx[dir]; y+=dy[dir];
        }
        if(board1[x][y]==1) return 0;
        else if(board1[x][y]%3==2) count++;
        if(count==2) return 0;
        else return 1;
    }
    else{
        x-=dx[dir]; y-=dy[dir];
        if(board1[x][y]==1) return 0;
        for(int k=0;k<6;++k){
            x+=dx[dir]; y+=dy[dir];
        }
        if(board1[x][y]==1) return 0;
        return 1;
    }
}

int count_stone(int i,int j,int dir,int x,int y) { // find 1player stone / err : x,y가 counting stone에 포함되었는가
    int count = 0,err=1;                            // x,y는 금수 확인 좌표 
    for(int k=0;k<5;++k){
        if(board1[i+k*dx[dir]][j+k*dy[dir]]==1){
            count++;
            board2[i+k*dx[dir]][j+k*dy[dir]] = 1;
        }
        if(x==i+k*dx[dir]&&y==j+k*dy[dir]) err=0;
        if(board1[i+k*dx[dir]][j+k*dy[dir]]==2) break;
    }
    if(err==0) return count;
    else return 0;
}

int available_count(int i, int j,int available) { // count 4x4 fork count
    int count2 = 0;
     for(int dir=0;dir<4;dir++){
         int w = 0;
        for(int dir1=-4;dir1<=0;dir1++){
            int x_1 = i + dx[dir]*dir1;
            int y_1 = j + dy[dir]*dir1;
            int count1=0;
            if(board1[x_1][y_1] == 1){
                zero_board2();
                count1 = count_stone(x_1,y_1,dir,i,j);
            }
            if(count1 == 4 && available == 3) w = 1;
            if(available == 4) {if(count1 == available) if(really_4(x_1,y_1,dir)) count2++;}
            else{
                int a,b,c,d,e;
                a = close_three_1(i,j,dir); b=close_three_2(i,j,dir);
                c = close_three_3(i,j,dir); d=close_three_4(i,j,dir);
                e = close_three_5(i,j,dir);
                if(a*b*c*d*e==1 && count1==available && w==0) count2++;
            }
        }
     }
    return count2;
}

void four_available(){ // 4X4 fork by make 2 lines
    countingBoard();
    for(int i=5;i<20;i++){
        for(int j=5;j<20;j++){
           if(board1[i][j]==0 || board1[i][j]==4){
               board1[i][j] = 1;
               if(available_count(i,j,4) >= 2) board1[i][j] = 4;
               else board1[i][j] = 0;// 4X4fork cant put stone 
           }
        }
    }
}

int close_three_1(int i, int j,int dir) { // X . O O O . X case X를 찾고 그 후에 . 이랑 O O O가 체크된 돌인지 체크 마지막으로 . X가 있다면
//                                           이는 오픈 4를 만들지 못하므로 return 0즉 거짓값을 반환한다.
    int i_1=i,j_1=j;
    while(board1[i_1][j_1]%3!=2){
        i_1-=dx[dir];
        j_1-=dy[dir]; 
    } 
    i_1+=dx[dir];
    j_1+=dy[dir];
    int count=0;
    if(board1[i_1][j_1]%3==0||board1[i_1][j_1]==4) count++; // 0 3 4 6
    for(int k=0;k<3;++k){
        i_1+=dx[dir]; j_1+=dy[dir];
        if(board2[i_1][j_1]==1) count++;
    } 
    i_1+=dx[dir]; j_1+=dy[dir];
    if(board1[i_1][j_1]%3==0||board1[i_1][j_1]==4) count++;
    i_1+=dx[dir]; j_1+=dy[dir];
    if(board1[i_1][j_1]%3==2) count++;
    if(count==6) return 0;
    else return 1;
} // 1 : 3 fork make close 4

int close_three_2(int i,int j,int dir){ // O . O . O / O O . . O case
    int i_1=i,j_1=j;
    int count=0,tmp=1,zero_count=0;
    while(board1[i_1][j_1]%3!=2){
        i_1-=dx[dir];
        j_1-=dy[dir];
    }
    i_1+=dx[dir];
    j_1+=dy[dir];
    while(board1[i_1][j_1]%3!=2){
        if(board2[i_1][j_1]==1){
            tmp = 0;
            count ++;
            if(count == 3) break;
        }
        if(board2[i_1][j_1]==0&&tmp==0) zero_count++;
        i_1+=dx[dir];
        j_1+=dy[dir];
    }
    if(zero_count == 2) return 0;
        else return 1;
} 

int close_three_3_1(int i,int j,int dir){ // find X O
    if(board1[i+dx[dir]][j+dy[dir]]%3==2||board1[i-dx[dir]][j-dy[dir]]%3==2)
        return 1;                               // 참이면 1을 반환하여 closethree3 fun에서 0을 반환 (거짓)
        else return 0;
}

int close_three_3(int i,int j,int dir){ // X O 가 있는 case
    int i_1 = i,j_1 = j;
    while(board1[i_1][j_1]%3!=2){
        i_1 -= dx[dir];
        j_1 -= dy[dir];
    }
    i_1 += dx[dir];
    j_1 += dy[dir];
    while(board1[i_1][j_1]%3!=2){
        if(board2[i_1][j_1] == 1){
            if(close_three_3_1(i_1,j_1,dir)) return 0;
        }
        i_1 += dx[dir];
        j_1 += dy[dir];
    }                  
    return 1;           
}

void close_three_4_1(int* x,int* y, int dir){
    while(board1[*x][*y]%3!=2){
        *x-=dx[dir];
        *y-=dy[dir];
    } // find X
}

void close_three_4_2(int* x,int* y,int dir){
    while(board1[*x][*y]%3!=2){
        *x+=dx[dir];
        *y+=dy[dir];
    } // 반대방향 X찾기
}

int close_three_4(int i,int j,int dir){ // X . O O O . . O / X . O O . O . O / X . O . O O . O시간없어서 노가다
    int x=i,y=j;
    close_three_4_1(&x,&y,dir);
    int count=0,count1=0;
    if(board1[x][y]%3==2){ count++; count1++;}
    x+=dx[dir]; y+=dy[dir];
    if(board1[x][y]%3==0||board1[x][y]==4){ count++; count1++;}
    x+=dx[dir]; y+=dy[dir];
    for(int k=0;k<2;++k){
        if(board2[x][y]==1) {count++; count1++;}
        x+=dx[dir]; y+=dy[dir];
    }
    if(board2[x][y]==1) count++;
    if(board1[x][y]%3==0||board1[x][y]==4) count1++;
    x+=dx[dir]; y+=dy[dir];
    if(board1[x][y]%3==0||board1[x][y]==4) count++;
    if(board2[x][y]==1) count1++;
    x+=dx[dir]; y+=dy[dir];
    if(board1[x][y]%3==0||board1[x][y]==4) {count++; count1++;}
    x+=dx[dir]; y+=dy[dir];
    if(board1[x][y]==1) {count++; count1++;}
    if(count==8||count1==8) return 0;
    x=i;y=j;
    close_three_4_2(&x,&y,dir);
    count=0; count1=0;
    if(board1[x][y]%3==2){ count++; count1++;}
    x-=dx[dir]; y-=dy[dir];
    if(board1[x][y]%3==0||board1[x][y]==4){ count++; count1++;}
    x-=dx[dir]; y-=dy[dir];
    for(int k=0;k<2;++k){
        if(board2[x][y]==1) {count++; count1++;}
        x-=dx[dir]; y-=dy[dir];
    }
    if(board2[x][y]==1) count++;
    if(board1[x][y]%3==0||board1[x][y]==4) count1++;
    x-=dx[dir]; y-=dy[dir];
    if(board1[x][y]%3==0||board1[x][y]==4) count++;
    if(board2[x][y]==1) count1++;
    x-=dx[dir]; y-=dy[dir];
    if(board1[x][y]%3==0||board1[x][y]==4) {count++; count1++;}
    x-=dx[dir]; y-=dy[dir];
    if(board1[x][y]==1) {count++; count1++;}
    if(count==8||count1==8) return 0;

    int count2=0;   // X . O . O O . O 
    x=i,y=j;
    close_three_4_1(&x,&y,dir);
    if(board1[x][y]%3==2) count2++;
    x += dx[dir]; y+=dy[dir];
    if(board1[x][y]%3==0||board1[x][y]==4) count2++;
    x += dx[dir]; y+=dy[dir];
    if(board2[x][y]==1) count2++;
    x += dx[dir]; y+=dy[dir];
    if(board1[x][y]%3==0||board1[x][y]==4) count2++;
    x += dx[dir]; y+=dy[dir];
    for(int k=0;k<2;++k){
        if(board2[x][y]==1) count2++;
        x += dx[dir]; y+=dy[dir];
    }
    if(board1[x][y]%3==0||board1[x][y]==4) count2++;
    x += dx[dir]; y+=dy[dir];
    if(board1[x][y]==1) count2++;
    if(count2==8) return 0;
    count2=0;
    x=i,y=j;
    close_three_4_2(&x,&y,dir);
    if(board1[x][y]%3==2) count2++;
    x -= dx[dir]; y-=dy[dir];
    if(board1[x][y]%3==0||board1[x][y]==4) count2++;
    x -= dx[dir]; y-=dy[dir];
    if(board2[x][y]==1) count2++;
    x -= dx[dir]; y-=dy[dir];
    if(board1[x][y]%3==0||board1[x][y]==4) count2++;
    x -= dx[dir]; y-=dy[dir];
    for(int k=0;k<2;++k){
        if(board2[x][y]==1) count2++;
       x -= dx[dir]; y-=dy[dir];
    }
    if(board1[x][y]%3==0||board1[x][y]==4) count2++;
    x -= dx[dir]; y-=dy[dir];
    if(board1[x][y]==1) count2++;
    if(count2==8) return 0;
    else return 1;
}

int close_three_5(int i,int j,int dir){ // O O . O 꼴인데 . 이 4x4 fork인 case
    while(board1[i][j]!=5){
        i-=dx[dir];
        j-=dy[dir];
    }
    int count=0,count1=0;
    while(board1[i][j]!=5||count1<3){
        if(board2[i][j]==1) count++;
        if(board1[i][j]==5) count1++;
        if(count>0&&board1[i][j]==0) break;
        i+=dx[dir];
        j+=dy[dir];
    }
    int tmp = board1[i][j];
    board1[i][j]=1;
    if(available_count(i,j,4)>=2){
        board1[i][j] = tmp;
        return 0;
    }
    else{
        board1[i][j] = tmp;
        return 1;
    }
}

int count_three(int i, int j){ // 3개의 돌이 2개 연속 겹침이 일어남 : 1, 아니다 : -1
    int count2 = available_count(i,j,3);
    if(count2 >= 2) return 1;
    else return 0;
}

void three_available() {
    countingBoard();
    for(int i=5;i<20;i++){
        for(int j=5;j<20;j++){
           if(board1[i][j]==0 || board1[i][j]==3){
               board1[i][j] = 1;
               if(count_three(i,j)) board1[i][j] = 3;
               else board1[i][j] = 0;// 4X4fork cant put stone 
           }
        }
    }
    
}

void first_6(int* x,int* y,int dir){
    while(board1[*x][*y]==1){
        *x -= dx[dir];
        *y -= dy[dir];
    }
    *x += dx[dir];
    *y += dy[dir]; // board1[x][y] 가 1인시점을 찾아준다.
}

int count_6(int i,int j,int dir){
    int count=0;
    int x=i,y=j;
    first_6(&x,&y,dir);
    while(board1[x][y]==1){
        if(board1[x][y]==1) count++;
        x+=dx[dir];
        y+=dy[dir];
    }
    if(count>=6) return 1;
    else return 0;
}

void six_1(int i,int j){
    if(board1[i][j]==0){
        for(int dir=0;dir<4;++dir){
            board1[i][j] = 1;
            if(count_6(i,j,dir)) {board1[i][j]=6; break;}
            else board1[i][j]=0;
        }
    }
}

void six_row_available(){
    countingBoard();
    for(int i=5;i<25;++i){
        for(int j=5;j<20;++j){
            six_1(i,j);
        }
    }
}

void initBoard() {
    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < SIZE; j++) {
            board[i][j] = '.';
        }
    }
}

// Print the game board
void printBoard() {
    four_available();
    three_available();
    six_row_available();
    /*for(int i=0;i<25;++i){
        for(int j=0;j<25;++j) printf("%d ",board4[i][j]);
        putchar('\n');
    }*/

    printf("   ");
    for (int i = 0; i < SIZE; i++) {
        printf("%c ", 'A' + i);  // Column labels
    }
    printf("\n");

    if(player==1){
    for (int i = 0; i < SIZE; i++) {
        printf("%2d ", i + 1);  // Row labels
        for (int j = 0; j < SIZE; j++) {
            if(board1[i+5][j+5] <= 2) printf("%c ",board[i][j]);
            else printf("* ");
        }
        printf("\n");
    }
    }
    else{
        for (int i = 0; i < SIZE; i++) {
        printf("%2d ", i + 1);  // Row labels
        for (int j = 0; j < SIZE; j++) {
            printf("%c ",board[i][j]);
        }
        printf("\n");
    }
    }
}

// Convert input like 'A13' into board indices
int convertInput(char col, int row, int *x, int *y) {
    if (col < 'A' || col > 'O' || row < 1 || row > SIZE) {
        return 0;  // Invalid input
    }
    *x = row - 1;
    *y = col - 'A';
    return 1;
}

// Check if there are 5 stones in a row
int checkWin(int x, int y) {
    char stone = board[x][y];
    int dx[] = {1, 0, 1, 1};   // Horizontal, vertical, diagonal directions
    int dy[] = {0, 1, 1, -1};  // Horizontal, vertical, diagonal directions

    for (int dir = 0; dir < 4; dir++) {
        int count = 1;  // Include the current position

        // Check in one direction
        for (int step = 1; step < 5; step++) {
            int nx = x + step * dx[dir];
            int ny = y + step * dy[dir];
            if (nx >= 0 && nx < SIZE && ny >= 0 && ny < SIZE && board[nx][ny] == stone) {
                count++;
            } else {
                break;
            }
        }

        // Check in the opposite direction
        for (int step = 1; step < 5; step++) {
            int nx = x - step * dx[dir];
            int ny = y - step * dy[dir];
            if (nx >= 0 && nx < SIZE && ny >= 0 && ny < SIZE && board[nx][ny] == stone) {
                count++;
            } else {
                break;
            }
        }

        if (count >= 5) {
            return 1;  // Victory
        }
    }

    return 0;  // Victory condition not met
}

void computer_turn();

// Play the game
void playGame() {
    char col;
    int row, x, y;
    char input[100];
    while (1) {
        if(computer == 2) break;
        if(computer==0||player==1){
        row = 0;
        int tmp=0;
        clearScreen();  // Clear the screen
        printBoard();
        printf("Player %d's turn (enter column and row, e.g., A13): ", player);

        // Input processing
        scanf(" %s", input); // ignore blank
        if(strcmp("gg",input)==0){
            clearScreen();
            printBoard();
            player = (player == 1) ? 2 : 1;
            if(computer==0)
            printf("Player %d wins!\n", player);
            else printf("Computer win!");
            break;
        }
        if(isalpha(input[0])){
            col = input[0];
        }else{
            printf("Invalid move. Try again\n");
            sleep(1);
            continue;
        }
        for(int i=1;input[i]!='\0';++i){
            if(isdigit(input[i]))
            row = row*10+(input[i]-'0');
            else tmp++;
        }
        if(tmp>0){
            printf("Invalid move. Try again\n");
                        printf("%d",tmp);
            sleep(1);
            continue;
        }
        col = toupper(col);  // Convert to uppercase

        // Convert input coordinates to board indices
        int i,j;
        j = col - 'A' + 5; // i,j는 board1의 좌표
        i = row + 5 - 1;

        if ((!convertInput(col, row, &x, &y)|| board[x][y] != '.') || (player==1&&board1[i][j]!=0)) {
            printf("Invalid move. Try again\n");
            sleep(1);
            continue;
        }

        // Place the stone
        board[x][y] = (player == 1) ? 'O' : 'X';

        // Check for victory condition
        if (checkWin(x, y)) {
            clearScreen();
            printBoard();
            printf("Player %d wins!\n", player);
            break;
        }

        // Switch to the next player
        player = (player == 1) ? 2 : 1;
        }
        else computer_turn();
    }
}
void get_com();
void computer_turn();
void play_mode();
int can_put(int i,int j);
int count_stone_2(int i,int j,int dir);
int count_stone_1(int i,int j,int dir);
void player_1_1();
void player_1_2();
void player_1_3();
void player_1_4();
void player_2_1();
void player_2_2();
void player_2_3();
void player_2_4();
void add_4();
void close_computer();
void do_3_4();

int main() {
    play_mode();
    zero_board1();
    initBoard();
    playGame();
    return 0;
}

// computer mode code

void reset_a(){
    for(int i=0;i<20;++i){
        for(int j=0;j<2;++j){
            a[i][j] = 0;
        }
    }
}

void reset_board4(){
    for(int i=0;i<25;++i){
        for(int j=0;j<25;++j){
            board4_1[i][j] = 0;
            board4_2[i][j] = 0;
            board3_1[i][j] = 0;
            board3_2[i][j] = 0;
        }
    }
}

void get_com(){
    reset_board4(); // 전에 만들었던 가중치를 초기화
    player_1_4();
    player_1_3();
    player_1_2();
    player_1_1();
    close_computer(); // 공격 턴 낭비 방지를 위한 board3_2 제거
    player_2_4(); 
    player_2_3();
    player_2_2();
    player_2_1(); // 가중치를 두는 식
    do_3_4();

    add_4();
    int tmp = -1;
    int start=0;
    for(int i=0;i<25;++i){
        for(int j=0;j<25;++j){
        if(tmp < board4[i][j] && board1[i][j] %4!=1 && board1[i][j]!=2){
            tmp = board4[i][j];
            start = 0;
            reset_a();
            a[start][0] = i;
            a[start][1] = j;
        }
        else if(board4[i][j]==tmp && board1[i][j]%4!=1&&board1[i][j]!=2){
            start++;
            a[start][0]=i;
            a[start][1]=j;
        }
        }
    }
}

int a_size(){
    int count = 0;
    for(int i=0;i<20;++i){
        if(a[i][0]>0) count++;
    }
    return count;
}

void get_b(){
    int size = a_size();
    srand(time(NULL));
    int random_num = rand() % size;
    b[0] = a[random_num][0];
    b[1] = a[random_num][1];
}

void computer_turn(){
    clearScreen();
    printBoard();
    get_com();
    get_b();
    printf("computer turn");
    for(int i=0;i<3;++i){
        putchar('.'); sleep(1);
    }
    board[b[0]-5][b[1]-5]='X';
    int x = b[0] - 5;
    int y = b[1] - 5;
    if (checkWin(x, y)) {
        clearScreen();
        printBoard();
        printf("Computer win!");
        computer = 2;
    }
    player = (player == 1) ? 2 : 1;
}

void play_mode(){
    char s[50];
    while(1){
        clearScreen();
        printf("choose mode(computer/player)");
        scanf("%s",s);
        if(strcmp(s,"computer")==0){ computer=1; break;}
        else if(strcmp(s,"player")==0){ computer=0; break;}
        else{
            printf("Try again\n");
            sleep(1);
            continue;
        }
    }
}

int can_put(int i,int j){
    if(board1[i][j]%3==0||board1[i][j]==4) return 1; // 0,3,4,6 수 놓을수있는 자리
    else return 0;
}

int count_stone_2(int i,int j,int dir) { // find 2player stone
    int count = 0;
    for(int k=0;k<5;++k){
        if(board1[i+k*dx[dir]][j+k*dy[dir]]==2){
            count++;
            board5[i+k*dx[dir]][j+k*dy[dir]] = 1;
        }
        else if(board1[i+k*dx[dir]][j+k*dy[dir]]==1) break;
    }
    return count;
}

int count_stone_1(int i,int j,int dir) { // find 1player stone// dir 방향만
    int count = 0;
    for(int k=0;k<5;++k){
        if(board1[i+k*dx[dir]][j+k*dy[dir]]==1){
            count++;
            board5[i+k*dx[dir]][j+k*dy[dir]] = 1;
        }
        else if(board1[i+k*dx[dir]][j+k*dy[dir]]==2) break;
    }
    return count;
}

void rs_board5(){
    for(int i=0;i<25;++i){
        for(int j=0;j<25;++j){
            board5[i][j] = 0;
        }
    }
}

void front_xy(int* x, int* y, int dir);
void back_xy(int* x,int* y, int dir);

void move_xy(int* x, int* y,int dir){
    while(board1[*x][*y] != 5) back_xy(x,y,dir);
    front_xy(x,y,dir);
    // x y를 옮긴다 맵의 제일 끝쪽에
}

void front_xy(int* x, int* y, int dir){
    *x += dx[dir];
    *y += dy[dir];
}

void back_xy(int* x,int* y, int dir){
    *x -= dx[dir];
    *y -= dy[dir];
}

void find_1(int *x,int *y, int dir){
    while(board1[*x][*y]!=5){
        if(board5[*x][*y]==1) break;
        front_xy(x,y,dir);
    }
}

int find_stone(int i,int j,int dir,int available){ // 3or4 개의 스톤의 각각의 끝부분이 몇개로 막혀있는지 체크
    find_1(&i,&j,dir);
    int count = 0,count1=0;
    back_xy(&i,&j,dir);
    if(can_put(i,j)) count++;
    front_xy(&i,&j,dir);
    while(board1[i][j]!=5&&count1<available){
        if(board5[i][j] == 1) count1++;
        front_xy(&i,&j,dir);
    }
    if(can_put(i,j)) count++;
    return count;
}

void dir_board3(int num,int x,int y,int dir){
    if(num==1){
        switch(dir){
            case 0: board3_1[x][y]+=1; break;
            case 1: board3_1[x][y]+=2; break;
            case 2: board3_1[x][y]+=4; break;
            case 3: board3_1[x][y]+=8; break;
        }
    }
    else if(num==2){
        switch(dir){
            case 0: board3_2[x][y]+=1; break;
            case 1: board3_2[x][y]+=2; break;
            case 2: board3_2[x][y]+=4; break;
            case 3: board3_2[x][y]+=8; break;
        }
    }
}

int close_c_3(int i,int j,int count,int dir,int n){
    int x = i+n*count*dx[dir];
    int y = j+n*count*dy[dir];
    if(board1[x][y]%4==1){
        return 1;
    }
    else return 0;
}

void close_c_2(int i,int j,int count){
    int n=-1;
    while(n<2){
        for(int dir=0;dir<4;++dir){
            if(close_c_3(i,j,count,dir,n)){
                for(int k=1;k<count;++k){
                    int x=i+n*k*dx[dir];
                    int y=j+n*k*dy[dir];
                    if(dir==0) board3_2[x][y] += 1;
                    if(dir==1) board3_2[x][y] += 2;
                    if(dir==2) board3_2[x][y] += 4;
                    if(dir==3) board3_2[x][y] += 8; // 각 dir에 대한 덧셈을 제거
                }
            }
        }
        n+=2;
    }
}

void close_c_1(int i,int j){
    if(board1[i][j]==1){
        for(int count=2;count<6;++count){
            close_c_2(i,j,count);
        }
    }
}

void close_computer(){         // board3_2를 꽉 채움 -> 공격 가중치를 제거한다 ex) O . X X X O . 자리는 공격을 하면 턴 낭비(제외)
    for(int i=5;i<20;i++){
        for(int j=5;j<20;++j){
            close_c_1(i,j);
        }
    }
}

int check_board3_1(int x,int y,int dir){
    if(board3_1[x][y]%(int)pow(2,dir+1)<(int)pow(2,dir)) return 1; // 같은 dir에서 연산이 안되어있으면 참을 반환
    else return 0;                                                 // dir=0 board % 2 < 1 2진법에 1(2)없으면 이 dir에 대해 카운팅 x
}

int check_board3_2(int x,int y,int dir){
    if(board3_2[x][y]%(int)pow(2,dir+1)<(int)pow(2,dir)) return 1; 
    else return 0;
}

int find_space(int i,int j,int dir,int num){ // board5에서 빈칸의 갯수를 찾는 용도.
    int x=i,y=j;
    find_1(&x,&y,dir);
    int count=0,w=0;
    int space=0;
    while(count<num){
        if(board5[x][y]==1){
            count++; w=1;
        }
        if(board5[x][y]==0&&w==1) space++;
        front_xy(&x,&y,dir);
    }
    return space;
}

void get_space_1(int* x,int* y,int dir){
    find_1(x,y,dir);
    while(board1[*x][*y]!=5){
        if(board5[*x][*y]==0) break;
        front_xy(x,y,dir);
    }
}

void player_1_1(){ // dir 가중치로 부터 1_4 -> 1_3 -> 1_2 순으로 진행함 1의 경우에는 중복 중첩이 안되게만 함
    for(int i=5;i<20;++i){
        for(int j=5;j<20;++j){
            if(board1[i][j]==1){
                int n=-1;
                while(n<2){
                    for(int dir=0;dir<4;++dir){ // 11001 : 1의 카운팅 O dir : 0,3의 경우 카운팅이 되었다.
                        int x=i+n*dx[dir];
                        int y=j+n*dy[dir];           // 같은 방향 dir이 있으면 세지 않는다 1101 : dir0,dir2,dir3 세짐(가중치)
                        if(can_put(x,y)&&check_board3_1(x,y,4)) {ADD_NUM_1(x,y,1); board3_1[x][y]+=16;} 
                    }
                    n+=2;
                }
            }
        }
    }
}

void player_1_2_1(int i,int j){
    for(int dir=0;dir<4;++dir){
        if(count_stone_1(i,j,dir)==2&&board1[i][j]==1){
            int x=i,y=j;
            move_xy(&x,&y,dir);
            int add;
            switch(find_stone(x,y,dir,2)) {
                case 0: add = 0; break;
                case 1: add = 2; break;
                case 2: add = 50; break;
            }
            find_1(&x,&y,dir);
            back_xy(&x,&y,dir);
            int stone=0;

            
            while(stone<2){
                if(can_put(x,y)&&check_board3_1(x,y,dir)){ADD_NUM_1(x,y,add); dir_board3(1,x,y,dir);}
                if(board5[x][y]==1) stone++;
                front_xy(&x,&y,dir);
            }
            if(can_put(x,y)&&check_board3_1(x,y,dir)){ADD_NUM_1(x,y,add); dir_board3(1,x,y,dir);}
        }
        rs_board5();
    }
}

void player_1_2(){
    for(int i=5;i<20;++i){
        for(int j=5;j<20;++j){
            player_1_2_1(i,j);
        }
    }
}

void player_1_3_1(int i,int j){
    for(int dir=0;dir<4;++dir){
        if(count_stone_1(i,j,dir)==3&&board1[i][j]==1){
            int x=i,y=j;
            move_xy(&x,&y,dir);
            int add;
            switch(find_stone(x,y,dir,3)) {
                case 0: add = 0; break;
                case 1: add = 50; break;
                case 2: add = 1000; break;
            }
            if(find_space(x,y,dir,3)==0){
                find_1(&x,&y,dir);
                if(add==50){
                    back_xy(&x,&y,dir);
                    if(board1[x][y]%3==2){   // case X O O O
                        for(int k=0;k<4;++k) front_xy(&x,&y,dir);
                        if(board1[x][y]==0&&find_34[x][y][dir]==0) find_34[x][y][dir]++;
                        front_xy(&x,&y,dir);
                        if(board1[x][y]==0&&find_34[x][y][dir]==0) find_34[x][y][dir]++;
                    }
                    else{
                        for(int k=0;k<4;++k) front_xy(&x,&y,dir);
                        if(board1[x][y]%3==2){
                            for(int k=0;k<4;++k) back_xy(&x,&y,dir);
                            if(board1[x][y]==0&&find_34[x][y][dir]==0) find_34[x][y][dir]++;
                            back_xy(&x,&y,dir);
                            if(board1[x][y]==0&&find_34[x][y][dir]==0) find_34[x][y][dir]++;
                        }
                    }
                }
                move_xy(&x,&y,dir);
                find_1(&x,&y,dir);
                back_xy(&x,&y,dir);
                int stone=0;
                while(stone<3){
                    if(can_put(x,y)&&check_board3_1(x,y,dir)){ADD_NUM_1(x,y,add); dir_board3(1,x,y,dir);}
                    if(board5[x][y]==1) stone++;
                    front_xy(&x,&y,dir);
                }
                if(can_put(x,y)&&check_board3_1(x,y,dir)){ADD_NUM_1(x,y,add); dir_board3(1,x,y,dir);}
            }
            else if(find_space(i,j,dir,3)==1){
                find_1(&x,&y,dir);
                if(add==50){
                    back_xy(&x,&y,dir);
                    if(board1[x][y]%3==2){   // case X O . O O / X O O . O
                        for(int k=0;k<5;++k){
                            front_xy(&x,&y,dir);
                            if(board1[x][y]==0&&find_34[x][y][dir]==0) find_34[x][y][dir]++;
                        }
                    }
                    else{
                        for(int k=0;k<5;++k) front_xy(&x,&y,dir);
                        if(board1[x][y]%3==2){
                            for(int k=0;k<5;++k){
                            back_xy(&x,&y,dir);
                            if(board1[x][y]==0&&find_34[x][y][dir]==0) find_34[x][y][dir]++;
                        }
                        }
                    }
                }
                move_xy(&x,&y,dir);
                get_space_1(&x,&y,dir);
                if(can_put(x,y)&&check_board3_1(x,y,dir)){
                    ADD_NUM_1(x,y,add); dir_board3(1,x,y,dir);
                }
            }
            else if(find_space(i,j,dir,3)==2){
                if(add!=0){
                    find_1(&x,&y,dir);
                    for(int k=0;k<4;++k){
                        front_xy(&x,&y,dir);
                        if(board1[x][y]==0&&find_34[x][y][dir]==0) find_34[x][y][dir]++;
                    }
                }
                move_xy(&x,&y,dir);
                get_space_1(&x,&y,dir);
                if(add == 1000) add = 50;  // O . O . O 는 3이지만 막을 수 있기때문에 가중치를 적게 둔다.
                if(can_put(x,y)&&check_board3_1(x,y,dir)){
                    ADD_NUM_1(x,y,add); dir_board3(1,x,y,dir);
                }
                front_xy(&x,&y,dir); front_xy(&x,&y,dir); // 두칸 앞으로
                if(can_put(x,y)&&check_board3_1(x,y,dir)){
                    ADD_NUM_1(x,y,add); dir_board3(1,x,y,dir);
                }
            }
        }
        rs_board5();
    }
}

void player_1_3(){
    for(int i=5;i<20;++i){
        for(int j=5;j<20;++j){
            player_1_3_1(i,j);
        }
    }
}

void player_1_4_1(int i,int j){
    for(int dir=0;dir<4;++dir){
        if(count_stone_1(i,j,dir)==4&&board1[i][j]==1){
            int x=i,y=j;
            move_xy(&x,&y,dir);
            int add;
            switch(find_stone(x,y,dir,4)){
                case 0: add=0; break;
                case 1: add=2500; break;
                case 2: add=2500; break;
            }
            if(find_space(x,y,dir,4)==0){
                find_1(&x,&y,dir);
                back_xy(&x,&y,dir);
                int stone=0;
                while(stone<4){
                    if(can_put(x,y)&&check_board3_1(x,y,dir)){ADD_NUM_1(x,y,add); dir_board3(1,x,y,dir);}
                    if(board5[x][y]==1) stone++;
                    front_xy(&x,&y,dir);
                }
                if(can_put(x,y)&&check_board3_1(x,y,dir)){ADD_NUM_1(x,y,add); dir_board3(1,x,y,dir);} //끝부분 stone 가중치 더해줌 ...O (here)
            }
            else if(find_space(x,y,dir,4)==1){
                add = 2500;
                get_space_1(&x,&y,dir);
                if(can_put(x,y)&&check_board3_1(x,y,dir)){
                    ADD_NUM_1(x,y,add);
                    dir_board3(1,x,y,dir);
                }
            }
        }
        rs_board5();
    }
}

void player_1_4(){
    for(int i=5;i<20;++i){
        for(int j=5;j<20;++j){
            player_1_4_1(i,j);
        }
    }
}

void player_2_1(){
    for(int i=5;i<20;++i){
        for(int j=5;j<20;++j){
            if(board1[i][j]==2){
                int n=-1;
                while(n<2){
                    for(int dir=0;dir<4;++dir){
                        int x=i+n*dx[dir];
                        int y=j+n*dy[dir];           // 같은 방향 dir이 있으면 세지 않는다 1101 : dir0,dir2,dir3 세짐(가중치)
                        if(can_put(x,y)&&check_board3_1(x,y,4)) {ADD_NUM_2(x,y,1); board3_1[x][y]+=16;} 
                    } // 낯개의 돌은 검은 흰 상관없이 한번만 카운팅 한다.
                    n+=2;
                }
            }
        }
    }
}

void player_2_2_1(int i,int j){
    for(int dir=0;dir<4;++dir){
        if(count_stone_2(i,j,dir)==2&&board1[i][j]==2){
            int x=i,y=j;
            move_xy(&x,&y,dir);
            int add;
            switch(find_stone(x,y,dir,2)) {
                case 0: add = 0; break;
                case 1: add = 2; break;
                case 2: add = 50; break;
            }
            find_1(&x,&y,dir);   // board1이 아닌 board5의 1의 숫자를 찾음
            back_xy(&x,&y,dir);
            int stone=0;
            while(stone<2){
                if(can_put(x,y)&&check_board3_2(x,y,dir)){ADD_NUM_2(x,y,add); dir_board3(2,x,y,dir);}
                if(board5[x][y]==1) stone++;
                front_xy(&x,&y,dir);
            }
            if(can_put(x,y)&&check_board3_2(x,y,dir)){ADD_NUM_2(x,y,add); dir_board3(2,x,y,dir);}
        }
        rs_board5();
    }
}

void player_2_2(){
    for(int i=5;i<20;++i){
        for(int j=5;j<20;++j){
            player_2_2_1(i,j);
        }
    }
}


int pla2_attack(int x,int y,int dir){  // O . X X X . O
    find_1(&x,&y,dir);
    back_xy(&x,&y,dir); back_xy(&x,&y,dir);
    if(board1[x][y]%4==1) return 1;
    for(int i=0;i<6;++i) front_xy(&x,&y,dir); // 앞으로 6칸 가라
    if(board1[x][y]%4==1) return 1;
    else return 0;
}

void player_2_3_1(int i,int j){
    for(int dir=0;dir<4;++dir){
        if(count_stone_2(i,j,dir)==3&&board1[i][j]==2){
            int x=i,y=j;
            move_xy(&x,&y,dir);
            int add;
            switch(find_stone(x,y,dir,3)) {
                case 0: add = 0; break;
                case 1: add = 50; break;
                case 2: add = 2000; break;
            }
            if(find_space(x,y,dir,3)==0){    // X X X
                if(add==2000&&pla2_attack(x,y,dir)){
                    find_1(&x,&y,dir);
                    back_xy(&x,&y,dir); back_xy(&x,&y,dir);
                    if(board1[x][y]%4==1){  // 6칸 앞으로 가서 돌을 둔다.
                        for(int k=0;k<5;++k) front_xy(&x,&y,dir);
                        if(can_put(x,y)&&check_board3_2(x,y,dir)){ADD_NUM_2(x,y,add); dir_board3(2,x,y,dir);}
                    }
                    else{
                        if(can_put(x,y)&&check_board3_2(x,y,dir)){ADD_NUM_2(x,y,add); dir_board3(2,x,y,dir);}
                    }
                }
                else{
                find_1(&x,&y,dir);
                back_xy(&x,&y,dir);
                int stone=0;
                while(stone<3){
                    if(can_put(x,y)&&check_board3_2(x,y,dir)){ADD_NUM_2(x,y,add); dir_board3(2,x,y,dir);}
                    if(board5[x][y]==1) stone++;
                    front_xy(&x,&y,dir);
                }
                if(can_put(x,y)&&check_board3_2(x,y,dir)){ADD_NUM_2(x,y,add); dir_board3(2,x,y,dir);}
                }
            }
            else if(find_space(i,j,dir,3)==1){
                get_space_1(&x,&y,dir);
                if(can_put(x,y)&&check_board3_2(x,y,dir)){
                    ADD_NUM_2(x,y,add); dir_board3(2,x,y,dir);
                }
            }
            else if(find_space(i,j,dir,3)==2){
                get_space_1(&x,&y,dir);
                if(add == 1000) add = 75;  // O . O . O 는 3이지만 막을 수 있기때문에 가중치를 적게 둔다.
                if(can_put(x,y)&&check_board3_2(x,y,dir)){
                    ADD_NUM_2(x,y,add); dir_board3(2,x,y,dir);
                }
                front_xy(&x,&y,dir); front_xy(&x,&y,dir); // 두칸 앞으로
                if(can_put(x,y)&&check_board3_2(x,y,dir)){
                    ADD_NUM_2(x,y,add); dir_board3(2,x,y,dir);
                }
            }
        }
        rs_board5();
    }
}

void player_2_3(){
    for(int i=5;i<20;++i){
        for(int j=5;j<20;++j){
            player_2_3_1(i,j);
        }
    }
}

void player_2_4_1(int i,int j){
    for(int dir=0;dir<4;++dir){
        if(count_stone_2(i,j,dir)==4&&board1[i][j]==2){
            int x=i,y=j;
            move_xy(&x,&y,dir);
            int add;
            switch(find_stone(x,y,dir,4)){
                case 0: add=0; break;
                case 1: add=5000; break;
                case 2: add=5000; break;
            }
            if(find_space(x,y,dir,4)==0){
                find_1(&x,&y,dir);
                back_xy(&x,&y,dir);
                int stone=0;
                while(stone<4){
                    if(can_put(x,y)&&check_board3_2(x,y,dir)){ADD_NUM_2(x,y,add); dir_board3(2,x,y,dir);}
                    if(board5[x][y]==1) stone++;
                    front_xy(&x,&y,dir);
                }
                if(can_put(x,y)&&check_board3_2(x,y,dir)){ADD_NUM_2(x,y,add); dir_board3(2,x,y,dir);} //끝부분 stone 가중치 더해줌 ...O (here)
            }
            else if(find_space(x,y,dir,4)==1){
                get_space_1(&x,&y,dir);
                if(can_put(x,y)&&check_board3_2(x,y,dir)){
                    add = 5000;      // X X . X X 면 그냥 승리니 가중치 높인다.
                    ADD_NUM_2(x,y,add);
                    dir_board3(2,x,y,dir);
                }
            }
        }
        rs_board5();
    }
}

void player_2_4(){
    for(int i=5;i<20;++i){
        for(int j=5;j<20;++j){
            player_2_4_1(i,j);
        }
    }
}

void add_34(){
    for(int i=0;i<25;++i){
        for(int j=0;j<25;++j){
            for(int dir=0;dir<4;++dir){
                find34[i][j] = find_34[i][j][dir];
            }
        }
    }
}

int case_1(int i,int j,int dir){
    int count =0;
    if(board1[i+dx[dir]][j+dy[dir]]==1) count++;
    if(board1[i-dx[dir]][j-dy[dir]]==1) count++;
    back_xy(&i,&j,dir); back_xy(&i,&j,dir);
    if(board1[i][j]%4!=1&&board1[i][j]!=2) count++;
    int space=0;
    back_xy(&i,&j,dir);
    if(board1[i][j]%4!=1&&board1[i][j]!=2) space++;
    for(int k=0;k<5;++k) front_xy(&i,&j,dir);
    if(board1[i][j]%4!=1&&board1[i][j]!=2) count++;
    front_xy(&i,&j,dir);
    if(board1[i][j]%4!=1&&board1[i][j]!=2) space++;
    if(space>=1) count++;
    if(count == 5) return 1;
    else return 0;
}

int case_2_1(int i,int j,int dir){
    int count=0;
    front_xy(&i,&j,dir); front_xy(&i,&j,dir);
    if(board1[i][j]==1) count++;
    front_xy(&i,&j,dir);
    if(board1[i][j]==1) count++;
    front_xy(&i,&j,dir);
    if(board1[i][j]%4!=1&&board1[i][j]!=2) count++;
    back_xy(&i,&j,dir); back_xy(&i,&j,dir); back_xy(&i,&j,dir);
    if(board1[i][j]%4!=1&&board1[i][j]!=2) count++;
    back_xy(&i,&j,dir); back_xy(&i,&j,dir);
    if(board1[i][j]%4!=1&&board1[i][j]!=2) count++;
    if(count == 5) return 1;
    else return 0;
}

int case_2_2(int i,int j,int dir){
    int count=0;
    back_xy(&i,&j,dir);back_xy(&i,&j,dir);
    if(board1[i][j]==1) count++;
    back_xy(&i,&j,dir);
    if(board1[i][j]==1) count++;
    back_xy(&i,&j,dir);
    if(board1[i][j]%4!=1&&board1[i][j]!=2) count++;
    front_xy(&i,&j,dir);front_xy(&i,&j,dir);front_xy(&i,&j,dir);
    if(board1[i][j]%4!=1&&board1[i][j]!=2) count++;
    front_xy(&i,&j,dir);front_xy(&i,&j,dir);
    if(board1[i][j]%4!=1&&board1[i][j]!=2) count++;
    if(count == 5) return 1;
    else return 0;
}

int case_3_1(int i,int j,int dir){
    int count=0;
    front_xy(&i,&j,dir);
    if(board1[i][j]==1) count++;
    front_xy(&i,&j,dir);
    if(board1[i][j]%4!=1&&board1[i][j]!=2) count++;
    front_xy(&i,&j,dir);
    if(board1[i][j]==1) count++;
    front_xy(&i,&j,dir);
    if(board1[i][j]%4!=1&&board1[i][j]!=2) count++;
    for(int k=0;k<5;++k) back_xy(&i,&j,dir);
    if(board1[i][j]%4!=1&&board1[i][j]!=2) count++;
    if(count ==5) return 1;
    else return 0;
}

int case_3_2(int i,int j,int dir){
    int count=0;
    back_xy(&i,&j,dir);
    if(board1[i][j]==1) count++;
    back_xy(&i,&j,dir);
    if(board1[i][j]%4!=1&&board1[i][j]!=2) count++;
    back_xy(&i,&j,dir);
    if(board1[i][j]==1) count++;
    back_xy(&i,&j,dir);
    if(board1[i][j]%4!=1&&board1[i][j]!=2) count++;
    for(int k=0;k<5;++k) front_xy(&i,&j,dir);
    if(board1[i][j]%4!=1&&board1[i][j]!=2) count++;
    if(count ==5) return 1;
    else return 0;
}

int case_4_1(int i,int j,int dir){
    int count=0;
    back_xy(&i,&j,dir);
    if(board1[i][j]==1) count++;
    back_xy(&i,&j,dir);
    if(board1[i][j]%4!=1&&board1[i][j]!=2) count++;
    for(int k=0;k<3;++k) front_xy(&i,&j,dir);
    if(board1[i][j]%4!=1&&board1[i][j]!=2) count++;
    front_xy(&i,&j,dir);
    if(board1[i][j]==1) count++;
    front_xy(&i,&j,dir);
    if(board1[i][j]%4!=1&&board1[i][j]!=2) count++;
    if(count==5) return 1;
    else return 0;
}

int case_4_2(int i,int j,int dir){
    int count=0;
    front_xy(&i,&j,dir);
    if(board1[i][j]==1) count++;
    front_xy(&i,&j,dir);
    if(board1[i][j]%4!=1&&board1[i][j]!=2) count++;
    for(int k=0;k<3;++k) back_xy(&i,&j,dir);
    if(board1[i][j]%4!=1&&board1[i][j]!=2) count++;
    back_xy(&i,&j,dir);
    if(board1[i][j]==1) count++;
    back_xy(&i,&j,dir);
    if(board1[i][j]%4!=1&&board1[i][j]!=2) count++;
    if(count==5) return 1;
    else return 0;
}

int add_case(int i,int j,int dir){
    int a[10];
    a[0] = case_1(i,j,dir);
    a[1]=case_2_1(i,j,dir);
    a[2] = case_2_2(i,j,dir);
    a[3] = case_3_1(i,j,dir);
    a[4] = case_3_2(i,j,dir);
    a[5] = case_4_1(i,j,dir);
    a[6] = case_4_2(i,j,dir);
    int sum=0;
    for(int k=0;k<7;++k) sum+=a[k];

    if(sum>0) return 1;
    else return 0;
}

void find_3_4(){
    add_34();
    for(int i=0;i<25;++i){
        for(int j=0;j<25;++j){
            if(find34[i][j]==1){
                for(int dir=0;dir<4;++dir){
                    if(find_34[i][j][dir]==1){
                        find34[i][j] += add_case(i,j,dir);
                    }
                }
            }
        }
    }
}

void reset_34();

void do_3_4(){
    find_3_4();
    for(int i=0;i<25;++i){
        for(int j=0;j<25;++j){
            if(find34[i][j]==2) ADD_NUM_1(i,j,1500);
        }
    }
    reset_34();
}

void reset_34(){
    for(int i =0;i<25;++i){
        for(int j=0;j<25;++j){
            for(int dir=0;dir<4;++dir)
            {
            find_34[i][j][dir] = 0;
            find34[i][j] = 0;
            }
        }
    }
}

void add_4(){
    for(int i = 0;i<25;++i){
        for(int j=0;j<25;++j){
            board4[i][j] = board4_1[i][j] + board4_2[i][j];
        }
    }
}