addpath('userinput');
addpath('Queue');

constructor
global exitFlag
global Queue


while true
    myInput = input('~/store$ ','s');
    Queue = DivideCmd(myInput);

    while ~isempty(Queue) && ~exitFlag
        [Queue,cmd] = dequeue();

        [Truss,Beam, Stack] = MuxInput(cmd,Truss,Beam,Stack);
    end

    if exitFlag
        break;
    end
end