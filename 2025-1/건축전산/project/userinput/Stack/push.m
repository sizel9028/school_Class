function Stack = push(Stack, Truss)
    Stack{end+1} = Truss;

    if numel(Stack) > 1000
        Stack(1) = [];
    end
end