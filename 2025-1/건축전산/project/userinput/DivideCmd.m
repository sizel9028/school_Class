function Queue = DivideCmd(inputText)
    cmds = split(inputText, '/');

    cmds = strtrim(cmds);
    cmds = cmds(~cellfun(@isempty, cmds));

    Queue = cmds;
end
