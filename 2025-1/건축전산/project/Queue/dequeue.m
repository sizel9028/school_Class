function [Queue, item] = dequeue()

global Queue

    if isempty(Queue)
        error("큐가 비어있습니다");
    end

    item = Queue{1};
    Queue(1) = [];

end