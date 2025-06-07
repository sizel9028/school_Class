function [Stack,Truss] = pop(Stack)
    if isempty(Stack)
        Truss = struct();
        return;
    end

    Truss = Stack{end};
    Stack(end) = [];
end