addpath('userinput');
addpath('Queue');

constructor
global exitFlag


while true
    myInput = input('~/store$ ','s');
    Queue = DivideCmd(myInput);

    while ~isempty(Queue) && ~exitFlag
        [Queue,cmd] = dequeue(Queue);
        dummy = userinput(cmd);
        [Truss, Stack] = processCMD(dummy,Truss,Stack);

    end

    if exitFlag
        break;
    end
end