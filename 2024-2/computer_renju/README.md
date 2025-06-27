# computer_renju_c
make renju c program play with computer

You can play gomoku with computer to execute renju.c file. 
I will do optimized later to make gomoku online by unity.

This is my first game which made in SNU_programmin practice class assignment.
Different with class assignment is playing with computer.
Now i will show my computer algorithm which in my renju.c

my algorithm ::
need :
25x25 board that get int number
25x25 board dir_1
25x25 board dir_1 defend
25x25 board dir_2
25x25 board dir_2 attack
25x25 board sum
6 integer 25x25 board
100x2 tmp //value of computer concave number
int max_Val = min_Int

do :
1. //first add in board dir_1 defend
   for(check stone line = 4, check stone line = 1, --check stone line)
     for(check all of 25x25 points)
       1 point :
         for(4 dir that dir=0,1,2,3)     // dir=0 dir=1 dir=2 dir=3 mean(1,1) (1,0) (0,1) (1,-1) 4 direction
           if(board dir_1 % 2^(dir+1) < 2^dir && player_stone(dir,point's coordinate) == check stone line && isneed_player(dir,coordinate)) begin
   // if board dir_1 is 1101(2) this means i add dir0,dir2,dir3 add in board dir_1 defend
   // see in example if dir = 0 board dir_1 % 2^1 = 1 (when 1101(2)) It isnt certify if condition. becuz 1 < 1
   // but when you see 1100(2) example It certify if condition. 0 < 1
   // so this mean if I calculate one direction like dir=2 it isnt need add another line of count.
   // lets see example
   // i add . O O O 300 points in . board
   // but in my algorithm . O O also add points less than 300 in . board
   // it made computer foolish, so i add this dir_1 dir_2 board to check is it already add it. lets see other algorithm
             board dir_1 defend += defend points //it is depend by check stone line
             board dir_1 += 2^dir
             end
           end
         end
       end

3. //second add in board dir_2 attack // It is maybe same as 1 only different player stone to my stone
   for(check stone line = 4,check stone line = 1,--check stone line)
     for(check all 25x25 points)
       1 point :
         for(4 dir, dir=0,1,2,3)
           if(board dir_2 % 2^(dir+1) < 2^dir && Computer_stone(dir,point's coordinate) == check stone line && isneed_computer(dir,coordinate)_ begin
            board dir_2 attack += defend points
            board dir_2 += 2^dir
            end
         end
      end
   end

4. add board dir_1 dir_2
   board sum = board dir_1 defend + board dir_2 attack

5. find high Integer in board sum
   for(check all 25x25 points)
      1 point :
         if(board sum[point's coordinate] > max_Val) begin
            empty the array tmp    //(tmp work like array list)
            put tmp[0] <- point's coordinate
         else if(board sum[point's coordinate == maxVal)
            put tmp <- point's coordinate
         end
      end

6. get randomized tmp
   get 1 random coordinate in tmp
   that tmp[i][0] : x, tmp[i][1] : y is computer's concave number

7. reset all value of array which i use for this algorithm
   and if computer turn, do algorithm 1
   or if game end, algorithm is end.

function int player_stone (int dir,coordinate my_location) // coordinate is board[x,y] -> (x,y)
   for(all dir = 0,1,2,3, and - dir) // -dir means dir=0 : (1,1) -dir=0 : (-1,-1)
      int count = 0
      for(i=0,i<5,i++)
         if(my_location + dir*i coordinate == player stone)
            ++count
         else if(my_location + dir*i coordinate == computer stone)
            break;
      end
      return count
   end
endfunction

function int Computer_stone (int dir,coordinate my_location) // coordinate is board[x,y] -> (x,y)
   for(all dir = 0,1,2,3, and - dir) // -dir means dir=0 : (1,1) -dir=0 : (-1,-1)
      int count = 0
      for(i=0,i<5,i++)
         if(my_location + dir*i coordinate == computer stone)
            ++count
         else if(my_location + dir*i coordinate == player stone)
            break;
      end
      return count
   end
endfunction

function bool isneed_player (int dir,coordinate my_location)
   //its check for is this coordinate is usefull to put stone
   //example X O O O . X // . counting 3 player stone so in my algorithm, it will be add defend points
   //However it doesn't need to defend it. so this function prevent this situation
   //also prevent endofmap O O O . // we dont need put stone this case
   in dir, my_location find player stone
   and is it need to put stone, return true
   else return true
   //i cant remember this algorithm, so i just write only english
endfunction

function bool isneed_computer (int dir,coordinate my_locaton)
   same as isneed_player
endfunction

// i remember that more logic in here to calculate better case to attack or defend
// but i cant find it, because my code is hardcoding so i cant find it.
   
